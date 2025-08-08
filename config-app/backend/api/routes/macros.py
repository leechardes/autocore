"""
API Routes para Macros e Automações
"""
from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import json
import sys
from pathlib import Path
from datetime import datetime
import asyncio

# Adiciona path para importar database
sys.path.append(str(Path(__file__).parent.parent.parent.parent.parent / "database"))

from shared.repositories import events, config, macros

# Importar o executor de macros
sys.path.append(str(Path(__file__).parent.parent.parent))
from services.macro_executor import macro_executor

router = APIRouter(prefix="/api/macros", tags=["macros"])

# ============================================
# MODELS
# ============================================

class MacroCreate(BaseModel):
    name: str
    description: Optional[str] = None
    trigger_type: str = "manual"  # manual, scheduled, condition
    trigger_config: Optional[Dict] = {}
    action_sequence: List[Dict]
    condition_logic: Optional[Dict] = None
    preserve_state: bool = False
    requires_heartbeat: bool = False

class MacroUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    trigger_type: Optional[str] = None
    trigger_config: Optional[Dict] = None
    action_sequence: Optional[List[Dict]] = None
    condition_logic: Optional[Dict] = None
    is_active: Optional[bool] = None
    preserve_state: Optional[bool] = None
    requires_heartbeat: Optional[bool] = None

class MacroExecute(BaseModel):
    context: Optional[Dict] = None
    test_mode: bool = False

# ============================================
# CRUD ENDPOINTS
# ============================================

@router.get("/")
async def list_macros(active_only: bool = True):
    """Lista todas as macros"""
    try:
        all_macros = macros.get_all(active_only=active_only)
        
        return [
            {
                "id": m.id,
                "name": m.name,
                "description": m.description,
                "trigger_type": m.trigger_type,
                "is_active": m.is_active,
                "last_executed": m.last_executed.isoformat() if m.last_executed else None,
                "execution_count": m.execution_count,
                "created_at": m.created_at.isoformat()
            }
            for m in all_macros
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{macro_id}")
async def get_macro(macro_id: int):
    """Obtém detalhes de uma macro"""
    try:
        macro = macros.get_by_id(macro_id)
        if not macro:
            raise HTTPException(status_code=404, detail="Macro não encontrada")
        
        return {
            "id": macro.id,
            "name": macro.name,
            "description": macro.description,
            "trigger_type": macro.trigger_type,
            "trigger_config": json.loads(macro.trigger_config or "{}"),
            "action_sequence": json.loads(macro.action_sequence or "[]"),
            "condition_logic": json.loads(macro.condition_logic or "null"),
            "is_active": macro.is_active,
            "last_executed": macro.last_executed.isoformat() if macro.last_executed else None,
            "execution_count": macro.execution_count,
            "created_at": macro.created_at.isoformat()
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/")
async def create_macro(macro: MacroCreate):
    """Cria uma nova macro"""
    try:
        # Preparar configurações
        trigger_config = macro.trigger_config or {}
        trigger_config["preserve_state"] = macro.preserve_state
        trigger_config["requires_heartbeat"] = macro.requires_heartbeat
        
        macro_data = {
            'name': macro.name,
            'description': macro.description,
            'trigger_type': macro.trigger_type,
            'trigger_config': json.dumps(trigger_config),
            'action_sequence': json.dumps(macro.action_sequence),
            'condition_logic': json.dumps(macro.condition_logic) if macro.condition_logic else None,
            'is_active': True
        }
        
        new_macro = macros.create(macro_data)
        
        return {
            "id": new_macro.id,
            "name": new_macro.name,
            "message": "Macro criada com sucesso"
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/{macro_id}")
async def update_macro(macro_id: int, macro: MacroUpdate):
    """Atualiza uma macro existente"""
    try:
        # Buscar macro existente
        db_macro = macros.get_by_id(macro_id)
        if not db_macro:
            raise HTTPException(status_code=404, detail="Macro não encontrada")
        
        # Preparar dados de atualização
        update_data = {}
        
        if macro.name is not None:
            update_data['name'] = macro.name
        if macro.description is not None:
            update_data['description'] = macro.description
        if macro.trigger_type is not None:
            update_data['trigger_type'] = macro.trigger_type
        if macro.is_active is not None:
            update_data['is_active'] = macro.is_active
            
        # Atualizar configurações
        if macro.trigger_config is not None or macro.preserve_state is not None or macro.requires_heartbeat is not None:
            config = json.loads(db_macro.trigger_config or "{}")
            if macro.trigger_config:
                config.update(macro.trigger_config)
            if macro.preserve_state is not None:
                config["preserve_state"] = macro.preserve_state
            if macro.requires_heartbeat is not None:
                config["requires_heartbeat"] = macro.requires_heartbeat
            update_data['trigger_config'] = json.dumps(config)
        
        if macro.action_sequence is not None:
            update_data['action_sequence'] = json.dumps(macro.action_sequence)
        if macro.condition_logic is not None:
            update_data['condition_logic'] = json.dumps(macro.condition_logic)
        
        # Aplicar atualização
        updated_macro = macros.update(macro_id, update_data)
        if not updated_macro:
            raise HTTPException(status_code=404, detail="Erro ao atualizar macro")
        
        return {"message": "Macro atualizada com sucesso"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{macro_id}")
async def delete_macro(macro_id: int):
    """Remove uma macro"""
    try:
        success = macros.delete(macro_id)
        if not success:
            raise HTTPException(status_code=404, detail="Macro não encontrada")
        
        return {"message": "Macro removida com sucesso"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# ============================================
# EXECUTION ENDPOINTS
# ============================================

@router.post("/{macro_id}/execute")
async def execute_macro(macro_id: int, request: MacroExecute, background_tasks: BackgroundTasks):
    """Executa uma macro"""
    
    try:
        macro = macros.get_by_id(macro_id)
        if not macro or not macro.is_active:
            raise HTTPException(status_code=404, detail="Macro não encontrada ou inativa")
        
        # Preparar dados da macro
        macro_data = {
            "id": macro.id,
            "name": macro.name,
            "action_sequence": json.loads(macro.action_sequence) if isinstance(macro.action_sequence, str) else macro.action_sequence,
            "trigger_config": json.loads(macro.trigger_config) if isinstance(macro.trigger_config, str) else macro.trigger_config
        }
        
        # Atualizar estatísticas usando o repositório
        executed_macro = macros.execute(macro_id)
        
        # Registrar evento
        events.log(
            event_type="macro_executed",
            source="config_app",
            action="execute",
            target=f"macro_{macro_id}",
            payload={
                "macro_id": macro_id,
                "name": macro.name,
                "context": request.context,
                "test_mode": request.test_mode
            }
        )
        
        # Executar macro em background usando o executor real
        background_tasks.add_task(
            macro_executor.execute_macro,
            macro_id,
            macro_data,
            request.test_mode
        )
        
        return {
            "status": "executing",
            "macro_id": macro_id,
            "name": macro.name,
            "test_mode": request.test_mode,
            "message": "Macro iniciada, comandos sendo enviados via MQTT"
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/{macro_id}/stop")
async def stop_macro(macro_id: int):
    """Para execução de uma macro"""
    try:
        # Parar execução via executor
        macro_executor.stop_macro(macro_id)
        
        # Registrar evento
        events.log(
            event_type="macro_stopped",
            source="config_app",
            action="stop",
            target=f"macro_{macro_id}"
        )
        
        return {
            "status": "stopped",
            "macro_id": macro_id,
            "message": "Comando de parada enviado"
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{macro_id}/status")
async def get_macro_status(macro_id: int):
    """Obtém status de execução de uma macro"""
    # TODO: Integrar com macro_engine
    return {
        "macro_id": macro_id,
        "status": "idle",
        "last_executed": None
    }

# ============================================
# TEMPLATE ENDPOINTS
# ============================================

@router.get("/templates/list")
async def list_macro_templates():
    """Lista templates de macros pré-definidos"""
    templates = [
        {
            "id": "light_show",
            "name": "Show de Luz",
            "description": "Sequência de luzes para demonstração",
            "category": "entertainment",
            "action_sequence": [
                {"type": "save_state", "targets": [1,2,3,4,5,6,7,8]},
                {
                    "type": "loop",
                    "count": 10,
                    "actions": [
                        {"type": "relay", "target": [1,3,5,7], "action": "on"},
                        {"type": "relay", "target": [2,4,6,8], "action": "off"},
                        {"type": "delay", "ms": 500},
                        {"type": "relay", "target": [1,3,5,7], "action": "off"},
                        {"type": "relay", "target": [2,4,6,8], "action": "on"},
                        {"type": "delay", "ms": 500}
                    ]
                },
                {"type": "restore_state", "targets": [1,2,3,4,5,6,7,8]}
            ]
        },
        {
            "id": "trail_mode",
            "name": "Modo Trilha",
            "description": "Ativa configurações para trilha off-road",
            "category": "driving",
            "action_sequence": [
                {"type": "save_state", "scope": "all"},
                {"type": "relay", "target": 3, "action": "on", "label": "Farol de milha"},
                {"type": "relay", "target": 10, "action": "on", "label": "Barra LED"},
                {"type": "relay", "target": 15, "action": "on", "label": "Luz traseira"},
                {"type": "mqtt", "topic": "autocore/modes/trail", "payload": {"active": True}}
            ]
        },
        {
            "id": "emergency",
            "name": "Modo Emergência",
            "description": "Ativa luzes de emergência",
            "category": "safety",
            "requires_heartbeat": True,
            "action_sequence": [
                {"type": "save_state", "scope": "all"},
                {
                    "type": "parallel",
                    "actions": [
                        {"type": "relay", "target": [4, 5], "action": "on"},
                        {"type": "mqtt", "topic": "autocore/alerts/emergency", "payload": {"active": True}}
                    ]
                },
                {
                    "type": "loop",
                    "count": -1,  # Loop infinito até parar
                    "actions": [
                        {"type": "relay", "target": [1, 2], "action": "on"},
                        {"type": "delay", "ms": 500},
                        {"type": "relay", "target": [1, 2], "action": "off"},
                        {"type": "delay", "ms": 500}
                    ]
                }
            ]
        },
        {
            "id": "shutdown_all",
            "name": "Desligar Tudo",
            "description": "Desliga todos os acessórios do veículo",
            "category": "system",
            "action_sequence": [
                {"type": "relay", "target": "all", "action": "off"},
                {"type": "mqtt", "topic": "autocore/system/shutdown", "payload": {"timestamp": "now"}}
            ]
        }
    ]
    
    return templates

@router.post("/templates/{template_id}/create")
async def create_from_template(template_id: str, name: Optional[str] = None):
    """Cria uma macro a partir de um template"""
    # Buscar template
    templates = await list_macro_templates()
    template = next((t for t in templates if t["id"] == template_id), None)
    
    if not template:
        raise HTTPException(status_code=404, detail="Template não encontrado")
    
    # Criar macro
    macro_data = MacroCreate(
        name=name or template["name"],
        description=template["description"],
        trigger_type="manual",
        action_sequence=template["action_sequence"],
        preserve_state=template.get("preserve_state", True),
        requires_heartbeat=template.get("requires_heartbeat", False)
    )
    
    return await create_macro(macro_data)