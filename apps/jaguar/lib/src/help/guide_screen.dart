import 'package:flutter/material.dart';

import '../settings.dart';
import '../share/scan_screen.dart';
import '../theme.dart';

/// Jaguar's guide, inside the app so it works without internet. One tab for
/// students and one for teachers; it opens on the tab of the chosen
/// profile. Each topic explains how it's done on this device (phone or
/// computer) and, when it can, takes you there.
class GuideScreen extends StatelessWidget {
  const GuideScreen({
    super.key,
    this.teacher = false,
    this.onOpenChallenges,
    this.onDeskCheck,
    this.onPlan,
    this.onOpenClasses,
    this.onOpenTeacher,
    this.onScan,
  });

  /// Opens on the Profe tab.
  final bool teacher;
  final VoidCallback? onOpenChallenges;
  final VoidCallback? onDeskCheck;
  final VoidCallback? onPlan;
  final VoidCallback? onOpenClasses;
  final VoidCallback? onOpenTeacher;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final desktop = useDesktopLayout(context);
    // The guide closes and then the action runs, on the main screen.
    VoidCallback? go(VoidCallback? action) => action == null
        ? null
        : () {
            Navigator.pop(context);
            action();
          };

    return DefaultTabController(
      length: 2,
      initialIndex: teacher ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guía de Jaguar Code'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.backpack_outlined), text: 'Alumno'),
              Tab(icon: Icon(Icons.school_outlined), text: 'Profe'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Page(
              greeting: desktop
                  ? '¡Hola! Aquí está lo que puedes hacer en Jaguar Code. Toca un tema para ver cómo se hace en la computadora.'
                  : '¡Hola! Aquí está lo que puedes hacer en Jaguar Code. Toca un tema para ver cómo se hace en tu celular.',
              topics: _studentTopics(desktop: desktop, go: go),
              extra: [
                const _Heading('Si algo no sale'),
                for (final (q, a) in _problems(desktop: desktop)) _Problem(question: q, answer: a),
                if (desktop) ...[const _Heading('Atajos de teclado'), const _Shortcuts()],
              ],
            ),
            _Page(
              greeting:
                  'Jaguar es una herramienta: tú pones los ejercicios, el ritmo y la calificación. '
                  'Así lo usas con tu grupo.',
              topics: _teacherTopics(desktop: desktop, go: go),
              extra: const [
                SizedBox(height: 8),
                _Note(
                  'Tus alumnos ven su propia guía en la pestaña Alumno. Si quieres explicarles algo, '
                  'ábrela con ellos en el proyector.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_Topic> _studentTopics({required bool desktop, required VoidCallback? Function(VoidCallback?) go}) => [
    _Topic(
      icon: Icons.play_arrow_rounded,
      title: 'Tu primer programa',
      summary: 'Elige cómo empezar, escribe y ejecuta',
      initiallyOpen: true,
      intro:
          'Al abrir Jaguar por primera vez te pregunta cómo quieres empezar. "Empezar desde cero" te lleva al '
          'Reto 1 con una introducción de cuatro pantallas y tres globos que te enseñan dónde escribir, cómo '
          'ejecutar y dónde están las pruebas. "Ya sé algo de programar" abre un programa listo para ejecutar.',
      shots: const [
        _Shot('bienvenida', 'Lo primero que ves al abrir Jaguar.'),
        _Shot('intro', 'Cuatro ideas con ejemplos, antes del primer reto.'),
        _Shot('reto-inicio', 'El Reto 1 con su primer globo.'),
      ],
      steps: [
        'Escribe entre Algoritmo y FinAlgoritmo: Escribir muestra, Leer pregunta, Si decide y Mientras repite. '
            'Al escribir, Jaguar cierra solo los paréntesis, las comillas y los bloques como FinSi.',
        desktop
            ? 'Presiona Ejecutar en la barra (${shortcutLabel('Enter')} o F9). La consola está debajo del código. '
                  'Para detener: Shift+F9.'
            : 'Toca el botón redondo con un triángulo, arriba a la derecha. Jaguar pasa solo a la pestaña Consola. Mientras '
                  'el programa corre, el botón se pone rojo y sirve para detenerlo.',
        'Si tu programa usa Leer, la consola dice "El programa espera un dato". Escríbelo abajo y presiona '
            'Enter o la flecha de enviar. Lo que escribiste aparece en azul.',
        'La primera vez que un programa tuyo corre sin error, Jaguar lo celebra.',
      ],
      moreShots: const [
        _Shot('codigo', 'El código y la barra de teclas.'),
        _Shot('consola-leer', 'La consola espera un dato.'),
        _Shot('primer-programa', 'Tu primer programa corrió.'),
      ],
      note:
          'Para unir un texto con una variable usa +: Escribir "Hola, " + nombre. También sirven las comas: '
          'Escribir "Hola, ", nombre.',
    ),
    if (!desktop)
      const _Topic(
        icon: Icons.keyboard_alt_outlined,
        title: 'La barra de teclas',
        summary: 'Lo que cuesta escribir en el celular',
        intro:
            'Debajo del código hay una barra con lo que más cuesta escribir en el teclado del celular: <-, '
            'comillas, paréntesis, corchetes, =, <, >, operadores, Y, O, NO, MOD y palabras como Escribir, Leer, '
            'Definir, Si, Para, Mientras, Repetir y Segun.',
        steps: [
          'Desliza la barra hacia un lado para ver más teclas.',
          'Las palabras de bloque escriben todo el bloque. Por ejemplo, Si pone Si … Entonces y su FinSi, con '
              'el cursor donde va la condición.',
          'Las flechas ‹ › mueven el cursor y ⇥ agrega sangría.',
        ],
        shots: [_Shot('codigo', 'La barra de teclas, bajo el código.')],
      ),
    _Topic(
      icon: Icons.account_tree_outlined,
      title: 'Código y diagrama',
      summary: 'El mismo programa, de dos formas',
      intro: 'El pseudocódigo y el diagrama de flujo son el mismo programa: lo que cambias en uno aparece en el otro.',
      shots: [
        _Shot('diagrama', 'La vista Diagrama, con su primera ayuda.'),
        if (desktop) const _Shot('computadora', 'En la computadora, con Ambos: código, diagrama y consola.'),
      ],
      steps: [
        desktop
            ? 'En la barra de arriba hay tres botones: Código, Diagrama y Ambos. Con Ambos ves el código y el '
                  'diagrama lado a lado. Atajos: ${shortcutLabel('Alt+1')}, 2 y 3.'
            : 'Debajo de la barra de arriba está el selector Código | Diagrama. Tócalo para cambiar entre las '
                  'dos formas. La pestaña de abajo siempre dice Programa.',
        'Toca un bloque del diagrama para ver su línea en el código.',
        'Si el código tiene un error, el diagrama conserva el último válido y te dice en qué línea corregir.',
      ],
    ),
    _Topic(
      icon: Icons.draw_outlined,
      title: 'Dibuja tu diagrama',
      summary: 'Programa con figuras, sin escribir',
      intro:
          'Arriba del diagrama está la paleta de figuras: Asignación, Lectura, Salida, Decisión, Ciclo Mientras, '
          'Ciclo Para, Repetir, Según y Llamada.',
      steps: [
        'Elige una figura de la paleta.',
        'Toca un ＋ en una flecha del diagrama, donde quieres que vaya.',
        'Llena lo que pide (por ejemplo, la variable a leer) y toca Agregar. En Salida puedes unir texto y '
            'variables con +: "Hola " + nombre.',
        desktop
            ? 'Doble clic en una figura para editarla; clic derecho para editar o eliminar.'
            : 'Mantén presionada una figura para editarla o eliminarla. Acerca o aleja con dos dedos.',
        'Si te equivocas, usa Deshacer en la barra de abajo del diagrama. Ahí mismo guardas el diagrama como imagen.',
      ],
      shots: const [_Shot('diagrama', 'Elegiste una figura: ahora toca un ＋.')],
    ),
    _Topic(
      icon: Icons.error_outline,
      title: 'Cuando hay un error',
      summary: 'Jaguar te dice dónde y cómo arreglarlo',
      intro:
          'Los errores están en español, te dicen en qué línea están y cómo arreglarlos. Mientras escribes '
          'Jaguar espera: una línea a medias o un bloque sin cerrar todavía no es un error.',
      steps: [
        desktop
            ? 'Cuando terminas la línea, se subraya en rojo y la explicación aparece al final de esa línea. '
                  'En la barra de abajo ves cuántos problemas hay.'
            : 'Cuando terminas la línea, se subraya en rojo y el error aparece completo en una franja roja debajo '
                  'del código. Tócala y Jaguar te lleva a esa línea.',
        'Si el error pasa al ejecutar, la consola lo muestra con un botón Ir a la línea.',
        'Primero ve el número de línea. Luego lee la sugerencia: casi siempre trae el código ya corregido, '
            'como en la captura, donde falta poner el texto entre comillas.',
      ],
      shots: const [_Shot('error', 'El error con su sugerencia, debajo del código.')],
    ),
    _Topic(
      icon: Icons.bolt_outlined,
      title: 'Lecciones cortas',
      summary: 'Preguntas rápidas con explicación, antes de cada reto',
      intro:
          'La Ruta tiene seis lecciones de cinco preguntas cada una: qué es un programa, operaciones, diagramas de '
          'flujo, decisiones, prueba de escritorio y ciclos. Duran un par de minutos y funcionan sin internet.',
      steps: [
        desktop
            ? 'Haz clic en Ruta en la barra de la izquierda y elige una lección.'
            : 'Abre la sala Ruta (abajo) y toca una lección. La siguiente también aparece en Inicio.',
        'Cada pregunta tiene una respuesta: elige una opción, ordena líneas de un programa o escoge una figura '
            'del diagrama de flujo. Toca Comprobar.',
        'Verde dice por qué estaba bien. Si fallas, la explicación te dice la respuesta y la pregunta vuelve al '
            'final para que la repitas una vez.',
        'Al terminar ves cuántas acertaste a la primera. La lección queda marcada y Seguir te lleva al paso '
            'siguiente de la ruta.',
        'No hay vidas ni castigos: puedes repetir una lección cuando quieras.',
      ],
      shots: const [
        _Shot('leccion-pregunta', 'Una pregunta con un programa y cuatro opciones.'),
        _Shot('leccion-acierto', 'Al acertar: la explicación y a seguir.'),
        _Shot('leccion-figuras', 'Preguntas de figuras del diagrama de flujo.'),
        _Shot('leccion-ordenar', 'Ordenar las líneas de un programa.'),
        _Shot('leccion-final', 'Al terminar: cuántas acertaste a la primera.'),
      ],
    ),
    _Topic(
      icon: Icons.flag_outlined,
      title: 'Retos',
      summary: 'Diez ejercicios para practicar por tu cuenta',
      intro:
          'Hay 10 retos, uno por tema y en orden: variables, operadores, Si, Según, Mientras, Para y Repetir. '
          'Cada uno va después de la lección que lo prepara. Funcionan sin internet.',
      steps: [
        desktop
            ? 'Haz clic en Ruta en la barra de la izquierda y elige un reto, o en Ayuda → Retos para practicar.'
            : 'Abre la sala Ruta (abajo) y toca un reto. El siguiente también aparece en Inicio.',
        'Lee el enunciado. Lo ocultas o lo muestras con la flecha.',
        'Si te atoras, toca el foco para ver una pista. Con Otra pista ves la siguiente: van de una idea a un '
            'ejemplo, sin darte la respuesta.',
        'Escribe tu programa y toca Probar. Algunas pruebas son ocultas: sus datos son secretos para que tu '
            'programa funcione con cualquier dato.',
        'Si pasa todo, sale ¡Reto superado! y el botón Siguiente reto.',
      ],
      shots: const [
        _Shot('retos', 'La Ruta: lecciones y retos por grupos, con tu avance.'),
        _Shot('reto', 'El reto con su enunciado.'),
      ],
      action: ('Ver los retos', go(onOpenChallenges)),
    ),
    _Topic(
      icon: Icons.fact_check_outlined,
      title: 'Cómo leer las pruebas',
      summary: 'Antes de probar, al probar y después de editar',
      intro:
          'Las pruebas dicen "si el programa recibe estos datos, debe mostrar esto". Probar corre todas y te '
          'explica cada fallo en una frase.',
      steps: [
        'Antes de probar todo está en gris: todavía no hay nada que juzgar.',
        'Verde es una prueba que pasó. Rojo es una que falló, con lo que debía mostrar y lo que mostró tu '
            'programa. Con Ver esta prueba en la consola la ves correr.',
        'Si cambias el código después de probar, el resultado se pone gris y dice Desactualizado: ya no '
            'habla de tu programa actual. Toca Probar de nuevo.',
        'El resultado se conserva aunque cambies de pestaña, de programa o cierres la app.',
      ],
      shots: const [
        _Shot('pruebas-neutras', 'Antes de probar.'),
        _Shot('pruebas-gris', 'Después de editar: desactualizado, en gris.'),
        _Shot('reto-superado', 'Pasaste todas las pruebas.'),
      ],
    ),
    _Topic(
      icon: Icons.qr_code_scanner,
      title: 'El ejercicio del proyector',
      summary: 'Escanea el QR de tu profe',
      steps: [
        if (canScanQr) ...[
          'En la sala Clases toca Escanear QR.',
          'Apunta al QR que proyecta tu profe: el ejercicio se abre solo, listo para resolver.',
        ] else ...[
          'Escanéalo con la cámara de tu celular: abre el ejercicio en el navegador.',
          desktop
              ? 'Si te pasan el enlace, ábrelo en el menú Archivo, en Abrir enlace.'
              : 'Si te pasan el enlace, ábrelo en la sala Clases, en Abrir enlace.',
        ],
        'El ejercicio queda guardado en tus programas y lo resuelves sin conexión.',
      ],
      action: ('Escanear un QR', go(onScan)),
    ),
    _Topic(
      icon: Icons.edit_note,
      title: 'Planteamiento',
      summary: 'Piensa el problema antes de programar',
      intro: 'El planteamiento te pide tres cosas: qué datos entran, qué haces con ellos y qué muestras al final.',
      steps: [
        desktop
            ? 'Está en el menú Archivo, en Planteamiento.'
            : 'Está en el menú de tres puntos, en Planteamiento. En un reto también está el botón de la libreta.',
        'Se guarda como comentario al inicio del programa, así que tu profe también lo ve.',
      ],
      action: ('Escribir el planteamiento', go(onPlan)),
    ),
    _Topic(
      icon: Icons.table_chart_outlined,
      title: 'Prueba de escritorio',
      summary: 'La tabla de variables, paso a paso',
      intro: 'Jaguar arma la tabla: una fila por cada paso y una columna por cada variable.',
      steps: [
        desktop
            ? 'Está en el menú Ejecutar, en Prueba de escritorio.'
            : 'Está en el menú de tres puntos, en Prueba de escritorio.',
        'En Datos de entrada escribe los datos que va a leer el programa, separados por comas y en orden. Por '
            'ejemplo: 7, 10.',
        'Toca Hacer la tabla. Los valores que cambian en cada paso se marcan.',
        'Con Practicar la llenas tú y Revisar te dice cuántos acertaste y marca en rojo los que no.',
        'El botón de copiar de arriba pega la tabla en tu documento o en una hoja de cálculo.',
      ],
      shots: const [_Shot('prueba-escritorio', 'La tabla con los datos 7 y 10.')],
      action: ('Hacer la prueba de escritorio', go(onDeskCheck)),
    ),
    if (desktop)
      const _Topic(
        icon: Icons.directions_walk,
        title: 'Paso a paso',
        summary: 'Ve tu programa instrucción por instrucción',
        steps: [
          'F10 (o F7) ejecuta una instrucción a la vez y la ilumina en el código y el diagrama.',
          'Abajo ves cada variable; las que acaban de cambiar se marcan.',
          'F4 ejecuta hasta la línea del cursor.',
        ],
      ),
    _Topic(
      icon: Icons.save_alt,
      title: 'Guardar, abrir y compartir',
      summary: 'Tus programas se guardan solos',
      intro:
          'Tus programas se guardan solos en este dispositivo, sin cuenta. Los archivos .psc son de texto y '
          'también los abren otros programas de pseudocódigo.',
      steps: [
        desktop
            ? 'Tus programas están en el panel Mis programas, a la izquierda. Guardar (${shortcutLabel('S')}) y '
                  'Abrir (${shortcutLabel('O')}) están en la barra.'
            : 'Tus programas están en la sala Taller (abajo). Ahí los buscas, los abres y puedes eliminar uno: te '
                  'deja Deshacer unos segundos. Con el menú ⋮ del Taller guardas todos tus programas en un solo archivo.',
        desktop
            ? 'Compartir (QR o enlace) está en la barra.'
            : 'Dentro de un programa, en el menú ⋮ de arriba: Guardar como archivo (.psc), Abrir archivo, Enviar '
                  'archivo (WhatsApp, correo…) y Compartir (QR o enlace).',
        'Con Compartir sale un QR. Escanéalo con la cámara de otro celular para abrir ahí el programa, o toca '
            'Copiar enlace y mándalo por WhatsApp.',
        'Ojo: tus programas viven en este dispositivo. Si borras los datos del navegador o desinstalas la app, '
            'se borran. Guarda como archivo lo que no quieras perder.',
      ],
      shots: [
        if (!desktop) const _Shot('sala-taller', 'La sala Taller, con tus programas.'),
        if (!desktop) const _Shot('mas-opciones', 'El menú ⋮ de arriba.'),
        const _Shot('compartir', 'Compartir con QR o enlace.'),
      ],
    ),
    _Topic(
      icon: Icons.home_outlined,
      title: 'Inicio y ajustes',
      summary: 'Dónde empezar y cómo usas Jaguar',
      intro: desktop
          ? 'En la computadora las cuatro salas están siempre en la barra de la izquierda: Inicio (lo que sigue), Ruta '
                '(lecciones y retos), Clases (lo de tu profe) y Taller (tu editor y tus programas).'
          : 'El Inicio del celular es un portal con tres secciones: Ruta (lecciones y retos, en un camino), '
                'Taller (tus propios programas) y Clases (lo de tu profe). Toca una para entrar y la flecha de '
                'arriba para volver. Un programa, un reto o una tarea se abre en el editor; Atrás regresa.',
      steps: [
        'Básico muestra solo lo necesario para empezar. Completo agrega todos los menús (como Editar y Ver), '
            'atajos y más opciones. Puedes ir y venir sin perder nada.',
        'Cuando llevas varios programas con ciclos sin errores, Jaguar te sugiere una vez probar Completo. '
            'Nunca cambia solo.',
        desktop
            ? 'Ajustes está abajo del panel de la izquierda: modo, perfil (alumno o profesor), tema, tamaño de '
                  'letra, tu nombre y volver a ver la introducción.'
            : 'Ajustes está en Inicio, con el engrane de arriba: modo, perfil (alumno o profesor), tema, tamaño de '
                  'letra, tu nombre y volver a ver la introducción o la guía del Reto 1.',
        desktop
            ? 'Lo que usas menos (Comunidad, Mis clases, tu cuenta, Acerca de) está en Más, dentro del menú.'
            : 'Lo que usas menos (programas de la comunidad, tu cuenta, Acerca de) está al final de Ajustes.',
      ],
      shots: [
        if (desktop)
          const _Shot('ancha-inicio', 'Inicio, con las salas en la barra de la izquierda.')
        else
          const _Shot('inicio', 'Inicio: lo que sigue para ti.'),
        const _Shot('ajustes', 'Ajustes.'),
      ],
    ),
    _Topic(
      icon: Icons.groups_outlined,
      title: 'Tu clase',
      summary: 'Únete con el código de tu profe y entrega',
      intro: 'Las clases en línea necesitan internet. Tu profe te da un código como JAG-4K7Q.',
      steps: [
        desktop ? 'Haz clic en Clases en la barra de la izquierda.' : 'Abre la sala Clases y toca Mis clases en línea.',
        'Toca Entrar, elige Alumno y escribe un alias. No uses tu nombre completo ni datos personales. No '
            'necesitas correo.',
        'Toca Unirme con un código. Escribe el código y tu nombre: solo lo ve tu profe, para saber de quién es '
            'cada entrega.',
        'Abre una tarea con Resolver y toca Probar: el resultado le llega a tu profe y Jaguar te avisa. Puedes '
            'seguir mejorando y volver a probar.',
      ],
      action: ('Ir a Mis clases', go(onOpenClasses)),
    ),
    _Topic(
      icon: Icons.verified_outlined,
      title: 'Mostrar al profesor',
      summary: 'La pantalla verde para enseñar desde tu lugar',
      intro: 'Cuando un ejercicio de tu profe pasa todas las pruebas, aparece el botón Mostrar al profesor.',
      steps: [
        'La primera vez te pide tu nombre. Luego sale una pantalla verde con tu nombre, el ejercicio, cuántos '
            'casos pasaron y la hora en que se verificó.',
        'Abajo hay un reloj que sigue corriendo, así tu profe sabe que es de ahora.',
        'Con Ver el código le enseñas tu programa. Para cambiar tu nombre: Ajustes.',
      ],
      shots: const [_Shot('mostrar-al-profe', 'La pantalla verde para enseñar desde tu lugar.')],
    ),
    if (!desktop)
      const _Topic(
        icon: Icons.arrow_back,
        title: 'El botón Atrás en Android',
        summary: 'No sales por accidente',
        steps: [
          'Atrás te regresa del programa a la sala donde lo abriste; desde otra sala, al Inicio.',
          'Si ya estás en Inicio, Jaguar dice "Presiona Atrás otra vez para salir". Solo sale si lo '
              'presionas otra vez enseguida.',
          'Tu programa ya está guardado; al volver lo encuentras igual.',
        ],
      ),
    _Topic(
      icon: Icons.wifi_off_outlined,
      title: 'Sin internet e instalar',
      summary: 'Programar no necesita datos',
      steps: [
        'Escribir, ejecutar, dibujar diagramas, hacer retos, la prueba de escritorio y resolver los ejercicios '
            'que ya abriste funcionan sin conexión.',
        'Solo las clases en línea y la comunidad necesitan internet.',
        if (!desktop)
          'En el navegador del celular puedes instalar Jaguar: abre el menú de Chrome y toca Instalar app o '
              'Agregar a pantalla principal.'
        else
          'En Chrome o Edge, busca el ícono de instalar en la barra de direcciones.',
      ],
    ),
  ];

  List<_Topic> _teacherTopics({required bool desktop, required VoidCallback? Function(VoidCallback?) go}) => [
    _Topic(
      icon: Icons.school_outlined,
      title: 'Elige «Soy profesor»',
      summary: 'Tus herramientas quedan a la mano',
      steps: [
        'En la bienvenida toca "Soy profesor" y confirma. Si ya habías elegido otra opción, cámbialo en Ajustes → Perfil.',
        desktop
            ? 'Aparece el menú Profesor (en modo Completo) y Mis ejercicios en el panel de la izquierda.'
            : 'Mis ejercicios aparece arriba en la sala Clases.',
      ],
      shots: const [_Shot('sala-clases-profe', 'La sala Clases de un profesor empieza por Mis ejercicios.')],
    ),
    _Topic(
      icon: Icons.assignment_outlined,
      title: 'Crea un ejercicio',
      summary: 'Tu solución genera las pruebas',
      steps: [
        'Abre Mis ejercicios y toca Nuevo ejercicio. Escribe el título y el enunciado.',
        'En Tu solución escribe el programa como si fueras el alumno. Nunca se comparte. Toca Generar casos con '
            'mi solución: Jaguar propone las pruebas que recorren los caminos de tu solución.',
        'Revísalas: puedes editarlas, agregar más o marcar una como Oculta, para que no programen "para el '
            'ejemplo".',
        if (desktop) 'Atajo: con tu solución abierta, menú Profesor, Crear ejercicio con este programa.',
        'Flexible no distingue mayúsculas, acentos ni espacios de más; Exacta pide la salida idéntica.',
        'Si cambias tu solución, Recalcular salidas actualiza lo esperado y Comprobar mi solución la corre.',
      ],
      shots: const [_Shot('ejercicio-profe', 'Jaguar propone los casos a partir de tu solución.')],
      action: ('Ir a Mis ejercicios', go(onOpenTeacher)),
    ),
    const _Topic(
      icon: Icons.qr_code_2,
      title: 'Compártelo sin internet',
      summary: 'Con un QR en el proyector o un enlace',
      steps: [
        'En el editor del ejercicio toca Proyectar, o en Mis ejercicios abre el menú del ejercicio y elige '
            'Proyectar. Sale un QR grande para el proyector.',
        'Tus alumnos lo leen con Escanear QR en la app de Jaguar, o con la cámara del celular.',
        'Copiar enlace te da un enlace para WhatsApp o Classroom.',
        'Cuando un alumno pasa todas las pruebas, te enseña la pantalla verde con su nombre y la hora.',
        'En el mismo menú están Probar como alumno y Compartir en el banco (este necesita internet).',
      ],
      shots: [_Shot('compartir', 'Un QR o un enlace, sin cuenta.')],
    ),
    _Topic(
      icon: Icons.groups_outlined,
      title: 'Tu clase en línea',
      summary: 'Un código para tu grupo',
      steps: [
        'Entra en línea como Profesor con tu correo, para no perder tus clases si cambias de equipo. La primera '
            'vez toca ¿Primera vez? Crear cuenta de profesor. Si olvidas la contraseña, hay un enlace por correo.',
        'En Mis clases toca Crear clase y ponle un nombre, como «1° A · Lógica». Jaguar te da un código como '
            'JAG-4K7Q: cópialo a tu grupo de WhatsApp o escríbelo en el pizarrón.',
        'Tus alumnos entran con el código y un nombre; no necesitan correo.',
        'Dentro de la clase, Asignar ejercicio elige uno de Mis ejercicios o del banco de la comunidad.',
      ],
      action: ('Ir a Mis clases', go(onOpenClasses)),
    ),
    const _Topic(
      icon: Icons.fact_check_outlined,
      title: 'Revisa las entregas',
      summary: 'Quién va cómo, en una tabla',
      steps: [
        'Cada vez que un alumno toca Probar, su resultado aparece en la tabla de la clase: cuántas pruebas pasó '
            'y a qué hora. Usa Actualizar para ver lo más reciente.',
        'Toca una celda para ver su programa. Con Abrir una copia lo abres en tu editor para ejecutarlo o hacer '
            'su prueba de escritorio.',
        'Si ves el ícono de portapapeles, pegó muchas líneas de una vez: pídele que te explique su programa.',
        'Jaguar no califica: la calificación y la rúbrica las pones tú.',
      ],
    ),
  ];

  List<(String, String)> _problems({required bool desktop}) => [
    (
      'Mi programa no avanza',
      'Seguro está en un Leer esperando un dato. En el celular la pestaña Consola tiene un punto: ábrela, '
          'escribe el dato y presiona Enter. Si es un ciclo que nunca termina, detenlo con el botón rojo y '
          'revisa la condición.',
    ),
    (
      'Dice "Parece que falta una comilla"',
      'Los textos van entre comillas: Escribir "Hola". Sin comillas, Jaguar piensa que Hola es una variable. '
          'La sugerencia del error trae la línea ya corregida.',
    ),
    (
      'No veo el diagrama',
      desktop
          ? 'Arriba, elige Diagrama o Ambos. Si el código tiene un error, corrígelo y el diagrama se actualiza.'
          : 'Toca Diagrama en el selector bajo la barra. Para volver al escrito, toca Código. Si el código tiene '
                'un error, corrígelo y el diagrama se actualiza.',
    ),
    (
      'Perdí mi programa',
      'Búscalo en la sala Taller (celular) o en Mis programas (computadora). Si acabas de eliminarlo, toca Deshacer '
          'en el aviso de abajo. Se guarda en este dispositivo y navegador; por eso conviene guardar como '
          'archivo o compartir con un enlace.',
    ),
    (
      'Una prueba oculta falla y no sé por qué',
      'Sus datos son secretos. Prueba tu programa con otros valores: cero, negativos, números grandes o '
          'iguales. Casi siempre ahí está el detalle.',
    ),
    (
      'Las pruebas están en gris',
      'Cambiaste el código desde la última prueba, o todavía no has probado. Toca Probar para que vuelvan a '
          'hablar de tu programa actual.',
    ),
    ('No me sale el QR', 'Si el programa es muy largo no cabe en un QR. Usa Copiar enlace o guárdalo como archivo.'),
    ('No aparece Mis clases', 'Las clases necesitan internet. Conéctate y vuelve a abrir Jaguar.'),
    (
      'No veo el menú Editar, Ver o Profesor',
      'Están en modo Completo (Ajustes). El menú Profesor aparece si tu perfil es Profesor.',
    ),
  ];
}

class _Shot {
  const _Shot(this.name, this.caption);

  /// A picture of the app in assets/manual, taken with tool/capturas.sh.
  final String name;
  final String caption;

  String get asset => 'assets/manual/$name.webp';
}

class _Topic {
  const _Topic({
    required this.icon,
    required this.title,
    required this.summary,
    required this.steps,
    this.intro,
    this.shots = const [],
    this.moreShots = const [],
    this.note,
    this.action,
    this.initiallyOpen = false,
  });

  final IconData icon;
  final String title;
  final String summary;
  final List<String> steps;

  /// A paragraph before the steps, for the idea behind them.
  final String? intro;

  /// Pictures before the steps, and after them.
  final List<_Shot> shots;
  final List<_Shot> moreShots;
  final String? note;

  /// A button that takes you there; hidden when the action isn't available.
  final (String, VoidCallback?)? action;
  final bool initiallyOpen;
}

class _Page extends StatelessWidget {
  const _Page({required this.greeting, required this.topics, this.extra = const []});

  final String greeting;
  final List<_Topic> topics;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Card(
              color: scheme.primaryContainer,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset('assets/images/mascota.png', width: 56, height: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        greeting,
                        style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final topic in topics) _TopicCard(topic: topic),
            ...extra,
            const SizedBox(height: 16),
            Text(
              'Este manual también está en jaguarcode.org/manual',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final _Topic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final action = topic.action;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        initiallyExpanded: topic.initiallyOpen,
        leading: CircleAvatar(
          backgroundColor: jaguarYellow.withValues(alpha: 0.3),
          foregroundColor: scheme.onSurface,
          child: Icon(topic.icon),
        ),
        title: Text(topic.title, style: theme.textTheme.titleMedium),
        subtitle: Text(topic.summary),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topic.intro case final intro?) Text(intro, style: theme.textTheme.bodyLarge),
          if (topic.shots.isNotEmpty) _Shots(shots: topic.shots),
          for (final (i, step) in topic.steps.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(step, style: theme.textTheme.bodyLarge)),
                ],
              ),
            ),
          if (topic.moreShots.isNotEmpty) _Shots(shots: topic.moreShots),
          if (topic.note case final note?) Padding(padding: const EdgeInsets.only(top: 12), child: _Note(note)),
          if (action != null && action.$2 != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: FilledButton.tonalIcon(
                onPressed: action.$2,
                icon: const Icon(Icons.arrow_forward),
                label: Text(action.$1),
              ),
            ),
        ],
      ),
    );
  }
}

/// The pictures of a topic, side by side and scrolling sideways; tapping one
/// opens it large.
class _Shots extends StatelessWidget {
  const _Shots({required this.shots});

  final List<_Shot> shots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 410,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: shots.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final shot = shots[i];
            return Semantics(
              label: 'Imagen: ${shot.caption}',
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _open(context, shot),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: _Picture(shot: shot)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: shot.name == 'computadora' ? 520 : 200,
                      child: Text(
                        shot.caption,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _open(BuildContext context, _Shot shot) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(shot.caption, style: const TextStyle(fontSize: 16)),
            leading: IconButton(
              tooltip: 'Cerrar',
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: InteractiveViewer(
            maxScale: 4,
            child: Center(child: _Picture(shot: shot, border: false)),
          ),
        ),
      ),
    );
  }
}

class _Picture extends StatelessWidget {
  const _Picture({required this.shot, this.border = true});

  final _Shot shot;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(border ? 12 : 0),
      child: DecoratedBox(
        decoration: BoxDecoration(border: border ? Border.all(color: scheme.outlineVariant) : null),
        // A missing picture never breaks the guide.
        child: Image.asset(
          shot.asset,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox(width: 170, child: Icon(Icons.image_not_supported_outlined)),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _Problem extends StatelessWidget {
  const _Problem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      shape: const Border(),
      leading: const Icon(Icons.help_outline),
      title: Text(question),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(answer, style: Theme.of(context).textTheme.bodyLarge)],
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(color: scheme.onSecondaryContainer)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Ejecutar', '${shortcutLabel('Enter')} · F9'),
      ('Paso a paso / siguiente paso', 'F10 · F7'),
      ('Ejecutar hasta el cursor', 'F4'),
      ('Probar un ejercicio', shortcutLabel('Enter', shift: true)),
      ('Guardar como .psc', shortcutLabel('S')),
      ('Buscar · reemplazar', '${shortcutLabel('F')} · ${shortcutLabel('H')}'),
      ('Comentar líneas', shortcutLabel('/')),
      ('Mover · duplicar línea', 'Alt+↑/↓ · Shift+Alt+↓'),
      ('Ordenar sangría', 'Shift+Alt+F'),
      ('Renombrar variable', 'F2'),
      ('Sugerencias', 'Ctrl+Espacio'),
      ('Ver código · diagrama · ambos', '${shortcutLabel('Alt+1')} · 2 · 3'),
      ('Esta guía', 'F1'),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final (action, keys) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(action)),
                    Text(keys, style: monoStyle.copyWith(fontSize: 13, letterSpacing: 0)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
