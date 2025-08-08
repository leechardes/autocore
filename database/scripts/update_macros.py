#!/usr/bin/env python3
"""
Script para atualizar macros existentes e criar Show de Luz
"""
import sys
import json
from pathlib import Path
from datetime import datetime

# Adiciona path para importar models
sys.path.append(str(Path(__file__).parent.parent))

from src.models.models import get_session, Macro

def update_macros():
    """Atualiza macros existentes com action_sequence correto e cria Show de Luz"""
    session = get_session()
    
    try:
        # 1. Atualizar Modo Trilha
        modo_trilha = session.query(Macro).filter_by(name="Modo Trilha").first()
        if modo_trilha:
            action_sequence = [
                {"type": "save_state", "scope": "all"},
                {"type": "relay", "target": 3, "action": "on", "label": "Farol de milha"},
                {"type": "relay", "target": 10, "action": "on", "label": "Barra LED"},
                {"type": "relay", "target": 15, "action": "on", "label": "Luz traseira"},
                {"type": "mqtt", "topic": "autocore/modes/trail", "payload": {"active": True}},
                {"type": "log", "message": "Modo Trilha ativado"}
            ]
            
            trigger_config = {
                "preserve_state": True,
                "requires_heartbeat": False
            }
            
            modo_trilha.action_sequence = json.dumps(action_sequence)
            modo_trilha.trigger_config = json.dumps(trigger_config)
            print("✅ Modo Trilha atualizado")
        
        # 2. Atualizar Emergência
        emergencia = session.query(Macro).filter_by(name="Emergência").first()
        if emergencia:
            action_sequence = [
                {"type": "save_state", "scope": "all"},
                {
                    "type": "parallel",
                    "actions": [
                        {"type": "relay", "target": [4, 5], "action": "on", "label": "Luzes de emergência"},
                        {"type": "mqtt", "topic": "autocore/alerts/emergency", "payload": {"active": True}}
                    ]
                },
                {
                    "type": "loop",
                    "count": -1,  # Loop infinito até parar
                    "actions": [
                        {"type": "relay", "target": [1, 2], "action": "on", "label": "Pisca alerta"},
                        {"type": "delay", "ms": 500},
                        {"type": "relay", "target": [1, 2], "action": "off"},
                        {"type": "delay", "ms": 500}
                    ]
                }
            ]
            
            trigger_config = {
                "preserve_state": True,
                "requires_heartbeat": True  # Importante para emergência!
            }
            
            emergencia.action_sequence = json.dumps(action_sequence)
            emergencia.trigger_config = json.dumps(trigger_config)
            print("✅ Emergência atualizada (com heartbeat obrigatório)")
        
        # 3. Atualizar Desligar Tudo
        desligar_tudo = session.query(Macro).filter_by(name="Desligar Tudo").first()
        if desligar_tudo:
            action_sequence = [
                {"type": "relay", "target": "all", "action": "off"},
                {"type": "mqtt", "topic": "autocore/system/shutdown", "payload": {"timestamp": datetime.now().isoformat()}},
                {"type": "log", "message": "Sistema desligado - Todos os acessórios OFF"}
            ]
            
            trigger_config = {
                "preserve_state": False,  # Não precisa preservar, está desligando tudo
                "requires_heartbeat": False
            }
            
            desligar_tudo.action_sequence = json.dumps(action_sequence)
            desligar_tudo.trigger_config = json.dumps(trigger_config)
            print("✅ Desligar Tudo atualizado")
        
        # 4. Criar Show de Luz (se não existir)
        show_luz = session.query(Macro).filter_by(name="Show de Luz").first()
        if not show_luz:
            action_sequence = [
                {"type": "save_state", "targets": [1,2,3,4,5,6,7,8], "label": "Salvar estado original"},
                {"type": "log", "message": "Iniciando Show de Luz 🎆"},
                
                # Sequência 1: Onda de luz
                {
                    "type": "loop",
                    "count": 3,
                    "label": "Onda de luz",
                    "actions": [
                        {"type": "relay", "target": [1,2], "action": "on"},
                        {"type": "delay", "ms": 200},
                        {"type": "relay", "target": [3,4], "action": "on"},
                        {"type": "relay", "target": [1,2], "action": "off"},
                        {"type": "delay", "ms": 200},
                        {"type": "relay", "target": [5,6], "action": "on"},
                        {"type": "relay", "target": [3,4], "action": "off"},
                        {"type": "delay", "ms": 200},
                        {"type": "relay", "target": [7,8], "action": "on"},
                        {"type": "relay", "target": [5,6], "action": "off"},
                        {"type": "delay", "ms": 200},
                        {"type": "relay", "target": [7,8], "action": "off"},
                        {"type": "delay", "ms": 200}
                    ]
                },
                
                # Sequência 2: Alternado
                {
                    "type": "loop",
                    "count": 5,
                    "label": "Alternado pares/ímpares",
                    "actions": [
                        {"type": "relay", "target": [1,3,5,7], "action": "on"},
                        {"type": "relay", "target": [2,4,6,8], "action": "off"},
                        {"type": "delay", "ms": 300},
                        {"type": "relay", "target": [1,3,5,7], "action": "off"},
                        {"type": "relay", "target": [2,4,6,8], "action": "on"},
                        {"type": "delay", "ms": 300}
                    ]
                },
                
                # Sequência 3: Todos piscando
                {
                    "type": "loop",
                    "count": 3,
                    "label": "Flash total",
                    "actions": [
                        {"type": "relay", "target": "all", "action": "on"},
                        {"type": "delay", "ms": 500},
                        {"type": "relay", "target": "all", "action": "off"},
                        {"type": "delay", "ms": 500}
                    ]
                },
                
                # Sequência 4: Crescente
                {
                    "type": "loop",
                    "count": 2,
                    "label": "Crescente",
                    "actions": [
                        {"type": "relay", "target": 1, "action": "on"},
                        {"type": "delay", "ms": 100},
                        {"type": "relay", "target": 2, "action": "on"},
                        {"type": "delay", "ms": 100},
                        {"type": "relay", "target": 3, "action": "on"},
                        {"type": "delay", "ms": 100},
                        {"type": "relay", "target": 4, "action": "on"},
                        {"type": "delay", "ms": 100},
                        {"type": "relay", "target": 5, "action": "on"},
                        {"type": "delay", "ms": 100},
                        {"type": "relay", "target": 6, "action": "on"},
                        {"type": "delay", "ms": 100},
                        {"type": "relay", "target": 7, "action": "on"},
                        {"type": "delay", "ms": 100},
                        {"type": "relay", "target": 8, "action": "on"},
                        {"type": "delay", "ms": 500},
                        {"type": "relay", "target": "all", "action": "off"},
                        {"type": "delay", "ms": 300}
                    ]
                },
                
                # Final: Restaurar estado
                {"type": "log", "message": "Show de Luz finalizado ✨"},
                {"type": "restore_state", "targets": [1,2,3,4,5,6,7,8], "label": "Restaurar estado original"}
            ]
            
            trigger_config = {
                "preserve_state": True,
                "requires_heartbeat": False,
                "total_duration_ms": 25000  # ~25 segundos total
            }
            
            show_luz = Macro(
                name="Show de Luz",
                description="Sequência de luzes para demonstração e entretenimento",
                trigger_type="manual",
                trigger_config=json.dumps(trigger_config),
                action_sequence=json.dumps(action_sequence),
                condition_logic=None,
                is_active=True,
                execution_count=0
            )
            
            session.add(show_luz)
            print("✅ Show de Luz criado")
        else:
            print("ℹ️ Show de Luz já existe")
        
        # 5. Criar Modo Estacionamento (novo)
        estacionamento = session.query(Macro).filter_by(name="Modo Estacionamento").first()
        if not estacionamento:
            action_sequence = [
                {"type": "save_state", "scope": "all"},
                {"type": "relay", "target": [1, 2], "action": "on", "label": "Luzes de posição"},
                {"type": "relay", "target": 12, "action": "on", "label": "Luz interna"},
                {"type": "delay", "ms": 30000},  # 30 segundos
                {"type": "relay", "target": 12, "action": "off", "label": "Desliga luz interna"},
                {"type": "mqtt", "topic": "autocore/modes/parking", "payload": {"active": True}}
            ]
            
            trigger_config = {
                "preserve_state": True,
                "requires_heartbeat": False
            }
            
            estacionamento = Macro(
                name="Modo Estacionamento",
                description="Ativa luzes de posição e interna temporariamente",
                trigger_type="manual",
                trigger_config=json.dumps(trigger_config),
                action_sequence=json.dumps(action_sequence),
                condition_logic=None,
                is_active=True,
                execution_count=0
            )
            
            session.add(estacionamento)
            print("✅ Modo Estacionamento criado")
        
        # Commit todas as mudanças
        session.commit()
        print("\n🎉 Todas as macros foram atualizadas com sucesso!")
        
        # Listar macros finais
        print("\n📋 Macros disponíveis:")
        all_macros = session.query(Macro).all()
        for macro in all_macros:
            config = json.loads(macro.trigger_config or "{}")
            print(f"  • {macro.name}")
            print(f"    - Preserva estado: {'Sim' if config.get('preserve_state') else 'Não'}")
            print(f"    - Requer heartbeat: {'Sim' if config.get('requires_heartbeat') else 'Não'}")
            print(f"    - Execuções: {macro.execution_count}")
        
    except Exception as e:
        print(f"❌ Erro: {e}")
        session.rollback()
    finally:
        session.close()

if __name__ == "__main__":
    update_macros()