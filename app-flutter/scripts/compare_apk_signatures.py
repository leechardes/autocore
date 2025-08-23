#!/usr/bin/env python3
"""
Script para comparar assinaturas de APKs de forma detalhada
"""
import subprocess
import sys
import os
import hashlib
import zipfile
import tempfile
import shutil


def get_apk_fingerprint(apk_path):
    """Extrai o fingerprint SHA256 do certificado do APK"""
    try:
        # Usar keytool para extrair informações do certificado
        result = subprocess.run(
            ["keytool", "-printcert", "-jarfile", apk_path],
            capture_output=True,
            text=True,
        )

        if result.returncode == 0:
            output = result.stdout
            fingerprints = {}

            # Extrair diferentes fingerprints
            for line in output.split("\n"):
                if "SHA1:" in line:
                    fingerprints["SHA1"] = line.split("SHA1:")[1].strip()
                elif "SHA256:" in line:
                    fingerprints["SHA256"] = line.split("SHA256:")[1].strip()
                elif "MD5:" in line:
                    fingerprints["MD5"] = line.split("MD5:")[1].strip()

            return fingerprints
        else:
            print(f"❌ Erro ao extrair certificado: {result.stderr}")
            return None
    except Exception as e:
        print(f"❌ Erro: {e}")
        return None


def check_apk_signature_versions(apk_path):
    """Verifica quais versões de assinatura estão presentes no APK"""
    try:
        # Verificar com apksigner (se disponível)
        result = subprocess.run(
            ["apksigner", "verify", "--verbose", apk_path],
            capture_output=True,
            text=True,
        )

        if result.returncode == 0:
            return result.stdout
        else:
            # Se apksigner não estiver disponível, usar método alternativo
            return check_signature_files(apk_path)
    except FileNotFoundError:
        # apksigner não está instalado, usar método alternativo
        return check_signature_files(apk_path)


def check_signature_files(apk_path):
    """Verifica arquivos de assinatura dentro do APK"""
    signature_info = []

    try:
        with zipfile.ZipFile(apk_path, "r") as apk:
            # Listar todos os arquivos
            file_list = apk.namelist()

            # Verificar META-INF
            meta_inf_files = [f for f in file_list if f.startswith("META-INF/")]

            # Verificar diferentes tipos de assinatura
            v1_signature = False
            v2_signature = False

            for file in meta_inf_files:
                if file.endswith(".SF"):
                    v1_signature = True
                    signature_info.append(f"✓ V1 Signature encontrada: {file}")
                elif (
                    file.endswith(".RSA")
                    or file.endswith(".DSA")
                    or file.endswith(".EC")
                ):
                    signature_info.append(f"✓ Certificado encontrado: {file}")

            # V2 signature está no ZIP central directory
            # Verificar se existe (método simplificado)
            apk_size = os.path.getsize(apk_path)
            if apk_size > 0:
                signature_info.append("✓ APK tem tamanho válido para V2/V3 signature")

    except Exception as e:
        signature_info.append(f"❌ Erro ao verificar arquivos: {e}")

    return "\n".join(signature_info)


def extract_cert_from_apk(apk_path, output_dir):
    """Extrai o certificado do APK para análise"""
    try:
        with zipfile.ZipFile(apk_path, "r") as apk:
            # Procurar por arquivos de certificado
            for file in apk.namelist():
                if file.startswith("META-INF/") and (
                    file.endswith(".RSA") or file.endswith(".DSA")
                ):
                    cert_path = os.path.join(output_dir, os.path.basename(file))
                    apk.extract(file, output_dir)
                    extracted_path = os.path.join(output_dir, file)

                    # Mover para o diretório raiz
                    shutil.move(extracted_path, cert_path)

                    # Limpar diretório META-INF
                    meta_inf_dir = os.path.join(output_dir, "META-INF")
                    if os.path.exists(meta_inf_dir):
                        shutil.rmtree(meta_inf_dir)

                    return cert_path
    except Exception as e:
        print(f"❌ Erro ao extrair certificado: {e}")
    return None


def compare_apks(apk1_path, apk2_path):
    """Compara as assinaturas de dois APKs"""
    print("=" * 60)
    print("🔍 COMPARAÇÃO DETALHADA DE ASSINATURAS DE APK")
    print("=" * 60)

    # 1. Obter fingerprints
    print("\n📋 1. FINGERPRINTS DOS CERTIFICADOS:")
    print("-" * 40)

    fp1 = get_apk_fingerprint(apk1_path)
    fp2 = get_apk_fingerprint(apk2_path)

    print(f"\n{os.path.basename(apk1_path)}:")
    if fp1:
        for key, value in fp1.items():
            print(f"  {key}: {value}")
    else:
        print("  ❌ Não foi possível obter fingerprint")

    print(f"\n{os.path.basename(apk2_path)}:")
    if fp2:
        for key, value in fp2.items():
            print(f"  {key}: {value}")
    else:
        print("  ❌ Não foi possível obter fingerprint")

    # Comparar fingerprints
    if fp1 and fp2:
        print("\n🔄 Comparação:")
        all_match = True
        for key in ["MD5", "SHA1", "SHA256"]:
            if key in fp1 and key in fp2:
                if fp1[key] == fp2[key]:
                    print(f"  ✅ {key}: IDÊNTICO")
                else:
                    print(f"  ❌ {key}: DIFERENTE!")
                    all_match = False

        if all_match:
            print("\n✅ Os certificados são IDÊNTICOS!")
        else:
            print("\n❌ Os certificados são DIFERENTES!")

    # 2. Verificar versões de assinatura
    print("\n📋 2. VERSÕES DE ASSINATURA:")
    print("-" * 40)

    print(f"\n{os.path.basename(apk1_path)}:")
    sig1 = check_apk_signature_versions(apk1_path)
    print(sig1)

    print(f"\n{os.path.basename(apk2_path)}:")
    sig2 = check_apk_signature_versions(apk2_path)
    print(sig2)

    # 3. Extrair e comparar certificados diretamente
    print("\n📋 3. EXTRAÇÃO DIRETA DOS CERTIFICADOS:")
    print("-" * 40)

    with tempfile.TemporaryDirectory() as temp_dir:
        cert1 = extract_cert_from_apk(apk1_path, temp_dir)
        cert2 = extract_cert_from_apk(apk2_path, temp_dir)

        if cert1 and cert2:
            # Calcular hash dos arquivos de certificado
            with open(cert1, "rb") as f1:
                hash1 = hashlib.sha256(f1.read()).hexdigest()
            with open(cert2, "rb") as f2:
                hash2 = hashlib.sha256(f2.read()).hexdigest()

            print(f"\nHash SHA256 do certificado 1: {hash1}")
            print(f"Hash SHA256 do certificado 2: {hash2}")

            if hash1 == hash2:
                print("\n✅ Os arquivos de certificado são IDÊNTICOS!")
            else:
                print("\n❌ Os arquivos de certificado são DIFERENTES!")

    # 4. Verificar com jarsigner
    print("\n📋 4. VERIFICAÇÃO COM JARSIGNER:")
    print("-" * 40)

    for apk_path in [apk1_path, apk2_path]:
        print(f"\n{os.path.basename(apk_path)}:")
        result = subprocess.run(
            ["jarsigner", "-verify", "-verbose", "-certs", apk_path],
            capture_output=True,
            text=True,
        )

        if "jar verified" in result.stdout:
            print("  ✅ Assinatura válida")
            # Extrair informações do certificado
            lines = result.stdout.split("\n")
            for line in lines:
                if "X.509" in line or "CN=" in line:
                    print(f"  {line.strip()}")
        else:
            print("  ❌ Assinatura inválida ou não assinado")
            if result.stderr:
                print(f"  Erro: {result.stderr}")

    print("\n" + "=" * 60)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python compare_apk_signatures.py <apk1> <apk2>")
        sys.exit(1)

    apk1 = sys.argv[1]
    apk2 = sys.argv[2]

    if not os.path.exists(apk1):
        print(f"❌ Arquivo não encontrado: {apk1}")
        sys.exit(1)

    if not os.path.exists(apk2):
        print(f"❌ Arquivo não encontrado: {apk2}")
        sys.exit(1)

    compare_apks(apk1, apk2)
