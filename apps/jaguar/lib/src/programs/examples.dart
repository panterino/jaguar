/// Example programs shown in the menu, each one introducing an idea.
const examples = <(String title, String source)>[
  (
    'Hola mundo',
    '''Algoritmo hola_mundo
    Escribir "¡Hola, mundo!"
FinAlgoritmo
''',
  ),
  (
    'Par o impar',
    '''Algoritmo par_o_impar
    Definir n Como Entero
    Escribir "Escribe un número:"
    Leer n
    Si n MOD 2 = 0 Entonces
        Escribir n, " es par"
    SiNo
        Escribir n, " es impar"
    FinSi
FinAlgoritmo
''',
  ),
  (
    'Tabla de multiplicar',
    '''Algoritmo tabla
    Definir n, i Como Entero
    Escribir "¿Qué tabla quieres ver?"
    Leer n
    Para i <- 1 Hasta 10 Hacer
        Escribir n, " x ", i, " = ", n * i
    FinPara
FinAlgoritmo
''',
  ),
  (
    'Adivina el número',
    '''Algoritmo adivina
    Definir secreto, intento, intentos Como Entero
    secreto <- Aleatorio(1, 100)
    intentos <- 0
    Escribir "Pensé un número del 1 al 100. ¡Adivínalo!"
    Repetir
        Leer intento
        intentos <- intentos + 1
        Si intento < secreto Entonces
            Escribir "Más grande..."
        SiNo
            Si intento > secreto Entonces
                Escribir "Más pequeño..."
            FinSi
        FinSi
    Hasta Que intento = secreto
    Escribir "¡Correcto! Lo lograste en ", intentos, " intentos."
FinAlgoritmo
''',
  ),
  (
    'Promedio de calificaciones',
    '''Algoritmo promedio
    Definir n, i Como Entero
    Definir suma, prom Como Real
    Escribir "¿Cuántas calificaciones?"
    Leer n
    Dimension calif[n]
    suma <- 0
    Para i <- 1 Hasta n Hacer
        Escribir "Calificación ", i, ":"
        Leer calif[i]
        suma <- suma + calif[i]
    FinPara
    prom <- suma / n
    Escribir "Promedio: ", prom
    Segun Trunc(prom) Hacer
        10: Escribir "¡Excelente!"
        8, 9: Escribir "Muy bien"
        6, 7: Escribir "Aprobado"
        De Otro Modo:
            Escribir "Reprobado"
    FinSegun
FinAlgoritmo
''',
  ),
  (
    'Factorial (función recursiva)',
    '''Funcion resultado <- Factorial(n)
    Si n <= 1 Entonces
        resultado <- 1
    SiNo
        resultado <- n * Factorial(n - 1)
    FinSi
FinFuncion

Algoritmo factorial
    Definir n Como Entero
    Escribir "Número:"
    Leer n
    Escribir n, "! = ", Factorial(n)
FinAlgoritmo
''',
  ),
];
