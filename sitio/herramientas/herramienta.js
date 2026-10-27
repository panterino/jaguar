// La herramienta de prueba de escritorio de la página. El núcleo (el mismo
// intérprete de la app, compilado a JavaScript) se descarga la primera vez que
// se usa; todo corre en el navegador y nada se envía a ningún servidor.
(function () {
  var fuente = document.getElementById('fuente');
  var entradas = document.getElementById('entradas');
  var boton = document.getElementById('generar');
  var ejemplo = document.getElementById('ejemplo');
  var salida = document.getElementById('resultado');
  var estado = document.getElementById('estado-herramienta');
  var datos = document.getElementById('ejemplos-datos');
  if (!fuente || !boton || !salida) return;

  var ejemplos = datos ? JSON.parse(datos.textContent) : [];
  var cargando = null;

  function cargar() {
    if (window.jaguarPruebaDeEscritorio) return Promise.resolve();
    if (cargando) return cargando;
    cargando = new Promise(function (ok, fallo) {
      var s = document.createElement('script');
      s.src = '/herramientas/prueba-nucleo.js';
      s.onload = ok;
      s.onerror = function () {
        cargando = null;
        fallo(new Error('No se pudo cargar'));
      };
      document.head.appendChild(s);
    });
    return cargando;
  }

  function celda(tipo, texto, clase) {
    var c = document.createElement(tipo);
    c.textContent = texto;
    if (clase) c.className = clase;
    return c;
  }

  function dibujar(r) {
    salida.textContent = '';
    if (r.error) {
      var caja = document.createElement('div');
      caja.className = 'aviso-error';
      caja.setAttribute('role', 'alert');
      var t = document.createElement('b');
      t.textContent = r.error.title + ' en la línea ' + r.error.line;
      caja.appendChild(t);
      caja.appendChild(document.createElement('br'));
      caja.appendChild(document.createTextNode(r.error.message + (r.error.hint ? ' ' + r.error.hint : '')));
      salida.appendChild(caja);
    }
    if (!r.rows.length) {
      if (!r.error) salida.appendChild(document.createTextNode('El programa no ejecutó ninguna instrucción.'));
      return;
    }
    var envoltura = document.createElement('div');
    envoltura.className = 'tabla';
    var tabla = document.createElement('table');
    var cap = document.createElement('caption');
    cap.textContent = 'Prueba de escritorio: una fila por instrucción y una columna por variable';
    tabla.appendChild(cap);
    var cabeza = document.createElement('thead');
    var fila = document.createElement('tr');
    ['Paso', 'Línea', 'Instrucción'].concat(r.variables, ['Pantalla']).forEach(function (n) {
      var th = celda('th', n);
      th.scope = 'col';
      fila.appendChild(th);
    });
    cabeza.appendChild(fila);
    tabla.appendChild(cabeza);
    var cuerpo = document.createElement('tbody');
    r.rows.forEach(function (row, i) {
      var tr = document.createElement('tr');
      tr.appendChild(celda('td', String(i + 1)));
      tr.appendChild(celda('td', String(row.line)));
      tr.appendChild(celda('td', row.instruction, 'instr'));
      r.variables.forEach(function (v) {
        var ahora = row.values[v] === undefined ? '' : row.values[v];
        var antes = i > 0 && r.rows[i - 1].values[v] !== undefined ? r.rows[i - 1].values[v] : '';
        tr.appendChild(celda('td', ahora, ahora !== '' && ahora !== antes ? 'cambio' : ''));
      });
      tr.appendChild(celda('td', (row.output || '').replace(/\n$/, '')));
      cuerpo.appendChild(tr);
    });
    tabla.appendChild(cuerpo);
    envoltura.appendChild(tabla);
    salida.appendChild(envoltura);
    if (r.truncated) {
      var p = document.createElement('p');
      p.className = 'nota-tabla';
      p.textContent = 'El programa tarda más pasos de los que caben en la tabla: se muestran los primeros.';
      salida.appendChild(p);
    }
  }

  function generar() {
    estado.textContent = 'Generando…';
    boton.disabled = true;
    cargar()
      .then(function () {
        return window.jaguarPruebaDeEscritorio(fuente.value, entradas.value);
      })
      .then(function (json) {
        var r = JSON.parse(json);
        dibujar(r);
        estado.textContent = r.error
          ? 'El programa tiene un error: revisa el aviso.'
          : 'Listo: ' + r.rows.length + (r.rows.length === 1 ? ' fila.' : ' filas.');
      })
      .catch(function () {
        estado.textContent = 'No se pudo cargar la herramienta. Revisa tu conexión e inténtalo de nuevo.';
      })
      .then(function () {
        boton.disabled = false;
      });
  }

  boton.addEventListener('click', generar);
  if (ejemplo) {
    ejemplo.addEventListener('change', function () {
      var e = ejemplos[Number(ejemplo.value)];
      if (!e) return;
      fuente.value = e.fuente;
      entradas.value = e.entradas;
      generar();
    });
  }
  // Se descarga el núcleo en cuanto alguien toca el código, para que el botón responda al instante.
  [fuente, entradas].forEach(function (campo) {
    campo.addEventListener('focus', cargar, { once: true });
  });
})();
