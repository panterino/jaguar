// El generador de diagramas de flujo de la página. El núcleo (el mismo motor
// de la app, compilado a JavaScript) se descarga la primera vez que se usa;
// todo corre en el navegador y nada se envía a ningún servidor.
(function () {
  var fuente = document.getElementById('fuente');
  var ejemplo = document.getElementById('ejemplo');
  var salida = document.getElementById('diagrama-salida');
  var estado = document.getElementById('estado-herramienta');
  var bajarSvg = document.getElementById('bajar-svg');
  var bajarPng = document.getElementById('bajar-png');
  var datos = document.getElementById('ejemplos-datos');
  if (!fuente || !salida) return;

  var ejemplos = datos ? JSON.parse(datos.textContent) : [];
  var cargando = null;
  var ultimo = null; // el último diagrama bueno: se queda mientras el código tiene un error
  var espera = null;

  function cargar() {
    if (window.jaguarDiagrama) return Promise.resolve();
    if (cargando) return cargando;
    cargando = new Promise(function (ok, fallo) {
      var s = document.createElement('script');
      s.src = '/herramientas/diagrama-nucleo.js';
      s.onload = ok;
      s.onerror = function () {
        cargando = null;
        fallo(new Error('No se pudo cargar'));
      };
      document.head.appendChild(s);
    });
    return cargando;
  }

  function aviso(error) {
    var caja = document.createElement('div');
    caja.className = 'aviso-error';
    caja.setAttribute('role', 'alert');
    var t = document.createElement('b');
    t.textContent = error.title + ' en la línea ' + error.line;
    caja.appendChild(t);
    caja.appendChild(document.createElement('br'));
    caja.appendChild(document.createTextNode(error.message + (error.hint ? ' ' + error.hint : '')));
    return caja;
  }

  function dibujar(r) {
    salida.textContent = '';
    if (r.error) {
      salida.appendChild(aviso(r.error));
      if (!ultimo) return;
      var nota = document.createElement('p');
      nota.className = 'nota-tabla';
      nota.textContent = 'Mientras tanto ves el último diagrama que se pudo dibujar.';
      salida.appendChild(nota);
      r = ultimo;
    } else {
      ultimo = r;
    }
    r.diagramas.forEach(function (d, i) {
      var figura = document.createElement('figure');
      figura.className = 'diagrama';
      figura.style.margin = i ? '18px 0 0' : '0';
      if (r.diagramas.length > 1) {
        var cap = document.createElement('figcaption');
        cap.className = 'nota-tabla';
        cap.textContent = d.titulo;
        figura.appendChild(cap);
      }
      // El SVG lo arma el núcleo a partir del código: no lleva texto de la persona sin escapar.
      figura.insertAdjacentHTML('beforeend', d.svg);
      salida.appendChild(figura);
    });
    var vacio = !r.diagramas.length;
    bajarSvg.disabled = vacio;
    bajarPng.disabled = vacio;
  }

  function actualizar() {
    estado.textContent = 'Dibujando…';
    cargar()
      .then(function () {
        var r = JSON.parse(window.jaguarDiagrama(fuente.value));
        dibujar(r);
        estado.textContent = r.error ? 'El programa tiene un error: revisa el aviso.' : 'Listo.';
      })
      .catch(function () {
        estado.textContent = 'No se pudo cargar la herramienta. Revisa tu conexión e inténtalo de nuevo.';
      });
  }

  function nombreArchivo(extension) {
    var m = /\b(?:algoritmo|proceso)\s+([\wÁÉÍÓÚÜÑáéíóúüñ]+)/i.exec(fuente.value);
    return 'diagrama-' + (m ? m[1].toLowerCase() : 'programa') + '.' + extension;
  }

  function descargar(blob, nombre) {
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = nombre;
    document.body.appendChild(a);
    a.click();
    setTimeout(function () {
      URL.revokeObjectURL(a.href);
      a.remove();
    }, 1000);
  }

  bajarSvg.addEventListener('click', function () {
    if (!ultimo || !ultimo.diagramas.length) return;
    descargar(new Blob([ultimo.diagramas[0].archivo], { type: 'image/svg+xml' }), nombreArchivo('svg'));
  });

  bajarPng.addEventListener('click', function () {
    if (!ultimo || !ultimo.diagramas.length) return;
    var d = ultimo.diagramas[0];
    var imagen = new Image();
    imagen.onload = function () {
      var escala = 2;
      var lienzo = document.createElement('canvas');
      lienzo.width = Math.round(d.ancho * escala);
      lienzo.height = Math.round(d.alto * escala);
      var c = lienzo.getContext('2d');
      c.fillStyle = '#FFFBF6';
      c.fillRect(0, 0, lienzo.width, lienzo.height);
      c.drawImage(imagen, 0, 0, lienzo.width, lienzo.height);
      lienzo.toBlob(function (blob) {
        if (blob) descargar(blob, nombreArchivo('png'));
      }, 'image/png');
    };
    imagen.src = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(d.archivo);
  });

  fuente.addEventListener('input', function () {
    clearTimeout(espera);
    espera = setTimeout(actualizar, 350);
  });
  fuente.addEventListener('focus', cargar, { once: true });
  if (ejemplo) {
    ejemplo.addEventListener('change', function () {
      var e = ejemplos[Number(ejemplo.value)];
      if (!e) return;
      fuente.value = e.fuente;
      actualizar();
    });
  }
  // Se dibuja el ejemplo al abrir la página, para que el diagrama sea el de este código.
  actualizar();
})();
