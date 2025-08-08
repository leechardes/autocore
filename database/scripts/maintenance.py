#!/usr/bin/env python3
"""
Scripts de manutenção do banco de dados AutoCore
Mantém o SQLite otimizado e pequeno para rodar bem no Raspberry Pi Zero
"""
import os
import sys
import sqlite3
import argparse
from datetime import datetime, timedelta
from pathlib import Path

# Adiciona o path do projeto
sys.path.append(str(Path(__file__).parent.parent.parent))

from database.shared.connection import get_db, DB_PATH, get_db_size
from database.shared.repositories import telemetry, events

class DatabaseMaintenance:
    """Classe para manutenção do banco SQLite"""
    
    def __init__(self):
        self.db_path = DB_PATH
        
    def cleanup_telemetry(self, days: int = 7) -> dict:
        """
        Remove dados de telemetria antigos
        Mantém apenas últimos X dias (padrão 7)
        """
        print(f"🧹 Limpando telemetria com mais de {days} dias...")
        
        # Conta registros antes
        with get_db() as conn:
            before = conn.execute("SELECT COUNT(*) FROM telemetry_data").fetchone()[0]
            
            # Remove dados antigos
            deleted = conn.execute("""
                DELETE FROM telemetry_data 
                WHERE timestamp < datetime('now', '-{} days')
            """.format(days)).rowcount
            
            after = conn.execute("SELECT COUNT(*) FROM telemetry_data").fetchone()[0]
        
        return {
            'before': before,
            'after': after,
            'deleted': deleted,
            'reduction_percent': round((deleted / before * 100) if before > 0 else 0, 2)
        }
    
    def cleanup_logs(self, days: int = 30) -> dict:
        """
        Remove logs antigos, mantendo erros e eventos de segurança
        """
        print(f"📋 Limpando logs com mais de {days} dias...")
        
        with get_db() as conn:
            before = conn.execute("SELECT COUNT(*) FROM event_logs").fetchone()[0]
            
            # Remove logs antigos (exceto erros e segurança)
            deleted = conn.execute("""
                DELETE FROM event_logs 
                WHERE timestamp < datetime('now', '-{} days')
                AND event_type NOT IN ('error', 'warning', 'security', 'critical')
            """.format(days)).rowcount
            
            after = conn.execute("SELECT COUNT(*) FROM event_logs").fetchone()[0]
        
        return {
            'before': before,
            'after': after,
            'deleted': deleted,
            'reduction_percent': round((deleted / before * 100) if before > 0 else 0, 2)
        }
    
    def aggregate_telemetry(self, days: int = 7):
        """
        Agrega dados antigos de telemetria em médias horárias
        Reduz drasticamente o tamanho mantendo informação útil
        """
        print(f"📊 Agregando telemetria com mais de {days} dias...")
        
        with get_db() as conn:
            # Cria tabela de agregação se não existir
            conn.execute("""
                CREATE TABLE IF NOT EXISTS telemetry_hourly (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    device_id INTEGER NOT NULL,
                    data_type VARCHAR(50) NOT NULL,
                    data_key VARCHAR(100) NOT NULL,
                    hour_timestamp TIMESTAMP NOT NULL,
                    avg_value REAL,
                    min_value REAL,
                    max_value REAL,
                    count INTEGER,
                    unit VARCHAR(20),
                    UNIQUE(device_id, data_type, data_key, hour_timestamp)
                )
            """)
            
            # Agrega dados antigos
            conn.execute("""
                INSERT OR REPLACE INTO telemetry_hourly 
                SELECT 
                    NULL as id,
                    device_id,
                    data_type,
                    data_key,
                    strftime('%Y-%m-%d %H:00:00', timestamp) as hour_timestamp,
                    AVG(CAST(data_value AS REAL)) as avg_value,
                    MIN(CAST(data_value AS REAL)) as min_value,
                    MAX(CAST(data_value AS REAL)) as max_value,
                    COUNT(*) as count,
                    unit
                FROM telemetry_data
                WHERE timestamp < datetime('now', '-{} days')
                GROUP BY device_id, data_type, data_key, 
                         strftime('%Y-%m-%d %H:00:00', timestamp), unit
            """.format(days))
            
            # Remove dados originais que foram agregados
            deleted = conn.execute("""
                DELETE FROM telemetry_data 
                WHERE timestamp < datetime('now', '-{} days')
            """.format(days)).rowcount
            
            aggregated = conn.execute("SELECT COUNT(*) FROM telemetry_hourly").fetchone()[0]
        
        return {
            'deleted_raw': deleted,
            'aggregated_records': aggregated,
            'compression_ratio': f"{deleted/aggregated:.1f}x" if aggregated > 0 else "N/A"
        }
    
    def vacuum_database(self) -> dict:
        """
        Executa VACUUM para recuperar espaço em disco
        Desfragmenta o banco de dados
        """
        print("🔧 Executando VACUUM no banco de dados...")
        
        size_before = get_db_size()
        
        with get_db() as conn:
            conn.execute("VACUUM")
            conn.execute("ANALYZE")  # Atualiza estatísticas
        
        size_after = get_db_size()
        
        return {
            'size_before_mb': size_before['total_size_mb'],
            'size_after_mb': size_after['total_size_mb'],
            'space_saved_mb': round(
                size_before['total_size_mb'] - size_after['total_size_mb'], 2
            )
        }
    
    def optimize_indexes(self):
        """
        Recria índices para melhor performance
        """
        print("📈 Otimizando índices...")
        
        with get_db() as conn:
            # Reindex todas as tabelas
            conn.execute("REINDEX")
            
            # Atualiza estatísticas do query planner
            conn.execute("ANALYZE")
        
        return {'status': 'optimized'}
    
    def full_maintenance(self, telemetry_days: int = 7, log_days: int = 30,
                        aggregate: bool = True) -> dict:
        """
        Executa manutenção completa
        """
        print("\n" + "="*50)
        print("🚀 MANUTENÇÃO COMPLETA DO BANCO DE DADOS")
        print("="*50 + "\n")
        
        results = {}
        
        # 1. Limpa telemetria
        results['telemetry'] = self.cleanup_telemetry(telemetry_days)
        print(f"✅ Telemetria: {results['telemetry']['deleted']} registros removidos")
        
        # 2. Agrega dados antigos
        if aggregate:
            results['aggregation'] = self.aggregate_telemetry(telemetry_days)
            print(f"✅ Agregação: {results['aggregation']['compression_ratio']} de compressão")
        
        # 3. Limpa logs
        results['logs'] = self.cleanup_logs(log_days)
        print(f"✅ Logs: {results['logs']['deleted']} registros removidos")
        
        # 4. Vacuum
        results['vacuum'] = self.vacuum_database()
        print(f"✅ Vacuum: {results['vacuum']['space_saved_mb']} MB recuperados")
        
        # 5. Otimiza índices
        results['indexes'] = self.optimize_indexes()
        print("✅ Índices otimizados")
        
        # Status final
        final_size = get_db_size()
        results['final_size'] = final_size
        
        print("\n" + "="*50)
        print("📊 RESULTADO FINAL")
        print("="*50)
        print(f"Tamanho do banco: {final_size['total_size_mb']} MB")
        print(f"Localização: {final_size['path']}")
        print("✅ Manutenção completa com sucesso!\n")
        
        return results
    
    def get_statistics(self) -> dict:
        """
        Retorna estatísticas do banco de dados
        """
        with get_db() as conn:
            stats = {
                'devices': conn.execute("SELECT COUNT(*) FROM devices WHERE is_active=1").fetchone()[0],
                'telemetry_records': conn.execute("SELECT COUNT(*) FROM telemetry_data").fetchone()[0],
                'telemetry_hourly': conn.execute(
                    "SELECT COUNT(*) FROM telemetry_hourly WHERE 1=1"
                ).fetchone()[0] if conn.execute(
                    "SELECT name FROM sqlite_master WHERE type='table' AND name='telemetry_hourly'"
                ).fetchone() else 0,
                'event_logs': conn.execute("SELECT COUNT(*) FROM event_logs").fetchone()[0],
                'relay_channels': conn.execute("SELECT COUNT(*) FROM relay_channels").fetchone()[0],
                'screens': conn.execute("SELECT COUNT(*) FROM screens").fetchone()[0],
                'oldest_telemetry': conn.execute(
                    "SELECT MIN(timestamp) FROM telemetry_data"
                ).fetchone()[0],
                'newest_telemetry': conn.execute(
                    "SELECT MAX(timestamp) FROM telemetry_data"
                ).fetchone()[0],
            }
            
            # Tamanho por tabela
            tables_size = {}
            for table in ['devices', 'telemetry_data', 'event_logs', 'relay_channels']:
                cursor = conn.execute(f"SELECT COUNT(*) * AVG(LENGTH(hex(*))) / 2 FROM {table}")
                size = cursor.fetchone()[0] or 0
                tables_size[table] = round(size / 1024 / 1024, 2)  # MB
            
            stats['tables_size_mb'] = tables_size
            stats['database_size'] = get_db_size()
            
        return stats

def main():
    """CLI para manutenção do banco"""
    parser = argparse.ArgumentParser(description='Manutenção do banco AutoCore')
    parser.add_argument('command', choices=['clean', 'vacuum', 'stats', 'full'],
                       help='Comando a executar')
    parser.add_argument('--telemetry-days', type=int, default=7,
                       help='Dias de telemetria para manter (padrão: 7)')
    parser.add_argument('--log-days', type=int, default=30,
                       help='Dias de logs para manter (padrão: 30)')
    parser.add_argument('--no-aggregate', action='store_true',
                       help='Pula agregação de dados')
    
    args = parser.parse_args()
    
    maintenance = DatabaseMaintenance()
    
    if args.command == 'clean':
        result = maintenance.cleanup_telemetry(args.telemetry_days)
        print(f"✅ Removidos {result['deleted']} registros de telemetria")
        result = maintenance.cleanup_logs(args.log_days)
        print(f"✅ Removidos {result['deleted']} logs")
        
    elif args.command == 'vacuum':
        result = maintenance.vacuum_database()
        print(f"✅ Espaço recuperado: {result['space_saved_mb']} MB")
        
    elif args.command == 'stats':
        stats = maintenance.get_statistics()
        print("\n📊 ESTATÍSTICAS DO BANCO")
        print("="*40)
        print(f"Dispositivos ativos: {stats['devices']}")
        print(f"Registros de telemetria: {stats['telemetry_records']}")
        print(f"Telemetria agregada: {stats['telemetry_hourly']}")
        print(f"Logs de eventos: {stats['event_logs']}")
        print(f"Canais de relé: {stats['relay_channels']}")
        print(f"Telas configuradas: {stats['screens']}")
        print(f"\nTamanho total: {stats['database_size']['total_size_mb']} MB")
        print("\nTamanho por tabela (MB):")
        for table, size in stats['tables_size_mb'].items():
            print(f"  {table}: {size} MB")
        
    elif args.command == 'full':
        maintenance.full_maintenance(
            args.telemetry_days,
            args.log_days,
            not args.no_aggregate
        )

if __name__ == '__main__':
    main()