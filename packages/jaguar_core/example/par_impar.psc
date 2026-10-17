// Pide números y dice si son pares o impares.
Algoritmo par_impar
	Definir n, i, cantidad Como Entero
	Escribir "¿Cuántos números vas a revisar?"
	Leer cantidad
	Para i <- 1 Hasta cantidad Hacer
		Escribir "Número ", i, ":"
		Leer n
		Si n MOD 2 = 0 Entonces
			Escribir n, " es par"
		SiNo
			Escribir n, " es impar"
		FinSi
	FinPara
FinAlgoritmo
