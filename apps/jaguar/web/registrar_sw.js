// Para abrir Jaguar Code sin internet después de la primera visita.
// Está en un archivo y no dentro de index.html para que la política de
// seguridad (CSP) no tenga que permitir scripts en línea.
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => navigator.serviceWorker.register('sw.js'));
}
