// Jaguar, la página: acceso anticipado, mascota, lección de prueba y
// animaciones al bajar. Sin librerías. Todo lo que se mueve respeta
// prefers-reduced-motion y la página se lee igual si este archivo no carga.
(function () {
  'use strict';
  var quieto = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var APP = 'https://app.jaguarcode.org/';
  var CLAVE = 'jaguar.accesoAnticipado';

  function guardado() { try { return localStorage.getItem(CLAVE) === '1'; } catch (e) { return false; } }
  function recuerda() { try { localStorage.setItem(CLAVE, '1'); } catch (e) { /* sin almacenamiento */ } }

  // ---- Confeti -----------------------------------------------------------
  function confeti(origen) {
    if (quieto) return;
    var caja = document.createElement('div');
    caja.className = 'confeti';
    caja.setAttribute('aria-hidden', 'true');
    var r = origen && origen.getBoundingClientRect ? origen.getBoundingClientRect() : { left: innerWidth / 2, top: innerHeight / 2, width: 0, height: 0 };
    var cx = r.left + r.width / 2, cy = r.top + r.height / 2;
    var colores = ['#F4B723', '#00A8F0', '#7BC043', '#FF8AB8', '#FFFFFF'];
    for (var i = 0; i < 36; i++) {
      var p = document.createElement('i');
      var ang = Math.random() * Math.PI * 2, fuerza = 90 + Math.random() * 190;
      p.style.cssText = 'left:' + cx + 'px;top:' + cy + 'px;background:' + colores[i % colores.length] +
        ';--x:' + Math.cos(ang) * fuerza + 'px;--y:' + (Math.sin(ang) * fuerza + 140) + 'px;--r:' + (Math.random() * 720 - 360) + 'deg;animation-delay:' + Math.random() * 80 + 'ms';
      caja.appendChild(p);
    }
    document.body.appendChild(caja);
    setTimeout(function () { caja.remove(); }, 1800);
  }

  // ---- Acceso anticipado -------------------------------------------------
  var api = 'https://firestore.googleapis.com/v1/projects/jaguarapp-50a15/databases/(default)/documents';
  var llave = 'AIzaSyD771Ak8TGNvnW1B_vRhMb6AG0IxPssrcE';
  var forma = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

  function huella(texto) {
    return crypto.subtle.digest('SHA-256', new TextEncoder().encode(texto)).then(function (b) {
      return Array.from(new Uint8Array(b)).map(function (x) { return x.toString(16).padStart(2, '0'); }).join('').slice(0, 32);
    });
  }

  function adentro(caja, celebra) {
    caja.classList.add('listo');
    var dentro = caja.querySelector('.dentro');
    if (dentro) {
      dentro.hidden = false;
      var titulo = dentro.querySelector('h3');
      if (titulo) { titulo.tabIndex = -1; if (celebra) titulo.focus({ preventScroll: true }); }
    }
    if (celebra) confeti(dentro || caja);
  }

  document.querySelectorAll('.acceso').forEach(function (caja) {
    var form = caja.querySelector('form');
    var estado = caja.querySelector('.estado');
    var origen = caja.getAttribute('data-origen') || 'acceso';
    if (guardado()) { adentro(caja, false); return; }
    if (!form) return;
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      if (form.sitio && form.sitio.value) return;
      var correo = String(form.correo.value || '').trim().toLowerCase();
      estado.className = 'estado';
      if (!forma.test(correo) || correo.length < 6 || correo.length > 200) {
        estado.className = 'estado mal';
        estado.textContent = 'Revisa tu correo: parece que le falta algo.';
        form.correo.focus();
        return;
      }
      var boton = form.querySelector('[type=submit]');
      boton.disabled = true;
      estado.textContent = 'Un momento…';
      huella(correo).then(function (id) {
        return fetch(api + ':commit?key=' + llave, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ writes: [{
            update: {
              name: 'projects/jaguarapp-50a15/databases/(default)/documents/accesoAnticipado/' + id,
              fields: { correo: { stringValue: correo }, origen: { stringValue: origen } }
            },
            updateTransforms: [{ fieldPath: 'creado', setToServerValue: 'REQUEST_TIME' }],
            currentDocument: { exists: false }
          }] })
        });
      }).then(function (r) {
        // 409: ese correo ya estaba en la lista; para quien lo escribe es lo mismo.
        if (!r.ok && r.status !== 409) throw new Error(r.status);
        recuerda();
        form.reset();
        estado.textContent = '';
        document.querySelectorAll('.acceso').forEach(function (otra) { adentro(otra, otra === caja); });
      }).catch(function () {
        estado.className = 'estado mal';
        estado.textContent = 'No se pudo guardar. Revisa tu conexión e inténtalo otra vez.';
      }).then(function () { boton.disabled = false; });
    });
  });

  // El botón de la portada cambia para quien ya está en la lista.
  if (guardado()) {
    document.querySelectorAll('[data-solo-lista]').forEach(function (a) { a.hidden = false; });
    document.querySelectorAll('[data-sin-lista]').forEach(function (a) { a.hidden = true; });
  }

  // ---- Mascota -----------------------------------------------------------
  var mascota = document.querySelector('.escena .mascota');
  var globo = document.querySelector('.globo');
  var frases = [
    '¡Hola! Soy Jaguar.',
    'Los errores no muerden.',
    '¿Ya hiciste tu prueba de escritorio?',
    'Un paso a la vez.',
    'Pista: léelo en voz alta.',
    '¡A programar!'
  ];
  var k = 0;
  if (mascota && globo) {
    var hablar = function () {
      k = (k + 1) % frases.length;
      globo.textContent = frases[k];
      globo.classList.remove('cambia');
      void globo.offsetWidth;
      globo.classList.add('cambia');
      mascota.classList.remove('salta');
      void mascota.offsetWidth;
      mascota.classList.add('salta');
      mascota.addEventListener('animationend', function fin(ev) {
        if (ev.animationName === 'salta') { mascota.classList.remove('salta'); mascota.removeEventListener('animationend', fin); }
      });
    };
    mascota.addEventListener('click', hablar);
    mascota.setAttribute('role', 'button');
    mascota.setAttribute('tabindex', '0');
    mascota.setAttribute('aria-label', 'La mascota de Jaguar. Tócala para que te diga algo');
    mascota.addEventListener('keydown', function (e) { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); hablar(); } });
  }

  // ---- Aparecer al bajar -------------------------------------------------
  var vistos = document.querySelectorAll('.revela, .ruta');
  if ('IntersectionObserver' in window && !quieto) {
    var ob = new IntersectionObserver(function (items) {
      items.forEach(function (it) {
        if (it.isIntersecting) { it.target.classList.add('visto'); ob.unobserve(it.target); }
      });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.12 });
    vistos.forEach(function (el) { ob.observe(el); });
  } else {
    vistos.forEach(function (el) { el.classList.add('visto'); });
  }

  // ---- Lección de prueba -------------------------------------------------
  var raiz = document.getElementById('leccion');
  if (!raiz) return;
  var rombo = '<svg viewBox="0 0 56 36" aria-hidden="true"><path class="f" d="M28 3l24 15-24 15L4 18z"/></svg>';
  var caja = '<svg viewBox="0 0 56 36" aria-hidden="true"><rect class="f" x="5" y="6" width="46" height="24" rx="2"/></svg>';
  var capsula = '<svg viewBox="0 0 56 36" aria-hidden="true"><rect class="f" x="5" y="6" width="46" height="24" rx="12"/></svg>';
  var romboide = '<svg viewBox="0 0 56 36" aria-hidden="true"><path class="f" d="M14 6h38l-10 24H4z"/></svg>';
  var preguntas = [
    {
      t: 'Completa el programa para que salude por su nombre',
      codigo: 'Leer nombre\nEscribir "Hola, " <b class="hueco">__</b> nombre',
      ops: ['+', '-', '<-', 'Si'], bien: 0, relleno: '+',
      ok: '¡Correcto!', okx: 'Con + unes un texto con lo que guardaste en una variable.',
      mal: 'Casi.', malx: 'Para unir textos se usa +.'
    },
    {
      t: '¿Qué figura del diagrama de flujo es una decisión?',
      ops: [caja, rombo, capsula, romboide], etiquetas: ['Rectángulo', 'Rombo', 'Cápsula', 'Paralelogramo'], bien: 1, html: true,
      ok: '¡Eso es!', okx: 'El rombo hace una pregunta y tiene dos salidas: Sí y No.',
      mal: 'No es esa.', malx: 'La decisión es el rombo: pregunta algo y sale por Sí o por No.'
    },
    {
      t: 'Prueba de escritorio: ¿cuánto vale x al final?',
      codigo: 'x &lt;- 2\nx &lt;- x + 3\nEscribir x',
      ops: ['2', '3', '5', '23'], bien: 2,
      ok: '¡Perfecto!', okx: 'x empieza en 2 y luego se le suman 3: queda en 5.',
      mal: 'Casi.', malx: 'Primero x vale 2; la segunda línea le suma 3, y queda en 5.'
    }
  ];
  var n = 0, aciertos = 0, elegida = -1, revisada = false;
  var barra = raiz.querySelector('.progreso > i');
  var cuenta = raiz.querySelector('.leccion-barra b');
  var cuerpo = raiz.querySelector('.leccion-cuerpo');
  var pie = raiz.querySelector('.leccion-pie');
  var msg = pie.querySelector('.msg');
  var boton = pie.querySelector('.boton');
  var final = raiz.querySelector('.leccion-final');

  function pinta() {
    var q = preguntas[n];
    elegida = -1; revisada = false;
    cuerpo.hidden = false; pie.hidden = false; final.hidden = true;
    pie.className = 'leccion-pie';
    msg.textContent = '';
    boton.textContent = 'Comprobar';
    boton.disabled = true;
    cuenta.textContent = (n + 1) + ' de ' + preguntas.length;
    barra.style.width = (n / preguntas.length * 100) + '%';
    var h = '<h3 id="leccion-t">' + q.t + '</h3>';
    if (q.codigo) h += '<pre aria-label="Código del ejemplo">' + q.codigo.replace(/\n/g, '\n') + '</pre>';
    h += '<ul class="opciones">';
    q.ops.forEach(function (o, i) {
      var etiqueta = q.etiquetas ? ' aria-label="' + q.etiquetas[i] + '"' : '';
      h += '<li><button type="button" class="opcion" aria-pressed="false" data-i="' + i + '"' + etiqueta + '>' + (q.html ? o : '<code>' + o.replace(/</g, '&lt;') + '</code>') + '</button></li>';
    });
    cuerpo.innerHTML = h + '</ul>';
  }

  cuerpo.addEventListener('click', function (e) {
    var b = e.target.closest('.opcion');
    if (!b || revisada) return;
    elegida = +b.getAttribute('data-i');
    cuerpo.querySelectorAll('.opcion').forEach(function (x) { x.setAttribute('aria-pressed', x === b ? 'true' : 'false'); });
    boton.disabled = false;
  });

  boton.addEventListener('click', function () {
    var q = preguntas[n];
    if (!revisada) {
      revisada = true;
      var bien = elegida === q.bien;
      var ops = cuerpo.querySelectorAll('.opcion');
      ops.forEach(function (x, i) {
        x.disabled = true;
        if (i === q.bien) x.classList.add('correcta');
        else if (i === elegida) x.classList.add('incorrecta');
      });
      var hueco = cuerpo.querySelector('.hueco');
      if (hueco && q.relleno) { hueco.textContent = q.relleno; hueco.classList.add('lleno'); }
      if (bien) aciertos++;
      pie.className = 'leccion-pie ' + (bien ? 'bien' : 'mal');
      msg.innerHTML = (bien ? q.ok : q.mal) + '<small>' + (bien ? q.okx : q.malx) + '</small>';
      barra.style.width = ((n + 1) / preguntas.length * 100) + '%';
      boton.textContent = n === preguntas.length - 1 ? 'Terminar' : 'Continuar';
      boton.focus({ preventScroll: true });
      if (bien) confeti(boton);
      return;
    }
    n++;
    if (n < preguntas.length) { pinta(); return; }
    cuerpo.hidden = true; pie.hidden = true; final.hidden = false;
    raiz.querySelector('.final-nota').textContent = aciertos + ' de ' + preguntas.length;
    var t = final.querySelector('h3'); t.tabIndex = -1; t.focus({ preventScroll: true });
    if (aciertos > 1) confeti(final.querySelector('img'));
  });

  final.querySelector('[data-repetir]').addEventListener('click', function () { n = 0; aciertos = 0; pinta(); });
  pinta();
})();
