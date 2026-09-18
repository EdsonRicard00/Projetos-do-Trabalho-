resposta = "sim"
while resposta == "sim":
    numero = int(input("Digite um número inteiro: "))
    if numero % 2 == 0:
        print(f"O número {numero} é par.")
    else:
        print(f"O número {numero} é ímpar.")
    
    resposta = input("Deseja verificar outro número? (sim/não): ").lower()
    print("Fim do programa.")
    