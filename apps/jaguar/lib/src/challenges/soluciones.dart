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
  'reto-2-01': '''
Algoritmo bisiesto
    Leer anio
    Si (anio MOD 4 = 0 Y anio MOD 100 <> 0) O anio MOD 400 = 0 Entonces
        Escribir "Bisiesto"
    SiNo
        Escribir "No bisiesto"
    FinSi
FinAlgoritmo
''',
  'reto-2-02': '''
Algoritmo mayor_de_tres
    Leer a, b, c
    mayor <- a
    Si b > mayor Entonces
        mayor <- b
    FinSi
    Si c > mayor Entonces
        mayor <- c
    FinSi
    Escribir "Mayor: ", mayor
FinAlgoritmo
''',
  'reto-2-03': '''
Algoritmo triangulo
    Leer a, b, c
    Si a = b Y b = c Entonces
        Escribir "Equilátero"
    SiNo
        Si a = b O b = c O a = c Entonces
            Escribir "Isósceles"
        SiNo
            Escribir "Escaleno"
        FinSi
    FinSi
FinAlgoritmo
''',
  'reto-2-04': '''
Algoritmo calculadora
    Definir op Como Texto
    Leer a, op, b
    Segun op Hacer
        "+": Escribir a + b
        "-": Escribir a - b
        "*": Escribir a * b
        "/":
            Si b = 0 Entonces
                Escribir "No se puede dividir"
            SiNo
                Escribir a / b
            FinSi
    FinSegun
FinAlgoritmo
''',
  'reto-2-05': '''
Algoritmo nombre_del_mes
    Leer mes
    Segun mes Hacer
        1: Escribir "Enero"
        2: Escribir "Febrero"
        3: Escribir "Marzo"
        4: Escribir "Abril"
        5: Escribir "Mayo"
        6: Escribir "Junio"
        7: Escribir "Julio"
        8: Escribir "Agosto"
        9: Escribir "Septiembre"
        10: Escribir "Octubre"
        11: Escribir "Noviembre"
        12: Escribir "Diciembre"
        De Otro Modo: Escribir "Mes inválido"
    FinSegun
FinAlgoritmo
''',
  'reto-2-06': '''
Algoritmo promedio_con_centinela
    suma <- 0
    cuenta <- 0
    Leer c
    Mientras c <> -1 Hacer
        suma <- suma + c
        cuenta <- cuenta + 1
        Leer c
    FinMientras
    Si cuenta = 0 Entonces
        Escribir "Sin datos"
    SiNo
        Escribir "Promedio: ", suma / cuenta
    FinSi
FinAlgoritmo
''',
  'reto-2-07': '''
Algoritmo mayor_de_la_lista
    Leer n
    Si n = 0 Entonces
        Escribir "Sin números"
    SiNo
        mayor <- n
        Mientras n <> 0 Hacer
            Si n > mayor Entonces
                mayor <- n
            FinSi
            Leer n
        FinMientras
        Escribir "Mayor: ", mayor
    FinSi
FinAlgoritmo
''',
  'reto-2-08': '''
Algoritmo suma_de_pares
    Leer n
    suma <- 0
    Para i <- 1 Hasta n Hacer
        Si i MOD 2 = 0 Entonces
            suma <- suma + i
        FinSi
    FinPara
    Escribir "Suma: ", suma
FinAlgoritmo
''',
  'reto-2-09': '''
Algoritmo factorial
    Leer n
    factorial <- 1
    Mientras n > 1 Hacer
        factorial <- factorial * n
        n <- n - 1
    FinMientras
    Escribir "Factorial: ", factorial
FinAlgoritmo
''',
  'reto-2-10': '''
Algoritmo cuenta_regresiva
    Leer n
    Para i <- n Hasta 1 Con Paso -1 Hacer
        Escribir i
    FinPara
    Escribir "¡Despegue!"
FinAlgoritmo
''',
  'reto-2-11': '''
Algoritmo cuadro
    Leer n
    Para i <- 1 Hasta n Hacer
        Para j <- 1 Hasta n Hacer
            Escribir Sin Saltar "*"
        FinPara
        Escribir ""
    FinPara
FinAlgoritmo
''',
  'reto-2-12': '''
Algoritmo escalera
    Leer n
    Para i <- 1 Hasta n Hacer
        Para j <- 1 Hasta i Hacer
            Escribir Sin Saltar "*"
        FinPara
        Escribir ""
    FinPara
FinAlgoritmo
''',
};
