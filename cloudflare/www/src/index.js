// Lleva cualquier ruta de www.jaguarcode.org a la misma ruta del dominio sin www.
export default {
  fetch(request) {
    const url = new URL(request.url);
    url.hostname = 'jaguarcode.org';
    return Response.redirect(url.toString(), 301);
  },
};
