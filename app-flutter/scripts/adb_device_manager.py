import os
import subprocess
from time import sleep

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def execute_adb_command(command):
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print("\nComando executado com sucesso!")
        if result.stdout:
            print("\nSaída:")
            print(result.stdout)
    except subprocess.CalledProcessError as e:
        print("\nErro ao executar o comando:")
        print(e.stderr)
    input("\nPressione Enter para continuar...")

def install_apk():
    clear_screen()
    print("=== Instalar APK ===")
    caminho = input("Digite o caminho completo do arquivo APK: ")
    if os.path.exists(caminho):
        execute_adb_command(f'adb install "{caminho}"')
    else:
        print("\nArquivo não encontrado!")
        input("\nPressione Enter para continuar...")

def update_apk():
    clear_screen()
    print("=== Atualizar APK ===")
    caminho = input("Digite o caminho completo do arquivo APK: ")
    if os.path.exists(caminho):
        execute_adb_command(f'adb install -r "{caminho}"')
    else:
        print("\nArquivo não encontrado!")
        input("\nPressione Enter para continuar...")

def uninstall_app():
    clear_screen()
    print("=== Desinstalar Aplicativo ===")
    package_name = input("Digite o nome do pacote (ex: com.exemplo.app): ")
    execute_adb_command(f'adb uninstall {package_name}')
    
def get_app_info(package_name):
    clear_screen()
    print(f"=== Informações do Aplicativo: {package_name} ===\n")
    
    # Versão do app
    version = execute_adb_command(f'adb shell dumpsys package {package_name} | grep versionName')
    if version:
        print(f"Versão: {version.strip()}")
    
    # Tamanho do app
    size = execute_adb_command(f'adb shell pm path {package_name} | cut -d: -f2 | tr -d "\r\n" | xargs -r adb shell ls -l')
    if size:
        print(f"Tamanho: {size.strip()}")
    
    # Data de instalação e última atualização
    install_info = execute_adb_command(f'adb shell dumpsys package {package_name} | grep -E "firstInstallTime|lastUpdateTime"')
    if install_info:
        print(f"Informações de instalação:\n{install_info.strip()}")
    
    # Permissões
    print("\nPermissões:")
    execute_adb_command(f'adb shell dumpsys package {package_name} | grep permission')
    
    # Diretório de dados
    data_dir = execute_adb_command(f'adb shell pm path {package_name}')
    if data_dir:
        print(f"\nLocalização do APK:\n{data_dir.strip()}")
    
    input("\nPressione Enter para continuar...")

def list_packages():
    clear_screen()
    print("=== Listar Pacotes Instalados ===")
    print("\n1. Todos os pacotes")
    print("2. Apenas pacotes do sistema")
    print("3. Apenas pacotes do usuário")
    print("4. Buscar e ver informações de um pacote específico")
    opcao = input("\nEscolha uma opção: ")
    
    if opcao == '1':
        execute_adb_command('adb shell pm list packages')
    elif opcao == '2':
        execute_adb_command('adb shell pm list packages -s')
    elif opcao == '3':
        execute_adb_command('adb shell pm list packages -3')
    elif opcao == '4':
        clear_screen()
        print("=== Buscar Pacote ===")
        busca = input("Digite parte do nome do pacote para buscar: ")
        resultado = execute_adb_command(f'adb shell pm list packages | grep {busca}')
        
        if resultado:
            print("\nPacotes encontrados:")
            packages = resultado.strip().split('\n')
            for i, package in enumerate(packages, 1):
                print(f"{i}. {package.replace('package:', '')}")
            
            escolha = input("\nDigite o número do pacote para ver mais informações (ou Enter para voltar): ")
            if escolha.isdigit() and 1 <= int(escolha) <= len(packages):
                package_name = packages[int(escolha)-1].replace('package:', '').strip()
                get_app_info(package_name)
        else:
            print("\nNenhum pacote encontrado!")
            input("\nPressione Enter para continuar...")
    else:
        print("\nOpção inválida!")
        input("\nPressione Enter para continuar...") #  /Users/leechardes/Downloads/lio-emulator.apk package:cielo.launcher

def device_info():
    clear_screen()
    print("=== Informações do Dispositivo ===")
    execute_adb_command('adb devices')
    execute_adb_command('adb shell getprop ro.build.version.release')
    execute_adb_command('adb shell getprop ro.product.model')
    execute_adb_command('adb shell getprop ro.product.manufacturer')

def main_menu():
    while True:
        clear_screen()
        print("=== ADB Device Manager ===")
        print("\n1. Instalar APK")
        print("2. Atualizar APK")
        print("3. Desinstalar Aplicativo")
        print("4. Listar Pacotes Instalados")
        print("5. Informações do Dispositivo")
        print("6. Sair")
        
        opcao = input("\nEscolha uma opção: ")
        
        if opcao == '1':
            install_apk()
        elif opcao == '2':
            update_apk()
        elif opcao == '3':
            uninstall_app()
        elif opcao == '4':
            list_packages()
        elif opcao == '5':
            device_info()
        elif opcao == '6':
            print("\nSaindo...")
            break
        else:
            print("\nOpção inválida!")
            sleep(1)

if __name__ == "__main__":
    main_menu()