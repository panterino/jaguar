// Medición de visitas con Google Analytics, solo si la persona acepta.
// Antes de aceptar no se carga nada de Google ni se guarda ninguna cookie.
// Este archivo es el mismo en la landing (sitio/) y en la app web
// (apps/jaguar/web/): una prueba revisa que sean idénticos.
(function () {
  'use strict';
  var ID = 'G-1T1QH5RR0E';
  var CLAVE = 'jaguar.analitica';
  var PRIVACIDAD = 'https://app.jaguarcode.org/privacidad.html';

  function leer() { try { return localStorage.getItem(CLAVE); } catch (e) { return null; } }
  function guardar(v) { try { localStorage.setItem(CLAVE, v); } catch (e) { /* sin almacenamiento */ } }

  // Quien pide que no lo midan desde su navegador (Global Privacy Control o No Rastrear) no ve el aviso.
  var noMedir = navigator.globalPrivacyControl === true || navigator.doNotTrack === '1' || window.doNotTrack === '1';

  var cargado = false;
  function cargar() {
    if (cargado) return;
    cargado = true;
    window['ga-disable-' + ID] = false;
    window.dataLayer = window.dataLayer || [];
    function gtag() { window.dataLayer.push(arguments); }
    gtag('consent', 'default', {
      analytics_storage: 'granted',
      ad_storage: 'denied',
      ad_user_data: 'denied',
      ad_personalization: 'denied'
    });
    gtag('js', new Date());
    gtag('config', ID, {
      anonymize_ip: true,
      allow_google_signals: false,
      allow_ad_personalization_signals: false
    });
    var s = document.createElement('script');
    s.async = true;
    s.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(ID);
    document.head.appendChild(s);
  }

  // Si antes se aceptó y ahora se rechaza: se detiene la medición y se borran las cookies de Google.
  function detener() {
    window['ga-disable-' + ID] = true;
    var partes = location.hostname.split('.');
    var dominios = [location.hostname, '.' + location.hostname];
    if (partes.length > 2) dominios.push('.' + partes.slice(-2).join('.'));
    document.cookie.split(';').forEach(function (c) {
      var nombre = c.split('=')[0].trim();
      if (nombre.indexOf('_ga') !== 0) return;
      dominios.forEach(function (d) {
        document.cookie = nombre + '=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/; domain=' + d;
      });
      document.cookie = nombre + '=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/';
    });
  }

  function cerrar() {
    var caja = document.getElementById('jaguar-analitica');
    if (caja) caja.remove();
  }

  function decidir(v) {
    guardar(v);
    cerrar();
    if (v === 'si') cargar(); else detener();
  }

  function aviso() {
    if (document.getElementById('jaguar-analitica')) return;
    var estilo = document.createElement('style');
    estilo.textContent =
      '#jaguar-analitica{position:fixed;left:12px;right:12px;bottom:12px;z-index:2147483000;max-width:560px;margin:0 auto;' +
      'background:#3B2410;color:#FFF3E0;border-radius:16px;padding:16px 18px;box-shadow:0 8px 30px rgba(0,0,0,.4);' +
      'font:15px/1.5 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}' +
      '#jaguar-analitica p{margin:0 0 12px}#jaguar-analitica a{color:#F4B723}' +
      '#jaguar-analitica .botones{display:flex;gap:10px}' +
      '#jaguar-analitica button{flex:1;font:inherit;font-weight:700;border:0;border-radius:999px;padding:11px 14px;cursor:pointer;' +
      'background:#FFF3E0;color:#3B2410}#jaguar-analitica button:focus-visible{outline:3px solid #00A8F0;outline-offset:2px}';
    var caja = document.createElement('div');
    caja.id = 'jaguar-analitica';
    caja.setAttribute('role', 'dialog');
    caja.setAttribute('aria-label', 'Medición de visitas');
    caja.innerHTML =
      '<p><b>¿Nos ayudas a mejorar?</b> Usamos Google Analytics para contar visitas y saber qué páginas sirven, ' +
      'sin anuncios y sin pedirte nombre ni correo. Puedes cambiar tu elección cuando quieras. ' +
      '<a href="' + PRIVACIDAD + '">Aviso de privacidad</a>.</p>' +
      '<div class="botones"><button type="button" data-v="si">Aceptar</button>' +
      '<button type="button" data-v="no">Rechazar</button></div>';
    caja.appendChild(estilo);
    caja.addEventListener('click', function (e) {
      var v = e.target && e.target.getAttribute && e.target.getAttribute('data-v');
      if (v) decidir(v);
    });
    document.body.appendChild(caja);
  }

  var eleccion = leer();
  if (noMedir && eleccion !== 'si') {
    // No se pregunta ni se mide.
  } else if (eleccion === 'si') {
    cargar();
  } else if (eleccion !== 'no') {
    if (document.body) aviso(); else document.addEventListener('DOMContentLoaded', aviso);
  }

  // Los enlaces "Cambiar mi elección de analítica" vuelven a mostrar el aviso.
  document.addEventListener('click', function (e) {
    var a = e.target && e.target.closest && e.target.closest('[data-analitica-cambiar]');
    if (!a) return;
    e.preventDefault();
    aviso();
  });
})();
