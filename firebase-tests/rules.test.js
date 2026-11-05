// Tests of firestore.rules against the emulator: `npm test`.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-jaguar',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

after(() => env.cleanup());
beforeEach(() => env.clearFirestore());

const db = (uid) => (uid ? env.authenticatedContext(uid) : env.unauthenticatedContext()).firestore();

/** A teacher's class with its code, written without rules. */
async function seedClass() {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const admin = ctx.firestore();
    await setDoc(doc(admin, 'classes/c1'), { name: '1A', ownerId: 'profe', ownerAlias: 'Profe', code: 'JAG-4K7Q' });
    await setDoc(doc(admin, 'classCodes/JAG-4K7Q'), { classId: 'c1', ownerId: 'profe' });
    await setDoc(doc(admin, 'classes/c1/assignments/a1'), {
      title: 'Par o impar',
      exercise: { id: 'x', t: 'Par o impar', c: [] },
      hiddenCount: 1,
    });
    await setDoc(doc(admin, 'classes/c1/hiddenCases/a1'), {
      cases: [{ i: ['0'], e: 'Par', h: true }],
    });
  });
}

const member = (code = 'JAG-4K7Q') => ({ name: 'Ana', role: 'alumno', code, joinedAt: serverTimestamp() });

describe('perfil', () => {
  test('cada quien lee y escribe solo el suyo', async () => {
    await assertSucceeds(setDoc(doc(db('ana'), 'users/ana'), { alias: 'Ana', role: 'alumno' }));
    await assertFails(getDoc(doc(db('beto'), 'users/ana')));
    await assertFails(setDoc(doc(db('beto'), 'users/ana'), { alias: 'X', role: 'alumno' }));
  });

  test('sin campos de más ni roles inventados', async () => {
    await assertFails(setDoc(doc(db('ana'), 'users/ana'), { alias: 'Ana', role: 'admin' }));
    await assertFails(setDoc(doc(db('ana'), 'users/ana'), { alias: 'Ana', role: 'alumno', telefono: '555' }));
  });
});

describe('clases', () => {
  test('el profesor crea su clase y su código', async () => {
    const profe = db('profe');
    await assertSucceeds(setDoc(doc(profe, 'classes/c2'), { name: '2B', ownerId: 'profe', ownerAlias: 'P', code: 'JAG-AAAA' }));
    await assertSucceeds(setDoc(doc(profe, 'classCodes/JAG-AAAA'), { classId: 'c2', ownerId: 'profe' }));
    await assertFails(setDoc(doc(db('otro'), 'classCodes/JAG-BBBB'), { classId: 'c2', ownerId: 'otro' }));
  });

  test('con el código un alumno se une; sin él, no', async () => {
    await seedClass();
    const ana = db('ana');
    await assertSucceeds(getDoc(doc(ana, 'classCodes/JAG-4K7Q')));
    await assertFails(getDocs(collection(ana, 'classCodes')));
    await assertFails(setDoc(doc(ana, 'classes/c1/members/ana'), member('JAG-MALO')));
    await assertSucceeds(setDoc(doc(ana, 'classes/c1/members/ana'), member()));
    await assertSucceeds(getDoc(doc(ana, 'classes/c1')));
  });

  test('un alumno no puede hacerse profesor ni ver a sus compañeros', async () => {
    await seedClass();
    await assertFails(setDoc(doc(db('ana'), 'classes/c1/members/ana'), { ...member(), role: 'profesor' }));
    await setDoc(doc(db('beto'), 'classes/c1/members/beto'), member());
    await assertFails(getDocs(collection(db('beto'), 'classes/c1/members')));
    await assertFails(getDoc(doc(db('beto'), 'classes/c1/members/ana')));
    await assertSucceeds(getDocs(collection(db('profe'), 'classes/c1/members')));
  });

  test('alguien de fuera no ve la clase ni sus tareas', async () => {
    await seedClass();
    await assertFails(getDoc(doc(db('extraño'), 'classes/c1')));
    await assertFails(getDocs(collection(db('extraño'), 'classes/c1/assignments')));
  });

  test('solo el profesor asigna tareas', async () => {
    await seedClass();
    await setDoc(doc(db('ana'), 'classes/c1/members/ana'), member());
    const task = { title: 'Mayor', exercise: { id: 'y' }, createdAt: serverTimestamp() };
    await assertFails(setDoc(doc(db('ana'), 'classes/c1/assignments/a2'), task));
    await assertSucceeds(setDoc(doc(db('profe'), 'classes/c1/assignments/a2'), task));
    await assertSucceeds(getDocs(collection(db('ana'), 'classes/c1/assignments')));
  });

  test('cada alumno entrega lo suyo y solo el profesor ve todas', async () => {
    await seedClass();
    await setDoc(doc(db('ana'), 'classes/c1/members/ana'), member());
    const work = { name: 'Ana', source: 'Algoritmo a\nFinAlgoritmo', passed: 2, total: 3, updatedAt: serverTimestamp() };
    await assertSucceeds(setDoc(doc(db('ana'), 'classes/c1/assignments/a1/submissions/ana'), work));
    await assertFails(setDoc(doc(db('ana'), 'classes/c1/assignments/a1/submissions/beto'), work));
    await assertFails(setDoc(doc(db('extraño'), 'classes/c1/assignments/a1/submissions/extraño'), work));
    await assertSucceeds(getDocs(collection(db('profe'), 'classes/c1/assignments/a1/submissions')));
    await setDoc(doc(db('beto'), 'classes/c1/members/beto'), member());
    await assertFails(getDoc(doc(db('beto'), 'classes/c1/assignments/a1/submissions/ana')));
  });

  test('la entrega puede decir cuántas líneas pegó, solo como número', async () => {
    await seedClass();
    await setDoc(doc(db('ana'), 'classes/c1/members/ana'), member());
    const work = { name: 'Ana', source: 'Algoritmo a\nFinAlgoritmo', passed: 2, total: 3, updatedAt: serverTimestamp() };
    const path = 'classes/c1/assignments/a1/submissions/ana';
    await assertSucceeds(setDoc(doc(db('ana'), path), { ...work, pasted: 12 }));
    await assertFails(setDoc(doc(db('ana'), path), { ...work, pasted: 'mucho' }));
    await assertFails(setDoc(doc(db('ana'), path), { ...work, pasted: 0 }));
  });

  test('al borrar su cuenta el alumno se lleva su entrega, no la de otros', async () => {
    await seedClass();
    await setDoc(doc(db('ana'), 'classes/c1/members/ana'), member());
    await setDoc(doc(db('beto'), 'classes/c1/members/beto'), member());
    const work = { name: 'Ana', source: 'x', passed: 1, total: 1, updatedAt: serverTimestamp() };
    await setDoc(doc(db('ana'), 'classes/c1/assignments/a1/submissions/ana'), work);
    await assertFails(deleteDoc(doc(db('beto'), 'classes/c1/assignments/a1/submissions/ana')));
    await assertSucceeds(deleteDoc(doc(db('ana'), 'classes/c1/assignments/a1/submissions/ana')));
    await assertSucceeds(deleteDoc(doc(db('ana'), 'classes/c1/members/ana')));
  });
});

describe('seguridad de las clases', () => {
  test('los casos ocultos solo los lee el profesor', async () => {
    await seedClass();
    await assertSucceeds(setDoc(doc(db('ana'), 'classes/c1/members/ana'), member()));
    // El profesor los lee y los escribe.
    await assertSucceeds(getDoc(doc(db('profe'), 'classes/c1/hiddenCases/a1')));
    await assertSucceeds(setDoc(doc(db('profe'), 'classes/c1/hiddenCases/a2'), { cases: [] }));
    // Una alumna de la clase no los ve, ni por documento ni listando.
    await assertFails(getDoc(doc(db('ana'), 'classes/c1/hiddenCases/a1')));
    await assertFails(getDocs(collection(db('ana'), 'classes/c1/hiddenCases')));
    // Tampoco quien no es de la clase, ni una visita sin cuenta.
    await assertFails(getDoc(doc(db('beto'), 'classes/c1/hiddenCases/a1')));
    await assertFails(getDoc(doc(db(null), 'classes/c1/hiddenCases/a1')));
    // Y nadie más los cambia.
    await assertFails(setDoc(doc(db('ana'), 'classes/c1/hiddenCases/a1'), { cases: [] }));
    await assertFails(deleteDoc(doc(db('ana'), 'classes/c1/hiddenCases/a1')));
    // Solo el campo permitido y un tamaño razonable.
    await assertFails(setDoc(doc(db('profe'), 'classes/c1/hiddenCases/a3'), { cases: [], extra: 1 }));
    await assertFails(setDoc(doc(db('profe'), 'classes/c1/hiddenCases/a4'), { cases: new Array(51).fill({}) }));
  });

  test('la tarea dice cuántos casos ocultos tiene, con un número sensato', async () => {
    await seedClass();
    const exercise = { id: 'x', t: 'Otro', c: [] };
    await assertSucceeds(setDoc(doc(db('profe'), 'classes/c1/assignments/a5'), { title: 'Otro', exercise, hiddenCount: 3 }));
    await assertFails(setDoc(doc(db('profe'), 'classes/c1/assignments/a6'), { title: 'Otro', exercise, hiddenCount: -1 }));
    await assertFails(setDoc(doc(db('profe'), 'classes/c1/assignments/a7'), { title: 'Otro', exercise, hiddenCount: 51 }));
    await assertFails(setDoc(doc(db('profe'), 'classes/c1/assignments/a8'), { title: 'Otro', exercise, hiddenCount: 'tres' }));
    await assertFails(setDoc(doc(db('ana'), 'classes/c1/assignments/a9'), { title: 'Otro', exercise, hiddenCount: 1 }));
  });

  test('el profesor cierra la clase y nadie nuevo se une; al abrirla, sí', async () => {
    await seedClass();
    const clase = { name: '1A', ownerId: 'profe', ownerAlias: 'Profe', code: 'JAG-4K7Q' };
    await assertSucceeds(setDoc(doc(db('profe'), 'classes/c1'), { ...clase, open: false }));
    await assertFails(setDoc(doc(db('ana'), 'classes/c1/members/ana'), member()));
    await assertSucceeds(setDoc(doc(db('profe'), 'classes/c1'), { ...clase, open: true }));
    await assertSucceeds(setDoc(doc(db('ana'), 'classes/c1/members/ana'), member()));
    // Quien ya estaba dentro sigue dentro al cerrarla.
    await assertSucceeds(setDoc(doc(db('profe'), 'classes/c1'), { ...clase, open: false }));
    await assertSucceeds(getDoc(doc(db('ana'), 'classes/c1')));
    await assertSucceeds(setDoc(doc(db('ana'), 'classes/c1/members/ana'), { ...member(), name: 'Ana P.' }));
  });

  test('solo el profesor cambia la clase, y solo sus campos', async () => {
    await seedClass();
    const clase = { name: '1A', ownerId: 'profe', ownerAlias: 'Profe', code: 'JAG-4K7Q' };
    await assertFails(setDoc(doc(db('ana'), 'classes/c1'), { ...clase, open: false }));
    await assertFails(setDoc(doc(db('profe'), 'classes/c1'), { ...clase, open: 'si' }));
    await assertFails(setDoc(doc(db('profe'), 'classes/c1'), { ...clase, secreto: 'algo' }));
    await assertFails(setDoc(doc(db('profe'), 'classes/c1'), { ...clase, code: 'JAG-OTRO' }));
    await assertFails(setDoc(doc(db('profe'), 'classes/c1'), { ...clase, ownerId: 'beto' }));
    await assertFails(setDoc(doc(db('profe'), 'classes/c1'), { ...clase, name: '' }));
    await assertSucceeds(setDoc(doc(db('profe'), 'classes/c1'), { ...clase, name: '1A Lógica' }));
  });

  test('una entrega con números absurdos se rechaza', async () => {
    await seedClass();
    await setDoc(doc(db('ana'), 'classes/c1/members/ana'), member());
    const path = 'classes/c1/assignments/a1/submissions/ana';
    const entrega = { name: 'Ana', source: 'Algoritmo a\nFinAlgoritmo', passed: 1, total: 2, updatedAt: serverTimestamp() };
    await assertSucceeds(setDoc(doc(db('ana'), path), entrega));
    await assertFails(setDoc(doc(db('ana'), path), { ...entrega, passed: 3 }));
    await assertFails(setDoc(doc(db('ana'), path), { ...entrega, passed: -1 }));
    await assertFails(setDoc(doc(db('ana'), path), { ...entrega, passed: 600, total: 600 }));
  });
});

describe('comunidad', () => {
  const publication = (authorId) => ({
    kind: 'programa',
    title: 'Adivina el número',
    description: 'Un juego',
    topic: 'ciclos',
    authorId,
    authorAlias: 'Ana',
    content: { source: 'Algoritmo a\nFinAlgoritmo' },
    status: 'publicado',
    createdAt: serverTimestamp(),
  });

  test('publicar a nombre propio; cualquiera puede verlo', async () => {
    await assertSucceeds(setDoc(doc(db('ana'), 'publications/p1'), publication('ana')));
    await assertFails(setDoc(doc(db('ana'), 'publications/p2'), publication('beto')));
    await assertSucceeds(getDoc(doc(db(null), 'publications/p1')));
    await assertSucceeds(
      getDocs(query(collection(db(null), 'publications'), where('status', '==', 'publicado'))),
    );
  });

  test('lo oculto solo lo ve su autor; nadie edita lo ajeno', async () => {
    await setDoc(doc(db('ana'), 'publications/p1'), publication('ana'));
    const createdAt = (await getDoc(doc(db('ana'), 'publications/p1'))).data().createdAt;
    await assertSucceeds(setDoc(doc(db('ana'), 'publications/p1'), { ...publication('ana'), createdAt, status: 'oculto' }));
    await assertFails(getDoc(doc(db('beto'), 'publications/p1')));
    await assertFails(deleteDoc(doc(db('beto'), 'publications/p1')));
  });

  test('lo que un moderador marcó no lo deshace el autor', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      const { createdAt, ...rest } = publication('ana');
      await setDoc(doc(ctx.firestore(), 'publications/m1'), { ...rest, createdAt: new Date(0), status: 'moderado' });
    });
    await assertFails(setDoc(doc(db('ana'), 'publications/m1'), { ...publication('ana'), createdAt: new Date(0), status: 'publicado' }));
    await assertFails(setDoc(doc(db('ana'), 'publications/m1'), { ...publication('ana'), createdAt: new Date(0), status: 'oculto' }));
    // El público no lo ve, y su autor sí.
    await assertFails(getDoc(doc(db(null), 'publications/m1')));
    await assertSucceeds(getDoc(doc(db('ana'), 'publications/m1')));
  });

  test('el autor corrige lo suyo, con límites y sin cambiar de quién es', async () => {
    const original = { ...publication('ana'), createdAt: new Date(0) };
    await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'publications/e1'), original));
    const edit = (change) => setDoc(doc(db('ana'), 'publications/e1'), { ...original, ...change });
    await assertSucceeds(edit({ title: 'Adivina el número 2' }));
    await assertFails(edit({ title: '' }));
    await assertFails(edit({ title: 'x'.repeat(121) }));
    await assertFails(edit({ description: 'x'.repeat(2001) }));
    await assertFails(edit({ content: 'no es un mapa' }));
    await assertFails(edit({ authorId: 'beto' }));
    await assertFails(edit({ kind: 'tutorial' }));
    await assertFails(edit({ createdAt: new Date(1) }));
    await assertFails(edit({ extra: 'algo' }));
    await assertFails(edit({ status: 'moderado' }));
    await assertFails(setDoc(doc(db('beto'), 'publications/e1'), { ...original, title: 'Ajeno' }));
  });

  test('"me sirvió" una vez por persona; reportar sin leer reportes', async () => {
    await setDoc(doc(db('ana'), 'publications/p1'), publication('ana'));
    await assertSucceeds(setDoc(doc(db('beto'), 'publications/p1/useful/beto'), {}));
    await assertFails(setDoc(doc(db('beto'), 'publications/p1/useful/ana'), {}));
    const report = { publicationId: 'p1', reporterId: 'beto', reason: 'No es apropiado', createdAt: serverTimestamp() };
    await assertSucceeds(setDoc(doc(db('beto'), 'reports/r1'), report));
    await assertFails(getDoc(doc(db('beto'), 'reports/r1')));
  });
});

describe('red de apoyo', () => {
  test('solo ofertas verificadas, y nadie las escribe desde la app', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'supportOffers/o1'), { title: 'Impresión 3D', verified: true });
      await setDoc(doc(ctx.firestore(), 'supportOffers/o2'), { title: 'Sin revisar', verified: false });
    });
    await assertSucceeds(getDoc(doc(db(null), 'supportOffers/o1')));
    await assertFails(getDoc(doc(db(null), 'supportOffers/o2')));
    await assertFails(setDoc(doc(db('ana'), 'supportOffers/o3'), { title: 'Falsa', verified: true }));
  });
});

describe('mensajes de la página', () => {
  test('cualquiera deja un mensaje, nadie lo lee ni lo cambia', async () => {
    const msg = { tipo: 'piloto', mensaje: 'Doy Cultura Digital en 1A', escuela: 'CBTis 1', creado: serverTimestamp() };
    await assertSucceeds(setDoc(doc(db(null), 'mensajes/m1'), msg));
    await assertFails(getDoc(doc(db(null), 'mensajes/m1')));
    await assertFails(getDocs(collection(db('ana'), 'mensajes')));
    await assertFails(setDoc(doc(db(null), 'mensajes/m1'), { ...msg, mensaje: 'Otro' }));
    await assertFails(deleteDoc(doc(db(null), 'mensajes/m1')));
  });

  test('solo los campos y tamaños permitidos', async () => {
    const base = { tipo: 'sugerencia', mensaje: 'Más retos', creado: serverTimestamp() };
    await assertSucceeds(setDoc(doc(db(null), 'mensajes/m7'), { ...base, tipo: 'datos' }));
    await assertFails(setDoc(doc(db(null), 'mensajes/m2'), { ...base, tipo: 'spam' }));
    await assertFails(setDoc(doc(db(null), 'mensajes/m3'), { ...base, mensaje: '' }));
    await assertFails(setDoc(doc(db(null), 'mensajes/m4'), { ...base, mensaje: 'x'.repeat(2001) }));
    await assertFails(setDoc(doc(db(null), 'mensajes/m5'), { ...base, extra: 'algo' }));
    await assertFails(setDoc(doc(db(null), 'mensajes/m6'), { ...base, creado: new Date(0) }));
  });
});

describe('acceso anticipado de la página', () => {
  test('cualquiera deja su correo; nadie lo lee ni lo cambia', async () => {
    const entry = { correo: 'ana@correo.mx', origen: 'acceso', creado: serverTimestamp() };
    await assertSucceeds(setDoc(doc(db(null), 'accesoAnticipado/a1'), entry));
    await assertFails(getDoc(doc(db(null), 'accesoAnticipado/a1')));
    await assertFails(getDocs(collection(db('ana'), 'accesoAnticipado')));
    await assertFails(setDoc(doc(db(null), 'accesoAnticipado/a1'), { ...entry, origen: 'inicio' }));
    await assertFails(deleteDoc(doc(db(null), 'accesoAnticipado/a1')));
  });

  test('el mismo correo otra vez se acepta con otro id: no se puede averiguar quién está en la lista', async () => {
    const entry = { correo: 'ana@correo.mx', origen: 'acceso', creado: serverTimestamp() };
    await assertSucceeds(setDoc(doc(db(null), 'accesoAnticipado/id-uno'), entry));
    await assertSucceeds(setDoc(doc(db(null), 'accesoAnticipado/id-dos'), entry));
  });

  test('solo correos con forma de correo, y los campos permitidos', async () => {
    const base = { correo: 'leo@escuela.edu.mx', origen: 'inicio', creado: serverTimestamp() };
    await assertSucceeds(setDoc(doc(db(null), 'accesoAnticipado/b1'), base));
    await assertFails(setDoc(doc(db(null), 'accesoAnticipado/b2'), { ...base, correo: 'sin-arroba' }));
    await assertFails(setDoc(doc(db(null), 'accesoAnticipado/b3'), { ...base, correo: 'dos@@x.mx' }));
    await assertFails(setDoc(doc(db(null), 'accesoAnticipado/b4'), { ...base, correo: 'con espacio@x.mx' }));
    await assertFails(setDoc(doc(db(null), 'accesoAnticipado/b5'), { ...base, correo: 'a@b' }));
    await assertFails(setDoc(doc(db(null), 'accesoAnticipado/b6'), { ...base, correo: `${'x'.repeat(200)}@x.mx` }));
    await assertFails(setDoc(doc(db(null), 'accesoAnticipado/b7'), { ...base, origen: 'otro' }));
    await assertFails(setDoc(doc(db(null), 'accesoAnticipado/b8'), { ...base, nombre: 'Ana' }));
    await assertFails(setDoc(doc(db(null), 'accesoAnticipado/b9'), { ...base, creado: new Date(0) }));
  });
});

// Abusos de la auditoría de seguridad: campos sin tipo ni tamaño.
describe('campos acotados (auditoría)', () => {
  const big = 'x'.repeat(5000);

  test('la entrega lleva un nombre corto y de texto', async () => {
    await seedClass();
    await setDoc(doc(db('ana'), 'classes/c1/members/ana'), member());
    const work = { name: 'Ana', source: 'x', passed: 1, total: 1, updatedAt: serverTimestamp() };
    const path = 'classes/c1/assignments/a1/submissions/ana';
    await assertSucceeds(setDoc(doc(db('ana'), path), work));
    await assertFails(setDoc(doc(db('ana'), path), { ...work, name: big }));
    await assertFails(setDoc(doc(db('ana'), path), { ...work, name: 42 }));
    await assertFails(setDoc(doc(db('ana'), path), { ...work, name: '' }));
  });

  test('la clase lleva un alias y un código acotados', async () => {
    const base = { name: '1A', ownerId: 'profe', ownerAlias: 'Profe', code: 'JAG-K7Q4M2XP', createdAt: serverTimestamp() };
    await assertSucceeds(setDoc(doc(db('profe'), 'classes/ok'), base));
    await assertFails(setDoc(doc(db('profe'), 'classes/malo1'), { ...base, ownerAlias: big }));
    await assertFails(setDoc(doc(db('profe'), 'classes/malo2'), { ...base, ownerAlias: 7 }));
    await assertFails(setDoc(doc(db('profe'), 'classes/malo3'), { ...base, code: big }));
    await assertFails(setDoc(doc(db('profe'), 'classes/malo4'), { ...base, code: 12 }));
  });

  test('la tarea lleva un ejercicio de tamaño razonable', async () => {
    await seedClass();
    const many = Object.fromEntries(Array.from({ length: 40 }, (_, i) => [`k${i}`, i]));
    await assertSucceeds(
      setDoc(doc(db('profe'), 'classes/c1/assignments/ok'), { title: 'T', exercise: { id: 'x', t: 'T', c: [] } }),
    );
    await assertFails(setDoc(doc(db('profe'), 'classes/c1/assignments/malo'), { title: 'T', exercise: many }));
  });

  test('el perfil no guarda una lista de clases interminable', async () => {
    const classes = (n) => Array.from({ length: n }, (_, i) => `c${i}`);
    await assertSucceeds(setDoc(doc(db('ana'), 'users/ana'), { alias: 'Ana', role: 'alumno', classes: classes(50) }));
    await assertFails(setDoc(doc(db('ana'), 'users/ana'), { alias: 'Ana', role: 'alumno', classes: classes(500) }));
  });

  test('la publicación lleva un contenido acotado y los reportes un id corto', async () => {
    const many = Object.fromEntries(Array.from({ length: 40 }, (_, i) => [`k${i}`, i]));
    const pub = (content) => ({
      kind: 'programa',
      title: 'Programa',
      description: 'd',
      topic: 'ciclos',
      authorId: 'ana',
      authorAlias: 'Ana',
      content,
      status: 'publicado',
      createdAt: serverTimestamp(),
    });
    await assertSucceeds(setDoc(doc(db('ana'), 'publications/ok'), pub({ source: 'x' })));
    await assertFails(setDoc(doc(db('ana'), 'publications/malo'), pub(many)));
    const report = (id) => ({ publicationId: id, reporterId: 'ana', reason: 'no va', createdAt: serverTimestamp() });
    await assertSucceeds(setDoc(doc(db('ana'), 'reports/r1'), report('ok')));
    await assertFails(setDoc(doc(db('ana'), 'reports/r2'), report(big)));
    await assertFails(setDoc(doc(db('ana'), 'reports/r3'), report(5)));
  });
});

// Lo que hace la app al quitar a un alumno (RestBackend.removeMember): en una
// sola escritura, borra sus entregas y su lugar en la clase.
describe('quitar a un alumno', () => {
  async function seedStudent() {
    await seedClass();
    await setDoc(doc(db('ana'), 'classes/c1/members/ana'), member());
    await setDoc(doc(db('ana'), 'classes/c1/assignments/a1/submissions/ana'), {
      name: 'Ana', source: 'x', passed: 1, total: 1, updatedAt: serverTimestamp(),
    });
  }

  test('el profesor la quita con sus entregas, en un solo paso', async () => {
    await seedStudent();
    const profe = db('profe');
    const batch = writeBatch(profe);
    batch.delete(doc(profe, 'classes/c1/assignments/a1/submissions/ana'));
    batch.delete(doc(profe, 'classes/c1/members/ana'));
    await assertSucceeds(batch.commit());
    const left = await getDocs(collection(profe, 'classes/c1/members'));
    assert.equal(left.size, 0, 'quedó el alumno');
    const work = await getDocs(collection(profe, 'classes/c1/assignments/a1/submissions'));
    assert.equal(work.size, 0, 'quedó su entrega');
  });

  test('otro alumno no puede quitarla, ni borrar su entrega', async () => {
    await seedStudent();
    await setDoc(doc(db('beto'), 'classes/c1/members/beto'), member());
    await assertFails(deleteDoc(doc(db('beto'), 'classes/c1/members/ana')));
    await assertFails(deleteDoc(doc(db('beto'), 'classes/c1/assignments/a1/submissions/ana')));
  });

  test('tras quitarla, no puede volver a entregar sin unirse otra vez', async () => {
    await seedStudent();
    await deleteDoc(doc(db('profe'), 'classes/c1/members/ana'));
    const work = { name: 'Ana', source: 'y', passed: 1, total: 1, updatedAt: serverTimestamp() };
    await assertFails(setDoc(doc(db('ana'), 'classes/c1/assignments/a1/submissions/ana'), work));
  });
});
