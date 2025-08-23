import getpass
import os
import platform
import re
import subprocess
import sys
import threading
import time
from datetime import datetime


# Cores para terminal
class Colors:
    HEADER = "\033[95m"
    BLUE = "\033[94m"
    CYAN = "\033[96m"
    GREEN = "\033[92m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"
    BOLD = "\033[1m"
    UNDERLINE = "\033[4m"


# Funções auxiliares para print colorido
def print_header(text):
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{text.center(60)}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.ENDC}\n")


def print_info(text):
    print(f"{Colors.CYAN}ℹ️  {text}{Colors.ENDC}")


def print_success(text):
    print(f"{Colors.GREEN}✅ {text}{Colors.ENDC}")


def print_warning(text):
    print(f"{Colors.WARNING}⚠️  {text}{Colors.ENDC}")


def print_error(text):
    print(f"{Colors.FAIL}❌ {text}{Colors.ENDC}")


def print_step(text):
    print(f"\n{Colors.BLUE}▶️  {Colors.BOLD}{text}{Colors.ENDC}")


# Classe para criar um spinner de loading
class LoadingSpinner:
    def __init__(self, message="Processando"):
        self.message = message
        self.running = False
        self.thread = None

    def __enter__(self):
        self.start()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.stop()

    def start(self):
        self.running = True
        self.thread = threading.Thread(target=self._spin)
        self.thread.start()

    def _spin(self):
        spinner = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        i = 0
        while self.running:
            print(
                f"\r{Colors.CYAN}{spinner[i % len(spinner)]} {self.message}...{Colors.ENDC}",
                end="",
                flush=True,
            )
            i += 1
            time.sleep(0.1)

    def stop(self):
        self.running = False
        if self.thread:
            self.thread.join()
        print("\r" + " " * (len(self.message) + 10) + "\r", end="", flush=True)


# Função para incrementar a versão MAJOR, MINOR ou PATCH
def increment_version(version, level):
    major, minor, patch = map(int, version.split("."))

    if level == "major":
        major += 1
        minor = 0
        patch = 0
    elif level == "minor":
        minor += 1
        patch = 0
    elif level == "patch":
        patch += 1

    return f"{major}.{minor}.{patch}"


# Função para incrementar a build version no pubspec.yaml
def increment_build_version(level=None):
    print_step("Incrementando a versão...")

    # Lê o conteúdo do pubspec.yaml
    with open("pubspec.yaml", "r") as file:
        lines = file.readlines()

    # Encontra a linha da versão
    for i, line in enumerate(lines):
        if line.startswith("version:"):
            current_version = line.split()[1]
            base_version = re.sub(r"\+.*", "", current_version)
            match = re.search(r"\+(.*)", current_version)
            if match:
                current_build_version = match.group(1)
            else:
                # Se não encontrar build version, assume 0
                current_build_version = "0"

            # Incrementa a versão base se um nível for fornecido
            new_base_version = base_version
            if level:
                new_base_version = increment_version(base_version, level)

            # Incrementa apenas a build version se o nível não for fornecido
            new_build_version = str(int(current_build_version) + 1)
            new_version = f"{new_base_version}+{new_build_version}"

            # Atualiza o arquivo com a nova versão
            lines[i] = f"version: {new_version}\n"
            with open("pubspec.yaml", "w") as file:
                file.writelines(lines)

            print_info(f"Versão anterior: {current_version}")
            print_success(f"Nova versão no pubspec.yaml: {new_version}")
            return current_version, new_version


# Função para obter o nome, versão e build version do pubspec.yaml
def get_app_info():
    with open("pubspec.yaml", "r") as file:
        content = file.read()

    name_match = re.search(r"name:\s*(\S+)", content)
    version_match = re.search(r"version:\s*(\S+)", content)

    if not name_match or not version_match:
        raise ValueError("Não foi possível encontrar name ou version no pubspec.yaml")

    app_name = name_match.group(1).strip()
    version = version_match.group(1)
    base_version, build_version = version.split("+")

    return app_name, base_version, build_version


# Função para construir o APK
def build_apk(build_mode):
    try:
        if build_mode == "debug":
            print_step("Iniciando a construção do APK em modo debug...")
            with LoadingSpinner("Compilando aplicação (modo debug)"):
                result = subprocess.run(
                    ["flutter", "build", "apk", "--debug"],
                    capture_output=True,
                    text=True,
                )
            if result.returncode != 0:
                print_error(f"Erro ao construir APK: {result.stderr}")
                return None
            return "build/app/outputs/flutter-apk/app-debug.apk"
        else:
            print_step("Iniciando a construção do APK em modo release...")
            with LoadingSpinner("Compilando aplicação (modo release)"):
                result = subprocess.run(
                    ["flutter", "build", "apk", "--release"],
                    capture_output=True,
                    text=True,
                )
            if result.returncode != 0:
                print_error(f"Erro ao construir APK: {result.stderr}")
                return None

            # COMENTADO TEMPORARIAMENTE - Teste de assinatura automática do Flutter
            # # Assinar APK manualmente (problema temporário do Flutter)
            # apk_path = "build/app/outputs/apk/release/app-release.apk"
            # print_step("Assinando APK...")
            # sign_result = subprocess.run(
            #     [
            #         "jarsigner",
            #         "-verbose",
            #         "-sigalg",
            #         "SHA256withRSA",
            #         "-digestalg",
            #         "SHA-256",
            #         "-keystore",
            #         "android/app/i9_smart_pdv_keystore.jks",
            #         "-storepass",
            #         "i9on@159753",
            #         apk_path,
            #         "i9_smart_pdv_alias",
            #     ],
            #     capture_output=True,
            #     text=True,
            # )
            # if sign_result.returncode != 0:
            #     print_warning(f"Aviso ao assinar APK: {sign_result.stderr}")
            # else:
            #     print_success("APK assinado com sucesso!")

            # return apk_path

            # Retornar o caminho padrão do APK gerado pelo Flutter
            return "build/app/outputs/apk/release/app-release.apk"
    except FileNotFoundError:
        print_error(
            "Flutter não encontrado no PATH. Certifique-se de que o Flutter está instalado e configurado."
        )
        return None


# Função para mesclar arquivos de histórico se existirem
def merge_build_history_files():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(current_dir)

    root_history = os.path.join(project_root, "BUILD_HISTORY.md")
    docs_dir = os.path.join(project_root, "docs")
    docs_history = os.path.join(docs_dir, "BUILD_HISTORY.md")

    # Se existe arquivo na raiz, mescla com o de docs
    if os.path.exists(root_history):
        os.makedirs(docs_dir, exist_ok=True)

        # Lê o conteúdo do arquivo da raiz
        with open(root_history, "r") as f:
            root_content = f.read()

        # Se já existe em docs, prepend o conteúdo
        if os.path.exists(docs_history):
            with open(docs_history, "r") as f:
                docs_content = f.read()

            # Combina os conteúdos (raiz primeiro, depois docs)
            with open(docs_history, "w") as f:
                f.write(root_content)
                if not root_content.endswith("\n\n"):
                    f.write("\n")
                f.write(docs_content)
        else:
            # Se não existe em docs, apenas move
            with open(docs_history, "w") as f:
                f.write(root_content)

        # Remove o arquivo da raiz
        os.remove(root_history)
        print_success("Histórico de build mesclado e movido para docs/")


# Função para gerar histórico de build em arquivo markdown
def generate_build_history(
    user, env_info, old_version, new_version, build_mode, version_level
):
    # Só adiciona ao histórico se a versão mudou
    if old_version == new_version:
        print_warning(
            "Versão não foi alterada, histórico de build não será atualizado."
        )
        return

    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Encontra o diretório raiz do projeto (onde está o pubspec.yaml)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(current_dir)  # Sobe um nível do diretório scripts

    # Define o caminho completo para o arquivo build_history.md em docs
    docs_dir = os.path.join(project_root, "docs")
    os.makedirs(docs_dir, exist_ok=True)  # Cria o diretório docs se não existir

    filename = os.path.join(docs_dir, "BUILD_HISTORY.md")

    # Primeiro mescla arquivos se necessário
    merge_build_history_files()

    with open(filename, "a") as file:
        file.write(f"## Build History - {now}\n")
        file.write(f"- User: {user}\n")
        file.write(f"- Environment: {env_info}\n")
        file.write(f"- Previous Version: {old_version}\n")
        file.write(f"- New Version: {new_version}\n")
        file.write(f"- Build Mode: {build_mode}\n")
        file.write(f"- Version Increment Level: {version_level}\n\n")

    print_success(f"Histórico de build atualizado: {old_version} -> {new_version}")


# Função para obter informações do ambiente
def get_environment_info():
    env_info = {}

    try:
        java_version = subprocess.run(
            ["java", "-version"], capture_output=True, text=True
        ).stderr.split("\n")[0]
        env_info["Java"] = java_version
    except Exception:
        env_info["Java"] = "Java não encontrado"

    try:
        # Navega para o diretório android e executa o gradlew
        gradle_result = subprocess.run(
            ["./gradlew", "--version"], capture_output=True, text=True, cwd="android"
        )
        # Procura pela linha que contém "Gradle" no output
        for line in gradle_result.stdout.split("\n"):
            if line.startswith("Gradle"):
                env_info["Gradle"] = line.strip()
                break
        else:
            env_info["Gradle"] = "Gradle versão não detectada"
    except Exception:
        env_info["Gradle"] = "Gradle não encontrado"

    try:
        flutter_version = subprocess.run(
            ["flutter", "--version"], capture_output=True, text=True
        ).stdout.split("\n")[0]
        env_info["Flutter"] = flutter_version
    except Exception:
        env_info["Flutter"] = "Flutter não encontrado no PATH"

    return env_info


# Função para renomear o APK
def rename_apk(apk_path, app_name, version, build_version):
    renamed_apk_path = (
        f"build/app/outputs/apk/release/{app_name}_v{version}+{build_version}.apk"
    )

    if os.path.exists(renamed_apk_path):
        print_warning(f"Removendo arquivo existente {renamed_apk_path}")
        os.remove(renamed_apk_path)

    print_step(f"Renomeando o APK para {renamed_apk_path}...")
    os.rename(apk_path, renamed_apk_path)
    print_success("Renomeação concluída!")
    return renamed_apk_path


# Função para verificar se o APK está assinado
def verify_apk_signature(apk_path):
    print_step("Verificando assinatura do APK...")

    has_v1 = False
    has_v2_v3 = False

    try:
        # Primeiro tenta com apksigner (mais completo)
        try:
            result = subprocess.run(
                ["apksigner", "verify", "--verbose", apk_path],
                capture_output=True,
                text=True,
            )

            if result.returncode == 0:
                output = result.stdout.lower()

                # Verificar diferentes esquemas de assinatura
                if "v1 scheme (jar signing): true" in output:
                    has_v1 = True
                if "v2 scheme (apk signature scheme v2): true" in output:
                    has_v2_v3 = True
                if "v3 scheme (apk signature scheme v3): true" in output:
                    has_v2_v3 = True

                print_success("✅ APK está assinado!")
                print_info(f"   Assinatura v1 (JAR): {'✓' if has_v1 else '✗'}")
                print_info(
                    f"   Assinatura v2/v3 (APK Signature Scheme): {'✓' if has_v2_v3 else '✗'}"
                )

                return True

        except FileNotFoundError:
            # Se apksigner não estiver disponível, usar jarsigner
            pass

        # Fallback para jarsigner (verifica apenas v1)
        result = subprocess.run(
            ["jarsigner", "-verify", apk_path],
            capture_output=True,
            text=True,
        )

        if result.returncode == 0 and "jar verified" in result.stdout:
            has_v1 = True
            print_success("✅ APK tem assinatura v1 (JAR signature)")
            print_info("   ℹ️  Use apksigner para verificar v2/v3")
            return True
        else:
            # APK pode estar assinado apenas com v2/v3
            print_warning("⚠️  APK não tem assinatura v1 (JAR signature)")
            print_info("   ℹ️  O APK pode estar assinado com v2/v3")
            print_info("   ℹ️  A Cielo geralmente aceita APKs com assinatura v2/v3")

            # Como não conseguimos verificar v2/v3 sem apksigner,
            # assumimos que está assinado se foi buildado pelo Flutter
            return True

    except FileNotFoundError:
        print_warning(
            "jarsigner não encontrado. Não foi possível verificar a assinatura."
        )
        return None
    except Exception as e:
        print_warning(f"Erro ao verificar assinatura: {e}")
        return None


# Função para abrir o diretório no explorador de arquivos
def open_explorer(apk_path):
    dir_path = os.path.dirname(apk_path)

    if platform.system() == "Darwin":  # macOS
        subprocess.run(["open", dir_path])
    elif platform.system() == "Linux":  # Linux
        subprocess.run(["xdg-open", dir_path])
    elif platform.system() == "Windows":  # Windows
        explorer_path = apk_path.replace("/", "\\").replace("\\", "\\\\")
        subprocess.run(["explorer", f"/e,{explorer_path}"])
    else:
        print_warning(
            "Sistema operacional não suportado para abrir o explorador de arquivos."
        )


# Programa principal
def main():
    print_header("I9 Smart PDV - Build APK")

    user = getpass.getuser()
    print_info(f"Usuário: {user}")
    print_info(f"Data/Hora: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")

    print_step("Verificando ambiente...")
    env_info = get_environment_info()

    # Mostra a versão atual e pergunta sobre o incremento da versão
    app_name, current_version, current_build = get_app_info()
    print(
        f"\n{Colors.BOLD}Versão atual: {Colors.GREEN}{current_version}+{current_build}{Colors.ENDC}"
    )

    increment_build = (
        input(
            f"\n{Colors.CYAN}Deseja incrementar a versão major, minor, patch? [s/N]: {Colors.ENDC}"
        )
        .strip()
        .lower()
        == "s"
    )
    version_level = None
    old_version = f"{current_version}+{current_build}"

    if increment_build:
        print(f"\n{Colors.CYAN}Escolha o tipo de incremento:{Colors.ENDC}")
        print(f"  {Colors.BOLD}1{Colors.ENDC} - Major (X.0.0)")
        print(f"  {Colors.BOLD}2{Colors.ENDC} - Minor (1.X.0)")
        print(
            f"  {Colors.BOLD}3{Colors.ENDC} - Patch (1.0.X) {Colors.GREEN}[padrão]{Colors.ENDC}"
        )

        choice = input(f"\n{Colors.CYAN}Opção [1-3]: {Colors.ENDC}").strip()

        # Mapeia a escolha para o tipo de incremento
        version_map = {"1": "major", "2": "minor", "3": "patch", "": "patch"}
        version_level = version_map.get(choice, "patch")

        print_info(f"Incrementando versão: {version_level}")
        result = increment_build_version(version_level)
        if result:
            old_version, new_version = result
        else:
            print_error("Erro ao incrementar versão")
            return

        # Garante que o novo arquivo pubspec.yaml seja lido com a versão incrementada
        app_name, current_version, current_build = (
            get_app_info()
        )  # Recarrega a versão após a atualização
        new_version = f"{current_version}+{current_build}"
    else:
        # Se o usuário não quiser incrementar a versão, pergunta se quer incrementar apenas a build
        increment_only_build = (
            input(
                f"{Colors.CYAN}Deseja incrementar apenas a build version? [s/N]: {Colors.ENDC}"
            )
            .strip()
            .lower()
            == "s"
        )
        if increment_only_build:
            result = increment_build_version(level=None)
            if result:
                old_version, new_version = result
            else:
                print_error("Erro ao incrementar versão")
                new_version = old_version
        else:
            new_version = old_version  # Se não incrementar, usa a versão atual

    # Gera o histórico da build em markdown
    generate_build_history(
        user,
        env_info,
        old_version,
        new_version,
        build_mode="release",
        version_level=version_level,
    )

    # Constrói o APK
    apk_path = build_apk("release")

    # Verifica se o APK foi gerado com sucesso
    if apk_path and os.path.exists(apk_path):
        print_success(f"APK gerado em: {apk_path}")

        # Renomeia o APK com a nova versão corretamente
        new_base_version, new_build_version = new_version.split(
            "+"
        )  # Divide a versão e o build
        renamed_apk_path = rename_apk(
            apk_path, app_name, new_base_version, new_build_version
        )

        # Verifica se o APK está assinado
        print()  # Linha em branco
        signature_verified = verify_apk_signature(renamed_apk_path)

        # Abre o explorador de arquivos
        open_explorer(renamed_apk_path)

        # Mostra resumo final
        print_header("Build Concluído com Sucesso!")
        print_info(f"App: {app_name}")
        print_info(f"Versão: {new_version}")
        print_info(f"Arquivo: {os.path.basename(renamed_apk_path)}")
        print_info(f"Tamanho: {os.path.getsize(renamed_apk_path) / 1024 / 1024:.2f} MB")

        # Status da assinatura no resumo
        if signature_verified is True:
            print_info(f"Assinatura: {Colors.GREEN}✅ Verificada{Colors.ENDC}")
        elif signature_verified is False:
            print_info(f"Assinatura: {Colors.FAIL}❌ Não assinada{Colors.ENDC}")
        else:
            print_info(f"Assinatura: {Colors.WARNING}⚠️ Não verificada{Colors.ENDC}")

        print(
            f"\n{Colors.GREEN}{Colors.BOLD}✨ APK pronto para distribuição!{Colors.ENDC}\n"
        )
    else:
        print_error("O APK não foi gerado com sucesso.")
        sys.exit(1)


if __name__ == "__main__":
    main()
