// Los textos de cada página de reto de la landing (sitio/retos/*.html): lo que
// no sale de los datos del reto sino de explicarlo. Lo usa tool/retos_html.dart.

class RetoTexto {
  const RetoTexto({
    required this.slug,
    required this.titulo,
    required this.descripcion,
    required this.h1,
    required this.resumen,
    required this.entrada,
    required this.proceso,
    required this.salida,
    required this.pensarlo,
    required this.errores,
    required this.preguntas,
    this.relacionados = const [],
  });

  /// Parte de la dirección: /retos/<slug>.
  final String slug;

  /// El título de la pestaña (hasta unos 60 caracteres) y la descripción (hasta unos 160).
  final String titulo;
  final String descripcion;
  final String h1;

  /// La frase bajo el título.
  final String resumen;

  /// El planteamiento: qué entra, qué se hace, qué sale.
  final String entrada;
  final String proceso;
  final String salida;

  /// Cómo se piensa, en párrafos.
  final List<String> pensarlo;

  /// Lo que más se confunde.
  final List<String> errores;
  final List<(String, String)> preguntas;

  /// Ids de otros retos para seguir.
  final List<String> relacionados;
}

const retosTexto = <String, RetoTexto>{
  'reto-1-01': RetoTexto(
    slug: 'algoritmo-para-saludar-por-su-nombre',
    titulo: 'Algoritmo para saludar por su nombre en pseudocódigo',
    descripcion:
        'Escribe un algoritmo que pida el nombre y salude: planteamiento, diagrama de flujo, pseudocódigo con Leer y Escribir, y el mismo programa en Python.',
    h1: 'Algoritmo que pide un nombre y saluda',
    resumen:
        'El primer programa que se hace en una materia de lógica: pedir un dato, guardarlo en una variable y usarlo en un mensaje.',
    entrada: 'El nombre de la persona (un texto).',
    proceso: 'Guardar el nombre en una variable.',
    salida: 'El mensaje Hola, seguido del nombre.',
    pensarlo: [
      'Un programa necesita dónde guardar lo que le escriben. Ese lugar es una variable: le pones un nombre, por ejemplo nombre, y la instrucción Leer la llena con lo que escribe la persona.',
      'Después, Escribir puede mostrar un texto fijo entre comillas y el valor de una variable en la misma línea. Se separan con comas, o se unen con el signo +.',
      'Como el dato es un nombre, la variable es de tipo Texto. Declararla con Definir es opcional en pseudocódigo, pero ayuda a ver qué guarda cada variable.',
    ],
    errores: [
      'Escribir "nombre" con comillas muestra la palabra nombre, no lo que guardó la variable.',
      'Olvidar el espacio después de la coma en el saludo: "Hola," pegaría el nombre al texto.',
      'Poner Escribir antes de Leer: el programa mostraría el saludo sin saber todavía el nombre.',
    ],
    preguntas: [
      (
        '¿Por qué no se pone el nombre entre comillas en Escribir?',
        'Porque entre comillas es un texto fijo que se muestra tal cual. Sin comillas, Jaguar busca la variable con ese nombre y muestra lo que guarda.',
      ),
      (
        '¿Hace falta Definir la variable?',
        'No. En el pseudocódigo que usa Jaguar se puede usar una variable sin declararla. Definir ayuda a dejar claro su tipo: Texto, Entero, Real o Lógico.',
      ),
    ],
    relacionados: ['reto-1-11', 'reto-1-02'],
  ),
  'reto-1-02': RetoTexto(
    slug: 'area-de-un-rectangulo-en-pseudocodigo',
    titulo: 'Área de un rectángulo en pseudocódigo (con diagrama)',
    descripcion:
        'Algoritmo para calcular el área de un rectángulo: lee la base y la altura, multiplica y muestra el resultado. Planteamiento, diagrama de flujo y pseudocódigo.',
    h1: 'Algoritmo para calcular el área de un rectángulo',
    resumen: 'Leer dos datos, hacer una operación y mostrar el resultado: la estructura de casi todos los primeros algoritmos.',
    entrada: 'La base y la altura del rectángulo (dos números).',
    proceso: 'Multiplicar la base por la altura.',
    salida: 'El texto Área: seguido del resultado.',
    pensarlo: [
      'El área de un rectángulo es base por altura. En pseudocódigo el asterisco * multiplica, y la flecha <- guarda el resultado en una variable: area <- base * altura.',
      'Leer puede pedir varios datos en una sola instrucción: Leer base, altura. La persona los escribe uno por uno y cada valor se guarda en su variable, en el mismo orden.',
      'Los números pueden traer decimales, como 2.5. No hace falta nada especial: el pseudocódigo trabaja con números enteros y reales sin que tengas que distinguirlos.',
    ],
    errores: [
      'Usar la letra x para multiplicar: en pseudocódigo se usa *.',
      'Mostrar la fórmula en lugar del resultado: Escribir "base * altura" muestra esas palabras, no la cuenta.',
      'Escribir los datos en el orden contrario al de Leer: la primera cifra es la base, la segunda la altura.',
    ],
    preguntas: [
      (
        '¿Cómo se multiplica en pseudocódigo?',
        'Con el asterisco *. La potencia se escribe con ^ y el residuo de una división con MOD.',
      ),
      (
        '¿Puedo usar decimales en la base y la altura?',
        'Sí. Con base 10 y altura 2.5 el programa muestra Área: 25, porque Jaguar trabaja con números reales sin que declares el tipo.',
      ),
    ],
    relacionados: ['reto-1-03', 'reto-1-04'],
  ),
  'reto-1-03': RetoTexto(
    slug: 'algoritmo-para-calcular-el-iva',
    titulo: 'Algoritmo para calcular el IVA en pseudocódigo',
    descripcion:
        'Algoritmo que lee el precio de un producto y muestra el total con IVA del 16 %: planteamiento, diagrama de flujo y pseudocódigo paso a paso, también en Python.',
    h1: 'Algoritmo para calcular el precio con IVA',
    resumen: 'Una constante, una expresión con dos operaciones y un resultado: cómo se pasa una fórmula del mundo real a pseudocódigo.',
    entrada: 'El precio del producto sin IVA.',
    proceso: 'Calcular el IVA (16 % del precio) y sumarlo al precio.',
    salida: 'El texto Total: seguido del precio con IVA.',
    pensarlo: [
      'El IVA del 16 % se calcula como precio por 0.16. El total es el precio más ese impuesto: total <- precio + precio * iva. La multiplicación se hace antes que la suma, igual que en matemáticas.',
      'Conviene guardar el 0.16 en una variable con nombre, iva <- 0.16, en lugar de repetir el número en la fórmula. Así, si el impuesto cambia, lo cambias en un solo lugar.',
      'Otra forma equivalente es multiplicar el precio por 1.16. Las dos dan el mismo resultado; la primera deja más claro qué se está sumando.',
    ],
    errores: [
      'Escribir el 16 como 16 y no como 0.16: el programa sumaría 16 veces el precio.',
      'Sumar el IVA solo, sin el precio: eso muestra el impuesto, no el total.',
      'Usar coma decimal (0,16): en pseudocódigo el separador decimal es el punto.',
    ],
    preguntas: [
      (
        '¿Cómo se calcula el IVA del 16 % en un algoritmo?',
        'Se multiplica el precio por 0.16 para obtener el impuesto y se suma al precio. También se puede multiplicar el precio por 1.16 para obtener el total directo.',
      ),
      (
        '¿Por qué conviene guardar el IVA en una variable?',
        'Porque el número queda con un nombre que explica qué es, y si el porcentaje cambia solo lo modificas en una línea.',
      ),
    ],
    relacionados: ['reto-1-02', 'reto-1-04'],
  ),
  'reto-1-04': RetoTexto(
    slug: 'convertir-minutos-a-horas-en-pseudocodigo',
    titulo: 'Convertir minutos a horas y minutos en pseudocódigo',
    descripcion:
        'Algoritmo que convierte minutos a horas y minutos con división entera y residuo (MOD): planteamiento, diagrama de flujo, pseudocódigo y Python.',
    h1: 'Algoritmo para convertir minutos a horas y minutos',
    resumen: 'La división entera y el residuo, dos operaciones que aparecen una y otra vez: horas completas y lo que sobra.',
    entrada: 'Una cantidad de minutos (un número entero).',
    proceso: 'Dividir entre 60 para obtener las horas completas y sacar el residuo para los minutos que sobran.',
    salida: 'El texto con las horas y los minutos, por ejemplo 2 horas y 5 minutos.',
    pensarlo: [
      'En 125 minutos caben 2 horas completas (120 minutos) y sobran 5. Las horas son la parte entera de 125 entre 60, y los minutos que sobran son el residuo de esa división.',
      'En pseudocódigo la parte entera se obtiene con Trunc(minutos / 60), y el residuo con el operador MOD: minutos MOD 60. MOD significa módulo: lo que queda al dividir.',
      'Con menos de 60 minutos, por ejemplo 59, las horas dan 0 y el residuo son los mismos 59 minutos. El programa funciona sin tratar ese caso aparte.',
    ],
    errores: [
      'Dividir con / y mostrar el resultado completo: 125 / 60 da 2.0833, no 2 horas y 5 minutos.',
      'Calcular los minutos como minutos - horas: hay que restar horas por 60, o usar MOD.',
      'Olvidar Trunc: sin él, las horas saldrían con decimales.',
    ],
    preguntas: [
      (
        '¿Qué hace MOD en pseudocódigo?',
        'Da el residuo de una división. Por ejemplo, 125 MOD 60 es 5, porque 125 entre 60 es 2 y sobran 5.',
      ),
      (
        '¿Cómo obtengo solo la parte entera de una división?',
        'Con la función Trunc, que corta los decimales: Trunc(125 / 60) es 2.',
      ),
    ],
    relacionados: ['reto-1-03', 'reto-1-05'],
  ),
  'reto-1-05': RetoTexto(
    slug: 'algoritmo-aprobado-o-reprobado',
    titulo: 'Algoritmo aprobado o reprobado en pseudocódigo',
    descripcion:
        'Algoritmo que lee una calificación y muestra Aprobado o Reprobado con Si, Entonces y SiNo: planteamiento, diagrama de flujo y pseudocódigo.',
    h1: 'Algoritmo que dice si una calificación aprueba',
    resumen: 'Tu primera decisión: el programa elige entre dos caminos según una condición.',
    entrada: 'Una calificación del 0 al 10.',
    proceso: 'Comparar la calificación con 6.',
    salida: 'Aprobado si es 6 o más; Reprobado si no.',
    pensarlo: [
      'Una decisión se escribe con Si, una condición y Entonces. Lo que va debajo se hace solo si la condición es verdadera. SiNo marca lo que se hace en caso contrario, y FinSi cierra el bloque.',
      'La condición es calificacion >= 6. El signo >= significa mayor o igual: con un 6 exacto la condición se cumple y la persona aprueba. Con 5.9 no.',
      'En el diagrama de flujo, la decisión es un rombo con dos salidas, Sí y No. Cada salida lleva a su propio mensaje y las dos se juntan antes del final.',
    ],
    errores: [
      'Usar > en lugar de >=: con 6 saldría Reprobado, y el 6 sí aprueba.',
      'Olvidar FinSi: el programa no sabe dónde termina la decisión y marca error.',
      'Usar = para asignar dentro de la condición: para comparar se usa =, y para guardar se usa <-.',
    ],
    preguntas: [
      (
        '¿Cuál es la diferencia entre > y >=?',
        '> es mayor que, y no incluye el valor. >= es mayor o igual, e incluye el valor. Con el 6 exacto, solo >= aprueba.',
      ),
      (
        '¿Cómo se dibuja un Si en un diagrama de flujo?',
        'Con un rombo que lleva la condición y dos salidas, Sí y No. Cada salida sigue su camino y los dos caminos se vuelven a juntar.',
      ),
    ],
    relacionados: ['reto-1-06', 'reto-1-07'],
  ),
  'reto-1-06': RetoTexto(
    slug: 'numero-dentro-de-un-rango-en-pseudocodigo',
    titulo: 'Número dentro de un rango en pseudocódigo: Si con Y',
    descripcion:
        'Algoritmo que dice si un número está entre 1 y 10 usando el operador lógico Y: planteamiento, diagrama, pseudocódigo y los casos de borde.',
    h1: 'Algoritmo que revisa si un número está en un rango',
    resumen: 'Dos condiciones que se cumplen a la vez: el operador Y y los valores de borde, donde más se equivoca la gente.',
    entrada: 'Un número.',
    proceso: 'Comprobar que sea mayor o igual a 1 y menor o igual a 10.',
    salida: 'Dentro si está en el rango (incluidos 1 y 10); Fuera si no.',
    pensarlo: [
      'Estar entre 1 y 10 son dos condiciones juntas: que sea mayor o igual a 1 y que sea menor o igual a 10. Se unen con el operador lógico Y, que solo da verdadero si ambas lo son.',
      'La condición queda: n >= 1 Y n <= 10. No se puede escribir como 1 <= n <= 10: en pseudocódigo cada comparación va por separado.',
      'Los bordes son el 1 y el 10: ambos cuentan como dentro, por eso se usan >= y <=. Por eso este reto se prueba con 0, 1, 10 y 11, que son los valores donde un error de signo se nota.',
    ],
    errores: [
      'Escribir n > 1 Y n <= 10: el 1 saldría como Fuera.',
      'Usar O en lugar de Y: con O, casi cualquier número cumpliría alguna de las dos condiciones.',
      'Encadenar comparaciones como en matemáticas (1 <= n <= 10): no funciona, hay que separarlas con Y.',
    ],
    preguntas: [
      (
        '¿Qué hace el operador Y en una condición?',
        'Une dos condiciones y da verdadero solo cuando las dos se cumplen. El operador O, en cambio, da verdadero si se cumple al menos una.',
      ),
      (
        '¿Por qué importan tanto los valores de borde?',
        'Porque es donde se equivocan los signos > y >=. Un buen programa se prueba con los valores justo en el límite y uno antes y uno después.',
      ),
    ],
    relacionados: ['reto-1-05', 'reto-1-07'],
  ),
  'reto-1-07': RetoTexto(
    slug: 'dia-de-la-semana-con-segun-en-pseudocodigo',
    titulo: 'Día de la semana con Según en pseudocódigo',
    descripcion:
        'Algoritmo que muestra el día de la semana a partir de un número del 1 al 7 con la estructura Según: pseudocódigo, diagrama y el caso De Otro Modo.',
    h1: 'Algoritmo que convierte un número en un día de la semana',
    resumen: 'La estructura Según elige entre muchas opciones sin escribir un Si detrás de otro.',
    entrada: 'Un número.',
    proceso: 'Buscar a qué día corresponde: 1 es Lunes, 2 Martes… 7 Domingo.',
    salida: 'El nombre del día, o No existe si el número no está entre 1 y 7.',
    pensarlo: [
      'Cuando hay muchas opciones para un mismo valor, Según es más claro que una cadena de Si. Escribes Segun dia Hacer y, debajo, un renglón por cada valor: 1: Escribir "Lunes".',
      'La opción De Otro Modo recoge todo lo que no coincide con ninguno de los casos. Aquí sirve para el 0, el 9 o cualquier número fuera de 1 a 7: muestra No existe.',
      'La estructura se cierra con FinSegun. En el diagrama de flujo, Según se dibuja como una decisión con varias salidas, una por caso.',
    ],
    errores: [
      'Olvidar De Otro Modo: con un 9 el programa no mostraría nada.',
      'Escribir los casos con comillas ("1"): son números, no texto.',
      'Olvidar FinSegun al final.',
    ],
    preguntas: [
      (
        '¿Cuándo conviene usar Según en lugar de Si?',
        'Cuando comparas la misma variable con varios valores concretos, como los días de la semana. Es más corto y más fácil de leer que varios Si anidados.',
      ),
      (
        '¿Para qué sirve De Otro Modo?',
        'Es el caso por omisión: se ejecuta cuando el valor no coincide con ninguno de los anteriores.',
      ),
    ],
    relacionados: ['reto-1-05', 'reto-1-06'],
  ),
  'reto-1-08': RetoTexto(
    slug: 'suma-de-numeros-hasta-el-cero-pseudocodigo',
    titulo: 'Suma de números hasta que escriban cero (Mientras)',
    descripcion:
        'Algoritmo que suma números hasta que se escribe 0 con el ciclo Mientras: acumulador, valor centinela, diagrama de flujo y pseudocódigo.',
    h1: 'Algoritmo que suma números hasta que escriben cero',
    resumen: 'Un ciclo que no sabe cuántas veces se repetirá: el acumulador y el valor que avisa que ya hay que parar.',
    entrada: 'Una lista de números, que termina cuando se escribe 0.',
    proceso: 'Ir sumando cada número a un acumulador mientras no sea 0.',
    salida: 'El texto Suma: seguido del total.',
    pensarlo: [
      'No sabes de antemano cuántos números van a escribir, así que no sirve un ciclo que cuente. Se usa Mientras: se repite mientras la condición sea verdadera, y se revisa antes de cada vuelta.',
      'La suma empieza en 0 antes del ciclo: es el acumulador. Cada vuelta le suma el número leído. El 0 que escriben al final es el valor centinela: avisa que se acabó y no se suma.',
      'El truco es leer un número antes del ciclo y otro al final de cada vuelta. Así, la condición n <> 0 siempre revisa el número más reciente. Si el primero ya es 0, el ciclo no se ejecuta y la suma queda en 0.',
    ],
    errores: [
      'No leer el siguiente número dentro del ciclo: el programa repetiría el mismo número para siempre (ciclo infinito).',
      'Empezar la suma sin inicializarla en 0: la variable no tendría valor al sumar.',
      'Leer solo dentro del ciclo y no antes: la condición se revisaría con una variable vacía.',
    ],
    preguntas: [
      (
        '¿Qué es un valor centinela?',
        'Es un valor especial que marca el final de los datos. Aquí es el 0: cuando se escribe, el ciclo termina y no se suma.',
      ),
      (
        '¿Cuál es la diferencia entre Mientras y Para?',
        'Para se usa cuando sabes cuántas vueltas dar. Mientras repite hasta que una condición deje de cumplirse, sin saber cuántas serán.',
      ),
    ],
    relacionados: ['reto-1-09', 'reto-1-10'],
  ),
  'reto-1-09': RetoTexto(
    slug: 'tabla-de-multiplicar-en-pseudocodigo',
    titulo: 'Tabla de multiplicar en pseudocódigo con Para',
    descripcion:
        'Algoritmo que muestra la tabla de multiplicar de un número del 1 al 10 con el ciclo Para: pseudocódigo, diagrama de flujo y el mismo programa en Python.',
    h1: 'Algoritmo para mostrar la tabla de multiplicar',
    resumen: 'El ciclo Para cuenta por ti: una variable que va de 1 a 10 y repite lo mismo en cada vuelta.',
    entrada: 'Un número.',
    proceso: 'Repetir 10 veces, multiplicando el número por 1, por 2… por 10.',
    salida: 'Diez renglones con la forma 3 x 1 = 3.',
    pensarlo: [
      'Sabes exactamente cuántas veces repetir: diez. Para esos casos está el ciclo Para: Para i <- 1 Hasta 10 Hacer. La variable i vale 1 en la primera vuelta, 2 en la segunda, y así hasta 10.',
      'Dentro del ciclo, un solo Escribir arma cada renglón: el número, el texto " x ", el valor de i, el texto " = " y el resultado de multiplicar. Los textos van entre comillas y se separan con comas.',
      'FinPara cierra el ciclo. No hace falta sumar a i ni revisar nada: el ciclo Para se encarga de contar y de parar.',
    ],
    errores: [
      'Poner el Escribir fuera del ciclo: mostraría un solo renglón.',
      'Olvidar los espacios dentro de las comillas: " x " con espacios evita que salga 3x1=3.',
      'Modificar i dentro del ciclo: Para ya la cambia sola en cada vuelta.',
    ],
    preguntas: [
      (
        '¿Cuándo se usa el ciclo Para?',
        'Cuando sabes cuántas veces repetir, como diez vueltas para una tabla. Si no lo sabes, se usa Mientras o Repetir.',
      ),
      (
        '¿Puedo contar de dos en dos o hacia atrás?',
        'Sí, con Con Paso: Para i <- 10 Hasta 1 Con Paso -1 cuenta hacia atrás. Si el inicio es mayor que el final y no pones paso, Jaguar cuenta hacia atrás solo.',
      ),
    ],
    relacionados: ['reto-1-08', 'reto-1-10'],
  ),
  'reto-1-10': RetoTexto(
    slug: 'algoritmo-de-contrasena-con-repetir',
    titulo: 'Algoritmo de contraseña con Repetir y contador',
    descripcion:
        'Algoritmo que pide una contraseña hasta que escriban la correcta y cuenta los intentos con Repetir… Hasta Que: pseudocódigo, diagrama y Python.',
    h1: 'Algoritmo que pide una contraseña y cuenta los intentos',
    resumen: 'Repetir se ejecuta al menos una vez: ideal cuando primero hay que pedir el dato y luego revisarlo.',
    entrada: 'Contraseñas que se van escribiendo, hasta que se escribe jaguar.',
    proceso: 'Pedir la clave y contar cada intento, hasta que la clave sea jaguar.',
    salida: 'El texto Entraste en, el número de intentos y la palabra intentos.',
    pensarlo: [
      'Siempre se pide la contraseña al menos una vez, y solo después se revisa si era la correcta. Para eso existe Repetir… Hasta Que: ejecuta el bloque primero y revisa la condición al final.',
      'Un contador empieza en 0 y sube de 1 en 1 cada vez que se pide la clave: intentos <- intentos + 1. Al salir del ciclo, el contador dice cuántos intentos fueron.',
      'La condición de salida es clave = "jaguar". El ciclo se repite mientras no se cumpla y termina en cuanto sea verdadera. La clave se define como Texto.',
    ],
    errores: [
      'Usar Mientras sin leer antes la clave: la condición se revisaría con la variable vacía.',
      'Poner el contador fuera del ciclo: contaría una sola vez.',
      'Escribir "Jaguar" con mayúscula en la condición: el texto se compara tal cual, y jaguar no es igual a Jaguar.',
    ],
    preguntas: [
      (
        '¿En qué se diferencia Repetir de Mientras?',
        'Repetir ejecuta el bloque al menos una vez y revisa la condición al final. Mientras revisa la condición antes de cada vuelta y puede no ejecutarse ninguna.',
      ),
      (
        '¿Qué es un contador?',
        'Una variable que empieza en 0 y sube de 1 en 1 cada vez que algo ocurre, para saber cuántas veces pasó.',
      ),
    ],
    relacionados: ['reto-1-08', 'reto-1-09'],
  ),
  'reto-1-11': RetoTexto(
    slug: 'convertir-texto-a-mayusculas-pseudocodigo',
    titulo: 'Convertir texto a mayúsculas en pseudocódigo',
    descripcion:
        'Algoritmo que convierte un texto a mayúsculas y le agrega un signo de admiración con la función Mayusculas y el operador +: pseudocódigo y Python.',
    h1: 'Algoritmo que pasa un texto a mayúsculas',
    resumen: 'Funciones y texto: Mayusculas cambia las letras y el signo + junta textos.',
    entrada: 'Una palabra o una frase.',
    proceso: 'Pasar el texto a mayúsculas y agregarle un signo de admiración al final.',
    salida: 'El texto en mayúsculas seguido de !.',
    pensarlo: [
      'Mayusculas es una función: recibe un texto entre paréntesis y devuelve ese mismo texto con todas las letras en mayúsculas. Mayusculas("hola") da "HOLA".',
      'Para agregar el signo de admiración se unen dos textos con +. Escribir Mayusculas(texto) + "!" muestra el texto grande y el signo pegado al final.',
      'La variable se define como Texto porque guarda lo que escribe la persona, que puede ser una palabra o una frase con espacios y acentos.',
    ],
    errores: [
      'Escribir Mayusculas(texto) sin pasarle la variable entre paréntesis.',
      'Olvidar las comillas en el signo: ! sin comillas no es un texto.',
      'Usar coma en lugar de +: con coma el signo también sale, pero son dos valores distintos del mismo Escribir.',
    ],
    preguntas: [
      (
        '¿Cómo paso un texto a mayúsculas en pseudocódigo?',
        'Con la función Mayusculas: Mayusculas(texto) devuelve el texto con todas las letras en mayúsculas. Minusculas hace lo contrario.',
      ),
      (
        '¿Cómo junto dos textos?',
        'Con el signo +. Escribir "Hola, " + nombre une el saludo con el contenido de la variable.',
      ),
    ],
    relacionados: ['reto-1-12', 'reto-1-01'],
  ),
  'reto-1-12': RetoTexto(
    slug: 'contar-letras-de-una-palabra-pseudocodigo',
    titulo: 'Contar las letras de una palabra en pseudocódigo',
    descripcion:
        'Algoritmo que cuenta cuántas letras tiene una palabra con la función Longitud: planteamiento, diagrama de flujo, pseudocódigo y el equivalente en Python.',
    h1: 'Algoritmo que cuenta las letras de una palabra',
    resumen: 'La función Longitud mide un texto: cuántos caracteres tiene, espacios incluidos.',
    entrada: 'Una palabra.',
    proceso: 'Medir cuántas letras tiene con la función Longitud.',
    salida: 'El texto Letras: seguido del número.',
    pensarlo: [
      'Longitud es una función que recibe un texto y devuelve cuántos caracteres tiene. Longitud("jaguar") es 6.',
      'Se usa dentro de Escribir, junto con el texto fijo: Escribir "Letras: ", Longitud(palabra). Lo que devuelve la función se muestra como cualquier otro valor.',
      'Con una sola letra, como "a", la longitud es 1. Un texto vacío tendría longitud 0.',
    ],
    errores: [
      'Escribir Longitud sin paréntesis ni la variable: las funciones llevan sus datos entre paréntesis.',
      'Pensar que cuenta solo letras: también cuenta espacios y signos.',
      'Poner la variable entre comillas: Longitud("palabra") cuenta las letras de la palabra palabra, que son 7.',
    ],
    preguntas: [
      (
        '¿Cómo sé cuántas letras tiene un texto?',
        'Con la función Longitud: Longitud("jaguar") devuelve 6. Cuenta todos los caracteres, incluidos los espacios.',
      ),
      (
        '¿Qué diferencia hay entre Longitud(palabra) y Longitud("palabra")?',
        'Sin comillas se mide lo que guarda la variable palabra. Con comillas se mide el texto fijo "palabra", que siempre mide 7.',
      ),
    ],
    relacionados: ['reto-1-11', 'reto-1-01'],
  ),
};
