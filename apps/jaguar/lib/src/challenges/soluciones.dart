/// Una solución de referencia por reto, bien sangrada. Las usan las pruebas
/// (cada una pasa todos los casos de su reto) y las páginas de retos de la
/// landing (tool/retos_html.dart), que las muestran como solución explicada.
const soluciones = <String, String>{
  'reto-1-01': '''
Algoritmo saludo
    Definir nombre Como Texto
    Leer nombre
    Escribir "Hola, ", nombre
FinAlgoritmo
''',
  'reto-1-02': '''
Algoritmo area_rectangulo
    Leer base, altura
    area <- base * altura
    Escribir "Área: ", area
FinAlgoritmo
''',
  'reto-1-03': '''
Algoritmo precio_con_iva
    Leer precio
    iva <- 0.16
    total <- precio + precio * iva
    Escribir "Total: ", total
FinAlgoritmo
''',
  'reto-1-04': '''
Algoritmo minutos_a_horas
    Leer minutos
    horas <- Trunc(minutos / 60)
    resto <- minutos MOD 60
    Escribir horas, " horas y ", resto, " minutos"
FinAlgoritmo
''',
  'reto-1-05': '''
Algoritmo aprobado
    Leer calificacion
    Si calificacion >= 6 Entonces
        Escribir "Aprobado"
    SiNo
        Escribir "Reprobado"
    FinSi
FinAlgoritmo
''',
  'reto-1-06': '''
Algoritmo dentro_del_rango
    Leer n
    Si n >= 1 Y n <= 10 Entonces
        Escribir "Dentro"
    SiNo
        Escribir "Fuera"
    FinSi
FinAlgoritmo
''',
  'reto-1-07': '''
Algoritmo dia_de_la_semana
    Leer dia
    Segun dia Hacer
        1: Escribir "Lunes"
        2: Escribir "Martes"
        3: Escribir "Miércoles"
        4: Escribir "Jueves"
        5: Escribir "Viernes"
        6: Escribir "Sábado"
        7: Escribir "Domingo"
        De Otro Modo: Escribir "No existe"
    FinSegun
FinAlgoritmo
''',
  'reto-1-08': '''
Algoritmo suma_hasta_cero
    suma <- 0
    Leer n
    Mientras n <> 0 Hacer
        suma <- suma + n
        Leer n
    FinMientras
    Escribir "Suma: ", suma
FinAlgoritmo
''',
  'reto-1-09': '''
Algoritmo tabla_de_multiplicar
    Leer n
    Para i <- 1 Hasta 10 Hacer
        Escribir n, " x ", i, " = ", n * i
    FinPara
FinAlgoritmo
''',
  'reto-1-10': '''
Algoritmo contrasena
    Definir clave Como Texto
    intentos <- 0
    Repetir
        Leer clave
        intentos <- intentos + 1
    Hasta Que clave = "jaguar"
    Escribir "Entraste en ", intentos, " intentos"
FinAlgoritmo
''',
  'reto-1-11': '''
Algoritmo grito
    Definir texto Como Texto
    Leer texto
    Escribir Mayusculas(texto) + "!"
FinAlgoritmo
''',
  'reto-1-12': '''
Algoritmo contar_letras
    Definir palabra Como Texto
    Leer palabra
    Escribir "Letras: ", Longitud(palabra)
FinAlgoritmo
''',
  'reto-0-01': '''
Algoritmo eco
    Leer palabra
    Escribir palabra
    Escribir palabra
FinAlgoritmo
''',
  'reto-0-02': '''
Algoritmo suma
    Leer a, b
    Escribir a + b
FinAlgoritmo
''',
  'reto-0-03': '''
Algoritmo mayor_de_edad
    Leer edad
    Si edad >= 18 Entonces
        Escribir "Mayor"
    SiNo
        Escribir "Menor"
    FinSi
FinAlgoritmo
''',
};
