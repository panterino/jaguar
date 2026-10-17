// Tests of firestore.rules against the emulator: `npm test`.
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
    await assertSucceeds(setDoc(doc(db('ana'), 'publications/p1'), { ...publication('ana'), status: 'oculto' }));
    await assertFails(getDoc(doc(db('beto'), 'publications/p1')));
    await assertFails(deleteDoc(doc(db('beto'), 'publications/p1')));
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
