senha = ""

while senha != "1234":
    senha = input("Digite a senha de acesso: ")
    if senha != "1234":
        print("Senha incorreta. Tente novamente.")

print("Acesso permitido! Bem-vindo.")