# Agents System - Sistema de Agentes Firmware

Este diretório contém o sistema de agentes especializados para desenvolvimento e manutenção do firmware ESP32.

## 🤖 Visão Geral do Sistema de Agentes

### Conceito
O sistema de agentes firmware fornece automação inteligente para desenvolvimento, testing, deployment e manutenção do código ESP32, permitindo operações complexas e workflows automatizados.

### Arquitetura dos Agentes
```
Agent Dashboard
├── Active Agents (agentes em execução)
├── Agent Templates (templates reutilizáveis)
├── Execution Logs (logs de execução)
├── Checkpoints (pontos de controle)
└── Metrics (métricas de performance)
```

## 📋 Documentação Disponível

- [`dashboard.md`](dashboard.md) - Dashboard principal dos agentes
- [`active-agents/`](active-agents/) - Agentes especializados ativos
- [`logs/`](logs/) - Sistema de logging detalhado
- [`checkpoints/`](checkpoints/) - Pontos de controle e validação
- [`metrics/`](metrics/) - Métricas e analytics

## 🎯 Agentes Especializados

### A01 - Screen Creator
**Responsabilidade**: Criação automática de novas telas LVGL  
**Diretório**: [`active-agents/A01-screen-creator/`](active-agents/A01-screen-creator/)

**Funcionalidades**:
- Geração de código ScreenBase
- Criação de layouts responsivos
- Integração automática com ScreenFactory
- Validação de UI components
- Testing automático de telas

**Comando de Execução**:
```bash
./run-agent.sh A01-screen-creator --template="dashboard" --components="relay,action,display"
```

### A02 - Component Builder
**Responsabilidade**: Construção de novos componentes C++  
**Diretório**: [`active-agents/A02-component-builder/`](active-agents/A02-component-builder/)

**Funcionalidades**:
- Geração de headers (.h) e implementações (.cpp)
- Templates de componentes especializados
- Integração com sistema de logging
- Testes unitários automáticos
- Documentação inline

**Comando de Execução**:
```bash
./run-agent.sh A02-component-builder --type="sensor" --interface="i2c" --driver="bme280"
```

### A03 - Command Generator
**Responsabilidade**: Geração de comandos MQTT  
**Diretório**: [`active-agents/A03-command-generator/`](active-agents/A03-command-generator/)

**Funcionalidades**:
- Criação de novos tipos de comando MQTT
- Validação de protocol v2.2.0
- Geração de schemas JSON
- Testing de comandos
- Documentação de API

**Comando de Execução**:
```bash
./run-agent.sh A03-command-generator --command="sensor_reading" --qos=1 --schema="temperature"
```

### A04 - OTA Deployer
**Responsabilidade**: Deploy e atualizações OTA  
**Diretório**: [`active-agents/A04-ota-deployer/`](active-agents/A04-ota-deployer/)

**Funcionalidades**:
- Build automático do firmware
- Assinatura digital de binários
- Upload para servidor OTA
- Notificação de dispositivos
- Rollback automático em caso de falha

**Comando de Execução**:
```bash
./run-agent.sh A04-ota-deployer --version="1.2.3" --target="production" --rollback-timeout="5m"
```

### A05 - Performance Profiler
**Responsabilidade**: Análise de performance  
**Diretório**: [`active-agents/A05-performance-profiler/`](active-agents/A05-performance-profiler/)

**Funcionalidades**:
- Análise de uso de memória
- Profiling de CPU usage
- Benchmarking de componentes
- Otimização de código
- Relatórios de performance

**Comando de Execução**:
```bash
./run-agent.sh A05-performance-profiler --duration="10m" --components="all" --output="report.json"
```

## 🏗️ Estrutura de um Agente

### Template Base
```
agent-name/
├── README.md              # Documentação do agente
├── config/                # Configurações
│   ├── agent-config.json  # Configuração principal
│   ├── templates/         # Templates de código
│   └── schemas/           # Schemas de validação
├── src/                   # Código fonte do agente
│   ├── main.py           # Script principal
│   ├── generators/       # Geradores de código
│   ├── validators/       # Validadores
│   └── utils/            # Utilitários
├── tests/                 # Testes do agente
│   ├── unit/             # Testes unitários
│   └── integration/      # Testes integração
├── output/                # Saídas geradas
│   ├── code/             # Código gerado
│   ├── docs/             # Documentação gerada
│   └── tests/            # Testes gerados
└── logs/                  # Logs de execução
    ├── execution.log     # Log principal
    ├── errors.log        # Log de erros
    └── metrics.log       # Métricas
```

### Agent Configuration Format
```json
{
  "agent_id": "A01-screen-creator",
  "agent_name": "Screen Creator Agent",
  "version": "1.0.0",
  "description": "Automated LVGL screen generation",
  "author": "AutoCore System",
  "capabilities": [
    "screen_generation",
    "layout_creation",
    "component_integration"
  ],
  "requirements": {
    "python_version": ">=3.8",
    "dependencies": [
      "jinja2>=3.0.0",
      "jsonschema>=4.0.0",
      "click>=8.0.0"
    ]
  },
  "parameters": {
    "template_type": {
      "type": "string",
      "default": "basic",
      "choices": ["basic", "dashboard", "settings", "status"]
    },
    "components": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": ["relay", "action", "display", "navigation"]
      }
    },
    "layout": {
      "type": "object",
      "properties": {
        "columns": {"type": "integer", "minimum": 1, "maximum": 4},
        "rows": {"type": "integer", "minimum": 1, "maximum": 6}
      }
    }
  },
  "output_formats": [
    "cpp_header",
    "cpp_implementation", 
    "json_config",
    "documentation"
  ],
  "validation_rules": [
    "valid_cpp_syntax",
    "lvgl_compliance",
    "memory_constraints",
    "naming_conventions"
  ]
}
```

## 🚀 Agent Execution Framework

### Agent Runner
```python
#!/usr/bin/env python3
"""
AutoCore Agent Execution Framework
Executa agentes especializados para firmware ESP32
"""

import json
import logging
import argparse
import sys
from pathlib import Path
from typing import Dict, Any, List
from datetime import datetime

class AgentRunner:
    def __init__(self, agent_id: str, config_path: str):
        self.agent_id = agent_id
        self.config = self.load_config(config_path)
        self.setup_logging()
        
    def load_config(self, config_path: str) -> Dict[str, Any]:
        """Carrega configuração do agente"""
        with open(config_path, 'r') as f:
            return json.load(f)
    
    def setup_logging(self):
        """Configura sistema de logging"""
        log_dir = Path(f"agents/active-agents/{self.agent_id}/logs")
        log_dir.mkdir(parents=True, exist_ok=True)
        
        # Configurar formatters
        formatter = logging.Formatter(
            '[%(asctime)s] 🤖 [%(name)s] %(levelname)s: %(message)s'
        )
        
        # File handler
        file_handler = logging.FileHandler(log_dir / "execution.log")
        file_handler.setFormatter(formatter)
        
        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        
        # Setup logger
        self.logger = logging.getLogger(f"Agent-{self.agent_id}")
        self.logger.setLevel(logging.INFO)
        self.logger.addHandler(file_handler)
        self.logger.addHandler(console_handler)
    
    def validate_parameters(self, params: Dict[str, Any]) -> bool:
        """Valida parâmetros de entrada"""
        schema = self.config.get('parameters', {})
        
        for param_name, param_config in schema.items():
            if param_name in params:
                value = params[param_name]
                param_type = param_config.get('type')
                
                # Validação de tipo
                if param_type == 'string' and not isinstance(value, str):
                    self.logger.error(f"Parameter {param_name} must be string")
                    return False
                elif param_type == 'integer' and not isinstance(value, int):
                    self.logger.error(f"Parameter {param_name} must be integer")
                    return False
                elif param_type == 'array' and not isinstance(value, list):
                    self.logger.error(f"Parameter {param_name} must be array")
                    return False
                
                # Validação de choices
                if 'choices' in param_config:
                    if value not in param_config['choices']:
                        self.logger.error(f"Invalid choice for {param_name}: {value}")
                        return False
        
        return True
    
    def execute(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Executa o agente com parâmetros"""
        self.logger.info(f"🚀 Starting execution of agent {self.agent_id}")
        
        # Validar parâmetros
        if not self.validate_parameters(params):
            raise ValueError("Parameter validation failed")
        
        # Checkpoint inicial
        self.create_checkpoint("start", {"params": params})
        
        try:
            # Executar lógica específica do agente
            result = self.run_agent_logic(params)
            
            # Checkpoint de sucesso
            self.create_checkpoint("success", result)
            
            self.logger.info(f"✅ Agent {self.agent_id} completed successfully")
            return result
            
        except Exception as e:
            # Checkpoint de erro
            self.create_checkpoint("error", {"error": str(e)})
            self.logger.error(f"❌ Agent {self.agent_id} failed: {e}")
            raise
    
    def run_agent_logic(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Lógica específica do agente - deve ser implementada pela subclasse"""
        raise NotImplementedError("Agent logic must be implemented")
    
    def create_checkpoint(self, status: str, data: Dict[str, Any]):
        """Cria checkpoint de execução"""
        checkpoint_dir = Path(f"agents/checkpoints/{self.agent_id}")
        checkpoint_dir.mkdir(parents=True, exist_ok=True)
        
        checkpoint = {
            "agent_id": self.agent_id,
            "timestamp": datetime.now().isoformat(),
            "status": status,
            "data": data
        }
        
        checkpoint_file = checkpoint_dir / f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{status}.json"
        with open(checkpoint_file, 'w') as f:
            json.dump(checkpoint, f, indent=2)
        
        self.logger.info(f"🎯 Checkpoint created: {status}")

class ScreenCreatorAgent(AgentRunner):
    """Agente especializado para criação de telas LVGL"""
    
    def run_agent_logic(self, params: Dict[str, Any]) -> Dict[str, Any]:
        from .generators.screen_generator import ScreenGenerator
        
        generator = ScreenGenerator(self.config, self.logger)
        
        # Gerar código da tela
        screen_code = generator.generate_screen(
            template_type=params.get('template_type', 'basic'),
            components=params.get('components', []),
            layout=params.get('layout', {})
        )
        
        # Salvar arquivos gerados
        output_dir = Path(f"agents/active-agents/{self.agent_id}/output")
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Salvar header
        header_file = output_dir / f"{params['screen_name']}.h"
        with open(header_file, 'w') as f:
            f.write(screen_code['header'])
        
        # Salvar implementação
        cpp_file = output_dir / f"{params['screen_name']}.cpp"
        with open(cpp_file, 'w') as f:
            f.write(screen_code['implementation'])
        
        return {
            "files_generated": [str(header_file), str(cpp_file)],
            "screen_name": params['screen_name'],
            "components_count": len(params.get('components', [])),
            "template_type": params.get('template_type')
        }

def main():
    parser = argparse.ArgumentParser(description='AutoCore Agent Runner')
    parser.add_argument('agent_id', help='ID do agente a executar')
    parser.add_argument('--config', default='config/agent-config.json', help='Arquivo de configuração')
    parser.add_argument('--params', type=json.loads, default='{}', help='Parâmetros JSON')
    
    args = parser.parse_args()
    
    # Mapear agentes para classes
    agent_classes = {
        'A01-screen-creator': ScreenCreatorAgent,
        # Adicionar outros agentes aqui
    }
    
    if args.agent_id not in agent_classes:
        print(f"❌ Unknown agent: {args.agent_id}")
        sys.exit(1)
    
    # Instanciar e executar agente
    agent_class = agent_classes[args.agent_id]
    config_path = f"agents/active-agents/{args.agent_id}/{args.config}"
    
    agent = agent_class(args.agent_id, config_path)
    
    try:
        result = agent.execute(args.params)
        print(f"✅ Agent execution completed: {json.dumps(result, indent=2)}")
    except Exception as e:
        print(f"❌ Agent execution failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## 📊 Monitoring e Metrics

### Agent Dashboard
```python
#!/usr/bin/env python3
"""
Agent Dashboard - Monitoramento em tempo real dos agentes
"""

import json
import time
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, List, Any

class AgentDashboard:
    def __init__(self):
        self.agents_dir = Path("agents/active-agents")
        self.checkpoints_dir = Path("agents/checkpoints")
        self.metrics_dir = Path("agents/metrics")
    
    def get_agent_status(self) -> Dict[str, Any]:
        """Obtém status de todos os agentes"""
        agents = []
        
        for agent_dir in self.agents_dir.iterdir():
            if agent_dir.is_dir() and agent_dir.name.startswith('A'):
                agent_info = self.get_single_agent_status(agent_dir.name)
                agents.append(agent_info)
        
        return {
            "timestamp": datetime.now().isoformat(),
            "total_agents": len(agents),
            "active_agents": len([a for a in agents if a["status"] == "running"]),
            "agents": agents
        }
    
    def get_single_agent_status(self, agent_id: str) -> Dict[str, Any]:
        """Obtém status de um agente específico"""
        agent_dir = self.agents_dir / agent_id
        
        # Carregar configuração
        config_file = agent_dir / "config" / "agent-config.json"
        if config_file.exists():
            with open(config_file) as f:
                config = json.load(f)
        else:
            config = {}
        
        # Verificar último checkpoint
        checkpoint_dir = self.checkpoints_dir / agent_id
        last_checkpoint = self.get_last_checkpoint(checkpoint_dir)
        
        # Verificar logs recentes
        log_file = agent_dir / "logs" / "execution.log"
        last_activity = self.get_last_log_activity(log_file)
        
        return {
            "agent_id": agent_id,
            "name": config.get("agent_name", agent_id),
            "version": config.get("version", "unknown"),
            "status": self.determine_agent_status(last_checkpoint, last_activity),
            "last_checkpoint": last_checkpoint,
            "last_activity": last_activity,
            "capabilities": config.get("capabilities", [])
        }
    
    def determine_agent_status(self, checkpoint: Dict, activity: Dict) -> str:
        """Determina status atual do agente"""
        if not checkpoint:
            return "idle"
        
        # Se último checkpoint foi erro
        if checkpoint.get("status") == "error":
            return "error"
        
        # Se atividade recente (últimos 5 minutos)
        if activity and activity.get("minutes_ago", 999) < 5:
            return "running"
        
        # Se checkpoint de sucesso recente
        if checkpoint.get("status") == "success":
            return "completed"
        
        return "idle"
    
    def display_dashboard(self):
        """Exibe dashboard no terminal"""
        status = self.get_agent_status()
        
        print("\n" + "="*60)
        print("🤖 AUTOCORE AGENTS DASHBOARD")
        print("="*60)
        print(f"📊 Total Agents: {status['total_agents']}")
        print(f"🟢 Active: {status['active_agents']}")
        print(f"⏰ Last Update: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("-"*60)
        
        for agent in status["agents"]:
            status_icon = {
                "running": "🟢",
                "completed": "✅",
                "error": "❌",
                "idle": "⚪"
            }.get(agent["status"], "❓")
            
            print(f"{status_icon} {agent['agent_id']:<20} {agent['status']:<12} {agent['name']}")
        
        print("="*60)

if __name__ == "__main__":
    dashboard = AgentDashboard()
    
    # Loop de monitoramento
    try:
        while True:
            dashboard.display_dashboard()
            time.sleep(30)  # Atualizar a cada 30 segundos
    except KeyboardInterrupt:
        print("\n👋 Dashboard stopped")
```

## 🔧 Agent CLI Tools

### Bash Runner Script
```bash
#!/bin/bash
# run-agent.sh - Script para executar agentes AutoCore

set -e

AGENTS_DIR="agents/active-agents"
PYTHON_ENV=".venv/bin/python"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] 🤖 $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $1${NC}" >&2
}

success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️ $1${NC}"
}

# Função para verificar se agente existe
check_agent_exists() {
    local agent_id=$1
    if [ ! -d "$AGENTS_DIR/$agent_id" ]; then
        error "Agent $agent_id not found in $AGENTS_DIR"
        exit 1
    fi
}

# Função para executar agente
run_agent() {
    local agent_id=$1
    shift
    local params="$@"
    
    log "Starting agent $agent_id"
    
    # Verificar se agente existe
    check_agent_exists $agent_id
    
    # Ativar ambiente virtual
    if [ -f "$PYTHON_ENV" ]; then
        source .venv/bin/activate
    else
        warning "Python virtual environment not found, using system python"
    fi
    
    # Construir parâmetros JSON
    local json_params="{}"
    for param in $params; do
        if [[ $param == *"="* ]]; then
            key=$(echo $param | cut -d'=' -f1 | sed 's/--//')
            value=$(echo $param | cut -d'=' -f2-)
            
            # Detectar tipo do valor
            if [[ $value =~ ^[0-9]+$ ]]; then
                # Número
                json_params=$(echo $json_params | jq ". + {\"$key\": $value}")
            elif [[ $value == "true" || $value == "false" ]]; then
                # Boolean
                json_params=$(echo $json_params | jq ". + {\"$key\": $value}")
            elif [[ $value == *","* ]]; then
                # Array
                IFS=',' read -ra ADDR <<< "$value"
                array_json="["
                for item in "${ADDR[@]}"; do
                    array_json="$array_json\"$item\","
                done
                array_json="${array_json%,}]"
                json_params=$(echo $json_params | jq ". + {\"$key\": $array_json}")
            else
                # String
                json_params=$(echo $json_params | jq ". + {\"$key\": \"$value\"}")
            fi
        fi
    done
    
    log "Executing with parameters: $json_params"
    
    # Executar agente
    if python agents/agent_runner.py $agent_id --params "$json_params"; then
        success "Agent $agent_id completed successfully"
    else
        error "Agent $agent_id failed"
        exit 1
    fi
}

# Função para listar agentes
list_agents() {
    log "Available agents:"
    for agent_dir in $AGENTS_DIR/*/; do
        if [ -d "$agent_dir" ]; then
            agent_id=$(basename "$agent_dir")
            if [ -f "$agent_dir/config/agent-config.json" ]; then
                agent_name=$(jq -r '.agent_name // .agent_id' "$agent_dir/config/agent-config.json")
                version=$(jq -r '.version // "unknown"' "$agent_dir/config/agent-config.json")
                echo -e "  ${GREEN}$agent_id${NC} - $agent_name (v$version)"
            else
                echo -e "  ${YELLOW}$agent_id${NC} - No config found"
            fi
        fi
    done
}

# Função para mostrar status
show_status() {
    log "Agent system status:"
    if [ -f "agents/dashboard.py" ]; then
        python agents/dashboard.py --single-run
    else
        warning "Dashboard not available"
        list_agents
    fi
}

# Função para mostrar ajuda
show_help() {
    echo "AutoCore Agent Runner"
    echo ""
    echo "Usage:"
    echo "  $0 <agent_id> [parameters...]     Run specific agent"
    echo "  $0 --list                        List available agents"
    echo "  $0 --status                      Show system status"
    echo "  $0 --help                        Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 A01-screen-creator --template=dashboard --components=relay,action"
    echo "  $0 A02-component-builder --type=sensor --interface=i2c"
    echo "  $0 A04-ota-deployer --version=1.2.3 --target=production"
    echo ""
    echo "Available agents:"
    list_agents
}

# Parse argumentos da linha de comando
case $1 in
    --list)
        list_agents
        ;;
    --status)
        show_status
        ;;
    --help|-h)
        show_help
        ;;
    A*)
        run_agent "$@"
        ;;
    *)
        if [ $# -eq 0 ]; then
            show_help
        else
            error "Invalid option: $1"
            show_help
            exit 1
        fi
        ;;
esac
```

## 📝 Agent Documentation Standards

### README Template
Cada agente deve ter um README.md seguindo este template:

```markdown
# A0X - Agent Name

## 🎯 Purpose
Brief description of what this agent does and why it exists.

## 🚀 Usage
```bash
./run-agent.sh A0X-agent-name --param1=value1 --param2=value2
```

## ⚙️ Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| param1    | string | Yes | - | Description |
| param2    | array | No | [] | Description |

## 📊 Output
Description of what the agent generates/produces.

## 🔧 Configuration
Details about agent-config.json and customization options.

## 🧪 Testing
How to test this agent and validate its output.

## 📝 Examples
Real-world usage examples with expected outputs.
```

Esta estrutura fornece um sistema robusto e extensível de agentes para automação do desenvolvimento firmware.