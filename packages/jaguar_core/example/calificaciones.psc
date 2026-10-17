// Promedio de calificaciones con arreglos, funciones y Segun.
Funcion promedio <- CalcularPromedio(calif, n)
	Definir suma Como Real
	suma <- 0
	Para i <- 1 Hasta n Hacer
		suma <- suma + calif[i]
	FinPara
	promedio <- suma / n
FinFuncion

SubProceso Intercambiar(a Por Referencia, b Por Referencia)
	aux <- a
	a <- b
	b <- aux
FinSubProceso

Algoritmo calificaciones
	Definir n Como Entero
	Leer n
	Dimension calif[n]
	Para i <- 1 Hasta n Hacer
		Leer calif[i]
	FinPara
	p <- CalcularPromedio(calif, n)
	Escribir "Promedio: ", p
	Segun Trunc(p) Hacer
		10: Escribir "Excelente"
		8, 9: Escribir "Muy bien"
		6, 7: Escribir "Aprobado"
		De Otro Modo:
			Escribir "Reprobado"
	FinSegun
	a <- 1
	b <- 2
	Intercambiar(a, b)
	Escribir "a=", a, " b=", b
FinAlgoritmo
