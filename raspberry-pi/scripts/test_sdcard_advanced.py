#!/usr/bin/env python3
"""
Script Avançado de Teste de SD Card para Raspberry Pi
Detecta problemas comuns e fornece diagnóstico detalhado
"""

import os
import sys
import time
import hashlib
import subprocess
import json
from pathlib import Path
from datetime import datetime
import random
import string

class SDCardTester:
    def __init__(self):
        self.results = {
            "timestamp": datetime.now().isoformat(),
            "tests": {},
            "errors": [],
            "warnings": [],
            "info": {}
        }
        self.test_dir = Path("/tmp/sdcard_test_" + str(os.getpid()))
        
    def run_command(self, cmd):
        """Executa comando e retorna output"""
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            return result.stdout.strip(), result.stderr.strip(), result.returncode
        except Exception as e:
            return "", str(e), 1
    
    def print_header(self, title):
        """Imprime cabeçalho formatado"""
        print("\n" + "="*50)
        print(f" {title}")
        print("="*50)
    
    def print_status(self, message, status="info"):
        """Imprime mensagem com status colorido"""
        colors = {
            "success": "\033[92m✓\033[0m",
            "error": "\033[91m✗\033[0m",
            "warning": "\033[93m⚠\033[0m",
            "info": "\033[94mℹ\033[0m"
        }
        print(f"{colors.get(status, '')} {message}")
    
    def get_sdcard_info(self):
        """Obtém informações do SD Card"""
        self.print_header("INFORMAÇÕES DO SD CARD")
        
        info = {}
        
        # Verificar se SD card existe
        if not os.path.exists("/dev/mmcblk0"):
            self.print_status("SD Card não detectado!", "error")
            self.results["errors"].append("SD Card não detectado")
            return False
        
        # Modelo do cartão
        try:
            with open("/sys/block/mmcblk0/device/name", "r") as f:
                info["model"] = f.read().strip()
                self.print_status(f"Modelo: {info['model']}", "info")
        except:
            info["model"] = "Desconhecido"
        
        # Serial
        try:
            with open("/sys/block/mmcblk0/device/serial", "r") as f:
                info["serial"] = f.read().strip()
                self.print_status(f"Serial: {info['serial']}", "info")
        except:
            info["serial"] = "Desconhecido"
        
        # Tamanho
        stdout, _, _ = self.run_command("sudo fdisk -l /dev/mmcblk0 2>/dev/null | grep 'Disk /dev/mmcblk0'")
        if stdout:
            size = stdout.split(":")[1].split(",")[0].strip()
            info["size"] = size
            self.print_status(f"Tamanho: {size}", "info")
        
        # Velocidade do barramento
        try:
            with open("/sys/block/mmcblk0/device/csd", "r") as f:
                csd = f.read().strip()
                info["csd"] = csd
        except:
            pass
        
        # Classe de velocidade
        try:
            with open("/sys/block/mmcblk0/device/ssr", "r") as f:
                ssr = f.read().strip()
                # Decodificar classe de velocidade do SSR
                if len(ssr) >= 2:
                    speed_class = int(ssr[0:2], 16) & 0x0F
                    info["speed_class"] = f"Class {speed_class}"
                    self.print_status(f"Classe de velocidade: Class {speed_class}", "info")
        except:
            pass
        
        self.results["info"] = info
        return True
    
    def check_filesystem(self):
        """Verifica sistema de arquivos"""
        self.print_header("VERIFICAÇÃO DO SISTEMA DE ARQUIVOS")
        
        test_result = {"passed": True, "details": {}}
        
        # Verificar montagem
        stdout, _, _ = self.run_command("mount | grep mmcblk0p2")
        if stdout:
            self.print_status("Sistema de arquivos montado", "success")
            test_result["details"]["mounted"] = True
        else:
            self.print_status("Sistema de arquivos não montado", "error")
            test_result["passed"] = False
            test_result["details"]["mounted"] = False
        
        # Verificar espaço
        stdout, _, _ = self.run_command("df -h / | tail -1")
        if stdout:
            parts = stdout.split()
            if len(parts) >= 5:
                usage = int(parts[4].replace("%", ""))
                test_result["details"]["disk_usage"] = f"{usage}%"
                
                if usage > 90:
                    self.print_status(f"Espaço crítico: {usage}% usado", "error")
                    test_result["passed"] = False
                elif usage > 80:
                    self.print_status(f"Espaço alto: {usage}% usado", "warning")
                    self.results["warnings"].append(f"Espaço em disco alto: {usage}%")
                else:
                    self.print_status(f"Espaço OK: {usage}% usado", "success")
        
        # Verificar erros no dmesg
        stdout, _, _ = self.run_command("sudo dmesg | grep -i mmcblk0 | grep -iE 'error|fail|corrupt' | wc -l")
        errors = int(stdout) if stdout.isdigit() else 0
        test_result["details"]["kernel_errors"] = errors
        
        if errors > 0:
            self.print_status(f"Encontrados {errors} erros no kernel", "warning")
            self.results["warnings"].append(f"{errors} erros relacionados ao SD Card no kernel")
            
            # Mostrar últimos erros
            stdout, _, _ = self.run_command("sudo dmesg | grep -i mmcblk0 | grep -iE 'error|fail|corrupt' | tail -3")
            if stdout:
                print("\nÚltimos erros:")
                for line in stdout.split("\n"):
                    print(f"  {line}")
        else:
            self.print_status("Nenhum erro no kernel", "success")
        
        self.results["tests"]["filesystem"] = test_result
        return test_result["passed"]
    
    def test_read_speed(self):
        """Testa velocidade de leitura"""
        self.print_header("TESTE DE VELOCIDADE DE LEITURA")
        
        test_result = {"passed": True, "details": {}}
        
        # Teste com dd
        self.print_status("Testando leitura sequencial...", "info")
        stdout, stderr, _ = self.run_command(
            "sudo dd if=/dev/mmcblk0p2 of=/dev/null bs=1M count=100 iflag=direct 2>&1"
        )
        
        output = stdout + stderr
        if "MB/s" in output or "MiB/s" in output:
            # Extrair velocidade
            for line in output.split("\n"):
                if "MB/s" in line or "MiB/s" in line:
                    speed_str = line.split(",")[-1].strip()
                    test_result["details"]["sequential_read"] = speed_str
                    
                    # Verificar se velocidade é aceitável (>10MB/s)
                    try:
                        speed = float(speed_str.split()[0])
                        if speed < 10:
                            self.print_status(f"Velocidade baixa: {speed_str}", "warning")
                            self.results["warnings"].append(f"Velocidade de leitura baixa: {speed_str}")
                        else:
                            self.print_status(f"Velocidade: {speed_str}", "success")
                    except:
                        self.print_status(f"Velocidade: {speed_str}", "info")
                    break
        
        # Teste de leitura aleatória
        self.print_status("Testando leitura aleatória...", "info")
        test_file = "/tmp/random_read_test"
        
        # Criar arquivo de teste se não existir
        if not os.path.exists(test_file):
            self.run_command(f"dd if=/dev/urandom of={test_file} bs=1M count=10 2>/dev/null")
        
        start = time.time()
        for _ in range(100):
            offset = random.randint(0, 10485760 - 4096)  # 10MB - 4KB
            self.run_command(f"dd if={test_file} of=/dev/null bs=4K count=1 skip={offset//4096} 2>/dev/null")
        duration = time.time() - start
        
        iops = 100 / duration
        test_result["details"]["random_read_iops"] = f"{iops:.1f} IOPS"
        
        if iops < 50:
            self.print_status(f"IOPS baixo: {iops:.1f}", "warning")
        else:
            self.print_status(f"IOPS: {iops:.1f}", "success")
        
        self.results["tests"]["read_speed"] = test_result
        return test_result["passed"]
    
    def test_write_speed(self):
        """Testa velocidade de escrita"""
        self.print_header("TESTE DE VELOCIDADE DE ESCRITA")
        
        test_result = {"passed": True, "details": {}}
        
        # Teste de escrita sequencial
        self.print_status("Testando escrita sequencial...", "info")
        test_file = "/tmp/write_speed_test"
        
        stdout, stderr, _ = self.run_command(
            f"dd if=/dev/zero of={test_file} bs=1M count=50 conv=fdatasync 2>&1"
        )
        
        output = stdout + stderr
        if "MB/s" in output or "MiB/s" in output:
            for line in output.split("\n"):
                if "MB/s" in line or "MiB/s" in line:
                    speed_str = line.split(",")[-1].strip()
                    test_result["details"]["sequential_write"] = speed_str
                    
                    try:
                        speed = float(speed_str.split()[0])
                        if speed < 5:
                            self.print_status(f"Velocidade muito baixa: {speed_str}", "error")
                            test_result["passed"] = False
                        elif speed < 10:
                            self.print_status(f"Velocidade baixa: {speed_str}", "warning")
                        else:
                            self.print_status(f"Velocidade: {speed_str}", "success")
                    except:
                        self.print_status(f"Velocidade: {speed_str}", "info")
                    break
        
        # Limpar
        os.remove(test_file) if os.path.exists(test_file) else None
        
        # Teste com arquivos pequenos
        self.print_status("Testando escrita de arquivos pequenos...", "info")
        self.test_dir.mkdir(exist_ok=True)
        
        start = time.time()
        for i in range(100):
            (self.test_dir / f"test_{i}.txt").write_text(f"Test content {i}\n")
        
        # Forçar sync
        os.sync()
        duration = time.time() - start
        
        files_per_sec = 100 / duration
        test_result["details"]["small_files"] = f"{files_per_sec:.1f} arquivos/s"
        
        if files_per_sec < 10:
            self.print_status(f"Performance baixa: {files_per_sec:.1f} arquivos/s", "warning")
        else:
            self.print_status(f"Performance: {files_per_sec:.1f} arquivos/s", "success")
        
        # Limpar
        for f in self.test_dir.glob("*"):
            f.unlink()
        self.test_dir.rmdir()
        
        self.results["tests"]["write_speed"] = test_result
        return test_result["passed"]
    
    def test_integrity(self):
        """Testa integridade de dados"""
        self.print_header("TESTE DE INTEGRIDADE")
        
        test_result = {"passed": True, "details": {}}
        
        self.print_status("Criando arquivo de teste...", "info")
        test_file = "/tmp/integrity_test"
        test_size = 100  # MB
        
        # Gerar dados aleatórios
        random_data = os.urandom(1024 * 1024)  # 1MB
        
        # Escrever arquivo
        with open(test_file, "wb") as f:
            for _ in range(test_size):
                f.write(random_data)
        
        # Calcular hash original
        self.print_status("Calculando checksum original...", "info")
        hash1 = hashlib.md5()
        with open(test_file, "rb") as f:
            while chunk := f.read(8192):
                hash1.update(chunk)
        original_hash = hash1.hexdigest()
        
        # Limpar cache
        self.run_command("echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null")
        
        # Ler e verificar
        self.print_status("Verificando integridade...", "info")
        hash2 = hashlib.md5()
        with open(test_file, "rb") as f:
            while chunk := f.read(8192):
                hash2.update(chunk)
        verify_hash = hash2.hexdigest()
        
        if original_hash == verify_hash:
            self.print_status("Integridade verificada com sucesso", "success")
            test_result["details"]["checksum_match"] = True
        else:
            self.print_status("FALHA na verificação de integridade!", "error")
            test_result["passed"] = False
            test_result["details"]["checksum_match"] = False
            self.results["errors"].append("Falha na verificação de integridade")
        
        # Limpar
        os.remove(test_file) if os.path.exists(test_file) else None
        
        self.results["tests"]["integrity"] = test_result
        return test_result["passed"]
    
    def check_smart_data(self):
        """Verifica dados SMART se disponível"""
        self.print_header("DADOS SMART (se disponível)")
        
        # SD Cards geralmente não suportam SMART, mas vamos tentar
        stdout, stderr, code = self.run_command("sudo smartctl -a /dev/mmcblk0 2>/dev/null")
        
        if code == 0 and "SMART" in stdout:
            self.print_status("Dados SMART disponíveis", "info")
            print(stdout)
        else:
            self.print_status("Dados SMART não disponíveis para SD Card", "info")
    
    def generate_report(self):
        """Gera relatório final"""
        self.print_header("RELATÓRIO FINAL")
        
        # Contar problemas
        total_tests = len(self.results["tests"])
        passed_tests = sum(1 for t in self.results["tests"].values() if t.get("passed", False))
        
        print(f"\nTestes executados: {total_tests}")
        print(f"Testes aprovados: {passed_tests}")
        print(f"Erros encontrados: {len(self.results['errors'])}")
        print(f"Avisos: {len(self.results['warnings'])}")
        
        if self.results["errors"]:
            print("\n\033[91mERROS:\033[0m")
            for error in self.results["errors"]:
                print(f"  ✗ {error}")
        
        if self.results["warnings"]:
            print("\n\033[93mAVISOS:\033[0m")
            for warning in self.results["warnings"]:
                print(f"  ⚠ {warning}")
        
        # Diagnóstico
        print("\n" + "="*50)
        print(" DIAGNÓSTICO")
        print("="*50)
        
        if not self.results["errors"] and not self.results["warnings"]:
            print("\n\033[92m✓ SD CARD FUNCIONANDO PERFEITAMENTE!\033[0m")
            print("\nRecomendações:")
            print("• Continue usando este cartão")
            print("• Faça backups regulares")
            print("• Monitore o desempenho periodicamente")
        elif self.results["errors"]:
            print("\n\033[91m✗ SD CARD COM PROBLEMAS GRAVES!\033[0m")
            print("\nAções necessárias:")
            print("1. Faça backup imediato dos dados")
            print("2. Substitua o SD Card")
            print("3. Use cartão Classe 10 ou superior")
            print("4. Verifique se o cartão é genuíno")
        else:
            print("\n\033[93m⚠ SD CARD COM AVISOS\033[0m")
            print("\nRecomendações:")
            print("• Monitore o cartão frequentemente")
            print("• Considere substituir em breve")
            print("• Faça backups frequentes")
        
        # Salvar relatório JSON
        report_file = f"/tmp/sdcard_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, "w") as f:
            json.dump(self.results, f, indent=2)
        print(f"\nRelatório salvo em: {report_file}")
    
    def run_all_tests(self):
        """Executa todos os testes"""
        print("\n" + "="*50)
        print(" TESTE COMPLETO DE SD CARD")
        print(" Raspberry Pi Zero 2W")
        print("="*50)
        print(f"\nIniciado em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Verificar se está rodando como root para alguns testes
        if os.geteuid() != 0:
            print("\n\033[93m⚠ Alguns testes requerem sudo\033[0m")
            print("Execute com: sudo python3 test_sdcard_advanced.py")
        
        # Executar testes
        if not self.get_sdcard_info():
            print("\n\033[91mTeste abortado: SD Card não detectado\033[0m")
            return
        
        self.check_filesystem()
        self.test_read_speed()
        self.test_write_speed()
        self.test_integrity()
        self.check_smart_data()
        
        # Gerar relatório
        self.generate_report()
        
        print(f"\nFinalizado em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    tester = SDCardTester()
    tester.run_all_tests()