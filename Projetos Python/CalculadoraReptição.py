continuar = "s"

while continuar == "s":
    num = float(input("Digite um número: "))
    num2 = float(input("Digite outro número: "))

    print ("Escolha uma operação: ")
    print ("1 - Adição")
    print ("2 - Subtração")
    print ("3 - Multiplicação")
    print ("4 - Divisão")
    operacao = int(input("Digite o número da operação desejada: "))


    if operacao == 1:
        resultado = num + num2
        print("O resultado da adição é:", resultado)    
    elif operacao == 2:
        resultado = num - num2
        print("O resultado da subtração é:", resultado)         
    elif operacao == 3:
        resultado = num * num2
        print("O resultado da multiplicação é:", resultado)             
    elif operacao == 4:                                         
        if num2 != 0:
            resultado = num / num2
            print("O resultado da divisão é:", resultado)             
        else:
            print("Erro: Divisão por zero não é permitida.")    
    else:
        print("Operação inválida. Tente novamente.")                                    
        continuar = input("Deseja realizar outra operação? (s/n): ").lower()
        print("Fim do programa.")
