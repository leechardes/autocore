#!/usr/bin/env python3
"""
Script de manutenção para AutoCore Gateway
"""
import os
import sys
import argparse
import subprocess
import shutil
from pathlib import Path
from datetime import datetime
import json

def get_gateway_root():
    """Retorna o diretório raiz do gateway"""
    return Path(__file__).parent.parent

def get_pid_file():
    """Retorna o arquivo PID do gateway"""
    return get_gateway_root() / "tmp" / "gateway.pid"

def is_gateway_running():
    """Verifica se o gateway está rodando"""
    pid_file = get_pid_file()
    if not pid_file.exists():
        return False
    
    try:
        with open(pid_file, 'r') as f:
            pid = int(f.read().strip())
        
        # Verificar se o processo existe
        os.kill(pid, 0)  # Signal 0 apenas verifica se o processo existe
        return True
    except (OSError, ValueError):
        # Remover PID file inválido
        if pid_file.exists():
            pid_file.unlink()
        return False

def get_gateway_stats():
    """Retorna estatísticas do gateway"""
    stats = {
        "timestamp": datetime.now().isoformat(),
        "gateway_running": is_gateway_running(),
        "uptime": None,
        "log_size": 0,
        "temp_files": 0
    }
    
    # Tamanho do log
    log_file = get_gateway_root() / "logs" / "gateway.log"
    if log_file.exists():
        stats["log_size"] = log_file.stat().st_size
    
    # Arquivos temporários
    temp_dir = get_gateway_root() / "tmp"
    if temp_dir.exists():
        stats["temp_files"] = len(list(temp_dir.glob("*")))
    
    # PID e uptime
    if stats["gateway_running"]:
        try:
            pid_file = get_pid_file()
            if pid_file.exists():
                # Calcular uptime baseado na criação do arquivo PID
                created = datetime.fromtimestamp(pid_file.stat().st_ctime)
                uptime = datetime.now() - created
                stats["uptime"] = str(uptime).split('.')[0]  # Remove microsegundos
        except Exception:
            pass
    
    return stats

def clean_logs(days=7):
    """Limpa logs antigos"""
    logs_dir = get_gateway_root() / "logs"
    if not logs_dir.exists():
        return 0
    
    count = 0
    cutoff_time = datetime.now().timestamp() - (days * 24 * 3600)
    
    for log_file in logs_dir.glob("*.log.*"):
        if log_file.stat().st_mtime < cutoff_time:
            log_file.unlink()
            count += 1
            print(f"🗑️  Removido: {log_file.name}")
    
    return count

def clean_temp_files():
    """Limpa arquivos temporários"""
    temp_dir = get_gateway_root() / "tmp"
    if not temp_dir.exists():
        return 0
    
    count = 0
    for temp_file in temp_dir.glob("*"):
        if temp_file.name != "gateway.pid" or not is_gateway_running():
            try:
                temp_file.unlink()
                count += 1
                print(f"🗑️  Removido: {temp_file.name}")
            except Exception as e:
                print(f"❌ Erro ao remover {temp_file.name}: {e}")
    
    return count

def rotate_logs():
    """Rotaciona o log principal"""
    log_file = get_gateway_root() / "logs" / "gateway.log"
    if not log_file.exists():
        print("📋 Nenhum log para rotacionar")
        return
    
    # Se o log está muito grande (>10MB), rotacionar
    if log_file.stat().st_size > 10 * 1024 * 1024:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        rotated_file = log_file.parent / f"gateway.log.{timestamp}"
        
        shutil.move(str(log_file), str(rotated_file))
        print(f"📋 Log rotacionado: {rotated_file.name}")
        
        # Comprimir log antigo
        try:
            subprocess.run(['gzip', str(rotated_file)], check=True)
            print(f"📦 Log comprimido: {rotated_file.name}.gz")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("⚠️  Compressão não disponível (gzip não encontrado)")

def backup_config():
    """Cria backup das configurações"""
    gateway_root = get_gateway_root()
    backup_dir = gateway_root.parent / "backups" / "gateway"
    backup_dir.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_name = f"gateway_config_{timestamp}.tar.gz"
    backup_path = backup_dir / backup_name
    
    # Arquivos para backup
    files_to_backup = [
        ".env",
        "requirements.txt",
        "docs/",
        "src/",
        "scripts/",
        "Makefile"
    ]
    
    cmd = ["tar", "-czf", str(backup_path)] + [
        f for f in files_to_backup 
        if (gateway_root / f).exists()
    ]
    
    try:
        subprocess.run(cmd, cwd=gateway_root, check=True)
        print(f"💾 Backup criado: {backup_path}")
        return backup_path
    except subprocess.CalledProcessError as e:
        print(f"❌ Erro ao criar backup: {e}")
        return None

def check_dependencies():
    """Verifica dependências do sistema"""
    checks = []
    
    # Python version
    python_version = f"{sys.version_info.major}.{sys.version_info.minor}"
    checks.append({
        "name": "Python Version",
        "status": "✅" if sys.version_info >= (3, 9) else "❌",
        "value": python_version,
        "requirement": "≥3.9"
    })
    
    # MQTT broker
    try:
        result = subprocess.run(['mosquitto_pub', '--help'], 
                              capture_output=True, timeout=5)
        mqtt_status = "✅" if result.returncode == 0 else "❌"
    except:
        mqtt_status = "❌"
    
    checks.append({
        "name": "MQTT Client",
        "status": mqtt_status,
        "value": "mosquitto-clients",
        "requirement": "installed"
    })
    
    # Disk space
    gateway_root = get_gateway_root()
    try:
        disk_usage = shutil.disk_usage(str(gateway_root))
        free_gb = disk_usage.free / (1024**3)
        disk_status = "✅" if free_gb > 1 else "⚠️"
    except:
        free_gb = 0
        disk_status = "❌"
    
    checks.append({
        "name": "Disk Space",
        "status": disk_status,
        "value": f"{free_gb:.1f}GB free",
        "requirement": ">1GB"
    })
    
    return checks

def main():
    parser = argparse.ArgumentParser(description='Manutenção do AutoCore Gateway')
    parser.add_argument('action', choices=[
        'status', 'clean', 'rotate-logs', 'backup', 'check-deps', 'full'
    ], help='Ação a executar')
    parser.add_argument('--days', type=int, default=7, 
                       help='Dias para limpeza de logs (padrão: 7)')
    parser.add_argument('--json', action='store_true',
                       help='Output em formato JSON')
    
    args = parser.parse_args()
    
    if args.action == 'status':
        stats = get_gateway_stats()
        if args.json:
            print(json.dumps(stats, indent=2))
        else:
            print("📊 Status do AutoCore Gateway:")
            print(f"   Gateway: {'🟢 Rodando' if stats['gateway_running'] else '🔴 Parado'}")
            if stats['uptime']:
                print(f"   Uptime: {stats['uptime']}")
            print(f"   Log: {stats['log_size']/1024:.1f}KB")
            print(f"   Arquivos temp: {stats['temp_files']}")
    
    elif args.action == 'clean':
        print("🧹 Iniciando limpeza...")
        logs_removed = clean_logs(args.days)
        temp_removed = clean_temp_files()
        print(f"✅ Limpeza concluída: {logs_removed} logs + {temp_removed} temp files removidos")
    
    elif args.action == 'rotate-logs':
        print("📋 Rotacionando logs...")
        rotate_logs()
        print("✅ Rotação concluída")
    
    elif args.action == 'backup':
        print("💾 Criando backup...")
        backup_path = backup_config()
        if backup_path:
            print("✅ Backup concluído")
        else:
            sys.exit(1)
    
    elif args.action == 'check-deps':
        print("🔍 Verificando dependências...")
        checks = check_dependencies()
        if args.json:
            print(json.dumps(checks, indent=2))
        else:
            for check in checks:
                print(f"   {check['status']} {check['name']}: {check['value']} ({check['requirement']})")
    
    elif args.action == 'full':
        print("🔧 Manutenção completa...")
        
        # Status
        stats = get_gateway_stats()
        print(f"📊 Gateway: {'🟢 Rodando' if stats['gateway_running'] else '🔴 Parado'}")
        
        # Limpeza
        print("🧹 Limpando arquivos...")
        clean_logs(args.days)
        clean_temp_files()
        
        # Rotação
        print("📋 Rotacionando logs...")
        rotate_logs()
        
        # Backup
        print("💾 Criando backup...")
        backup_config()
        
        # Dependências
        print("🔍 Verificando dependências...")
        checks = check_dependencies()
        failed_checks = [c for c in checks if c['status'] == '❌']
        if failed_checks:
            print("⚠️  Dependências com problemas encontradas")
            for check in failed_checks:
                print(f"   ❌ {check['name']}: {check['value']}")
        
        print("✅ Manutenção completa finalizada")

if __name__ == '__main__':
    main()