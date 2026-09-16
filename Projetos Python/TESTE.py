# Lendo dados do usuário e convertendo para número
nome = input("Qual é o seu nome? ")
idade = int(input("Qual é a sua idade? "))

print(f"Olá, {nome}! No ano que vem você terá {idade + 1} anos.")


nota = float(input("Digite sua nota: "))

if nota >= 7.0:
    print("Aprovado!")
elif nota >= 5.0:
    print("Recuperação.")
else:
    print("Reprovado.")