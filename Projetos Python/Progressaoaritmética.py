inicio = int(input("digite o valor de inicio:"))
razao = int(input("digite a razao da PA:"))
fim = int(input("digite o valor de finalização (limite):"))


atual = inicio

print("Calculando a progressão aritmética:")
while atual <= fim:
    print(atual, end=" ")
    atual += razao
    print("FIM DO P.A!")