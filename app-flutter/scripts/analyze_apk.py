import os
import logging
import sys

# Desabilitar loguru completamente antes de importar qualquer coisa
os.environ["LOGURU_AUTOINIT"] = "False"

# Configurar logging para silenciar tudo
logging.basicConfig(level=logging.CRITICAL)
logging.getLogger().setLevel(logging.CRITICAL)

# Desabilitar stderr temporariamente durante import
stderr = sys.stderr
sys.stderr = open(os.devnull, "w")

try:
    from androguard.misc import AnalyzeAPK
finally:
    # Restaurar stderr
    sys.stderr = stderr


def analisar_apk(caminho_apk):
    print(f"\n📦 Analisando APK: {caminho_apk}")

    try:
        a, d, dx = AnalyzeAPK(caminho_apk)
    except Exception as e:
        print(f"❌ Erro ao analisar APK: {e}")
        return

    print(f"📌 Package: {a.get_package()}")
    print(f"🔢 Version Code: {a.get_androidversion_code()}")
    print(f"🏷️ Version Name: {a.get_androidversion_name()}")
    print(f"📱 Min SDK Version: {a.get_min_sdk_version()}")
    print(f"🎯 Target SDK Version: {a.get_target_sdk_version()}\n")

    print("🔐 Permissões declaradas:")
    for perm in a.get_permissions():
        print(f" - {perm}")

    print("\n🔗 DeepLinks (VIEW intents):")
    for activity in a.get_activities():
        try:
            filters = a.get_intent_filters("activity", activity)
            for f in filters:
                if isinstance(f, dict) and "action" in f:
                    for action in f["action"]:
                        if "VIEW" in action:
                            print(f" - {activity}: {f}")
        except Exception as e:
            print(f" [!] Erro ao analisar intents de {activity}: {e}")

    print("\n🔏 Assinatura:")
    # Verificar se o APK está assinado
    try:
        certs = a.get_certificates()
        if certs:
            print(f" ✅ APK assinado - {len(certs)} certificado(s) encontrado(s)")
            for i, cert in enumerate(certs):
                print(f"\n 📜 Certificado {i+1}:")
                try:
                    # Tentar diferentes formas de acessar as informações
                    if hasattr(cert, "issuer"):
                        issuer = (
                            str(cert.issuer).split("CN=")[-1].split(",")[0]
                            if "CN=" in str(cert.issuer)
                            else str(cert.issuer)
                        )
                        print(f"    - Emissor: {issuer}")
                    if hasattr(cert, "subject"):
                        subject = (
                            str(cert.subject).split("CN=")[-1].split(",")[0]
                            if "CN=" in str(cert.subject)
                            else str(cert.subject)
                        )
                        print(f"    - Sujeito: {subject}")
                    if hasattr(cert, "serial_number"):
                        print(f"    - Serial: {cert.serial_number}")

                    # Tentar obter informações de validade
                    if hasattr(cert, "not_valid_before"):
                        print(f"    - Válido desde: {cert.not_valid_before}")
                    if hasattr(cert, "not_valid_after"):
                        print(f"    - Válido até: {cert.not_valid_after}")
                except Exception as e:
                    print(f"    - Erro ao processar certificado: {e}")
        else:
            print(" ❌ APK NÃO ASSINADO")
    except Exception as e:
        print(f" ⚠️ Não foi possível verificar assinatura: {e}")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        caminho = sys.argv[1]
    else:
        caminho = input("📂 Caminho do APK: ").strip()
    analisar_apk(caminho)
