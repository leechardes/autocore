#!/usr/bin/env python3
"""
Script de Validação de Conformidade MQTT v2.2.0
Verifica se componentes do AutoCore seguem a arquitetura MQTT documentada
"""

import os
import re
import json
import sys
from pathlib import Path
from typing import Dict, List, Tuple
from dataclasses import dataclass
from enum import Enum
from colorama import init, Fore, Style

# Inicializar colorama para output colorido
init(autoreset=True)

class Severity(Enum):
    CRITICAL = "🔴 CRÍTICO"
    HIGH = "⚠️  ALTO"
    MEDIUM = "🟡 MÉDIO"
    LOW = "🟢 BAIXO"

@dataclass
class Violation:
    component: str
    file: str
    line: int
    issue: str
    current: str
    expected: str
    severity: Severity

class MQTTConformanceValidator:
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.violations: List[Violation] = []
        self.stats = {
            'files_checked': 0,
            'violations_found': 0,
            'critical': 0,
            'high': 0,
            'medium': 0,
            'low': 0
        }
        
        # Padrões v2.2.0
        self.valid_topic_patterns = [
            r'^autocore/devices/[\w-]+/(status|relays/set|relays/state|relays/heartbeat|display/screen|display/touch|sensors/data)$',
            r'^autocore/telemetry/(relays|displays|sensors|can)/[\w/]*$',
            r'^autocore/gateway/(status|stats|commands/\w+)$',
            r'^autocore/discovery/(announce|request)$',
            r'^autocore/system/(broadcast|alert|update)$',
            r'^autocore/commands/(all|group|device)/[\w-]+/\w+$',
            r'^autocore/errors/[\w-]+/\w+$',
            r'^autocore/metrics/\w+$'
        ]
        
        # Tópicos incorretos conhecidos
        self.incorrect_patterns = {
            r'autotech/': ('autotech/', 'autocore/', Severity.CRITICAL),
            r'/relay/': ('/relay/', '/relays/', Severity.HIGH),
            r'/config\b': ('/config', 'API REST', Severity.CRITICAL),
            r'autocore/devices/\+/telemetry': ('UUID in telemetry topic', 'autocore/telemetry/{type}/data', Severity.HIGH)
        }

    def validate_component(self, component_path: str, component_name: str):
        """Valida um componente específico"""
        print(f"\n{Fore.CYAN}Validando {component_name}...{Style.RESET_ALL}")
        
        component_dir = self.project_root / component_path
        if not component_dir.exists():
            print(f"{Fore.YELLOW}  Componente não encontrado: {component_path}{Style.RESET_ALL}")
            return
        
        # Extensões a verificar por tipo de projeto
        extensions = {
            '.py': self.validate_python_file,
            '.js': self.validate_javascript_file,
            '.jsx': self.validate_javascript_file,
            '.ts': self.validate_javascript_file,
            '.tsx': self.validate_javascript_file,
            '.cpp': self.validate_cpp_file,
            '.c': self.validate_c_file,
            '.h': self.validate_header_file
        }
        
        for file_path in component_dir.rglob('*'):
            if file_path.is_file() and file_path.suffix in extensions:
                self.stats['files_checked'] += 1
                extensions[file_path.suffix](file_path, component_name)

    def validate_python_file(self, file_path: Path, component: str):
        """Valida arquivo Python"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')
                
            # Verificar tópicos MQTT
            topic_patterns = [
                r"['\"]autocore/[^'\"]+['\"]",
                r"['\"]autotech/[^'\"]+['\"]",  # Incorreto
                r"topic\s*=\s*['\"][^'\"]+['\"]",
                r"subscribe\(['\"][^'\"]+['\"]",
                r"publish\(['\"][^'\"]+['\"]"
            ]
            
            for i, line in enumerate(lines, 1):
                for pattern in topic_patterns:
                    matches = re.findall(pattern, line)
                    for match in matches:
                        self.check_topic_validity(match, file_path, i, component)
                
                # Verificar protocol_version
                if 'json.dumps' in line or 'payload' in line:
                    if 'protocol_version' not in line and 'protocol_version' not in lines[max(0, i-5):min(len(lines), i+5)]:
                        self.add_violation(
                            component, str(file_path), i,
                            "Payload sem protocol_version",
                            line.strip(),
                            "Incluir 'protocol_version': '2.2.0'",
                            Severity.HIGH
                        )
                
                # Verificar configuração via MQTT
                if '/config' in line and 'mqtt' in line.lower():
                    self.add_violation(
                        component, str(file_path), i,
                        "Configuração via MQTT detectada",
                        line.strip(),
                        "Usar API REST para configuração",
                        Severity.CRITICAL
                    )
                    
        except Exception as e:
            print(f"{Fore.RED}  Erro ao validar {file_path}: {e}{Style.RESET_ALL}")

    def validate_javascript_file(self, file_path: Path, component: str):
        """Valida arquivo JavaScript/TypeScript"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')
                
            for i, line in enumerate(lines, 1):
                # Verificar tópicos
                topic_matches = re.findall(r"['\"`]autocore/[^'\"`]+['\"`]", line)
                topic_matches.extend(re.findall(r"['\"`]autotech/[^'\"`]+['\"`]", line))
                
                for match in topic_matches:
                    self.check_topic_validity(match, file_path, i, component)
                
                # Verificar protocol_version em payloads
                if 'JSON.stringify' in line or 'payload' in line:
                    context = ''.join(lines[max(0, i-3):min(len(lines), i+3)])
                    if 'protocol_version' not in context:
                        self.add_violation(
                            component, str(file_path), i,
                            "Payload sem protocol_version",
                            line.strip(),
                            "Incluir protocol_version: '2.2.0'",
                            Severity.HIGH
                        )
                        
        except Exception as e:
            print(f"{Fore.RED}  Erro ao validar {file_path}: {e}{Style.RESET_ALL}")

    def validate_cpp_file(self, file_path: Path, component: str):
        """Valida arquivo C++"""
        self.validate_c_like_file(file_path, component)

    def validate_c_file(self, file_path: Path, component: str):
        """Valida arquivo C"""
        self.validate_c_like_file(file_path, component)

    def validate_header_file(self, file_path: Path, component: str):
        """Valida arquivo header"""
        self.validate_c_like_file(file_path, component)

    def validate_c_like_file(self, file_path: Path, component: str):
        """Valida arquivos C/C++"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')
                
            for i, line in enumerate(lines, 1):
                # Verificar tópicos
                topic_matches = re.findall(r'"autocore/[^"]*"', line)
                topic_matches.extend(re.findall(r'"autotech/[^"]*"', line))
                
                for match in topic_matches:
                    self.check_topic_validity(match, file_path, i, component)
                
                # Verificar estruturas JSON
                if 'JsonDocument' in line or 'cJSON' in line or 'json' in line.lower():
                    context = ''.join(lines[max(0, i-5):min(len(lines), i+10)])
                    if 'protocol_version' not in context:
                        if any(word in context for word in ['publish', 'send', 'mqtt']):
                            self.add_violation(
                                component, str(file_path), i,
                                "Provável payload sem protocol_version",
                                line.strip(),
                                'doc["protocol_version"] = "2.2.0";',
                                Severity.MEDIUM
                            )
                
                # Verificar QoS incorreto
                if 'qos' in line.lower():
                    if 'telemetry' in line.lower() and 'qos.*[12]' in line.lower():
                        self.add_violation(
                            component, str(file_path), i,
                            "QoS incorreto para telemetria",
                            line.strip(),
                            "QoS 0 para telemetria",
                            Severity.MEDIUM
                        )
                        
        except Exception as e:
            print(f"{Fore.RED}  Erro ao validar {file_path}: {e}{Style.RESET_ALL}")

    def check_topic_validity(self, topic: str, file_path: Path, line: int, component: str):
        """Verifica se um tópico está conforme v2.2.0"""
        # Limpar o tópico
        clean_topic = topic.strip('"\'` ')
        
        # Verificar padrões incorretos conhecidos
        for pattern, (current, expected, severity) in self.incorrect_patterns.items():
            if re.search(pattern, clean_topic):
                self.add_violation(
                    component, str(file_path), line,
                    f"Tópico incorreto: {pattern}",
                    clean_topic,
                    clean_topic.replace(current, expected) if current != '/config' else expected,
                    severity
                )
                return
        
        # Verificar se segue algum padrão válido
        if clean_topic.startswith('autocore/'):
            valid = any(re.match(pattern, clean_topic) for pattern in self.valid_topic_patterns)
            if not valid and '+' not in clean_topic and '#' not in clean_topic:
                self.add_violation(
                    component, str(file_path), line,
                    "Estrutura de tópico não conforme",
                    clean_topic,
                    "autocore/{categoria}/{uuid}/{recurso}/{ação}",
                    Severity.MEDIUM
                )

    def add_violation(self, component: str, file: str, line: int, issue: str, 
                     current: str, expected: str, severity: Severity):
        """Adiciona uma violação encontrada"""
        # Simplificar caminho do arquivo
        try:
            file = str(Path(file).relative_to(self.project_root))
        except:
            pass
            
        violation = Violation(component, file, line, issue, current, expected, severity)
        self.violations.append(violation)
        self.stats['violations_found'] += 1
        
        # Atualizar contadores por severidade
        if severity == Severity.CRITICAL:
            self.stats['critical'] += 1
        elif severity == Severity.HIGH:
            self.stats['high'] += 1
        elif severity == Severity.MEDIUM:
            self.stats['medium'] += 1
        else:
            self.stats['low'] += 1

    def print_report(self):
        """Imprime relatório de violações"""
        print(f"\n{'='*80}")
        print(f"{Fore.CYAN}RELATÓRIO DE CONFORMIDADE MQTT v2.2.0{Style.RESET_ALL}")
        print(f"{'='*80}\n")
        
        # Estatísticas
        print(f"{Fore.GREEN}Arquivos verificados:{Style.RESET_ALL} {self.stats['files_checked']}")
        print(f"{Fore.YELLOW}Violações encontradas:{Style.RESET_ALL} {self.stats['violations_found']}")
        print(f"  {Fore.RED}Críticas:{Style.RESET_ALL} {self.stats['critical']}")
        print(f"  {Fore.YELLOW}Altas:{Style.RESET_ALL} {self.stats['high']}")
        print(f"  {Fore.BLUE}Médias:{Style.RESET_ALL} {self.stats['medium']}")
        print(f"  {Fore.GREEN}Baixas:{Style.RESET_ALL} {self.stats['low']}")
        
        if not self.violations:
            print(f"\n{Fore.GREEN}✅ Nenhuma violação encontrada! Componentes conformes com v2.2.0{Style.RESET_ALL}")
            return
        
        # Agrupar por componente
        by_component = {}
        for v in self.violations:
            if v.component not in by_component:
                by_component[v.component] = []
            by_component[v.component].append(v)
        
        # Imprimir violações por componente
        for component, violations in by_component.items():
            print(f"\n{Fore.CYAN}📦 {component}{Style.RESET_ALL}")
            print(f"{'-'*60}")
            
            # Ordenar por severidade
            violations.sort(key=lambda x: [Severity.CRITICAL, Severity.HIGH, Severity.MEDIUM, Severity.LOW].index(x.severity))
            
            for v in violations[:10]:  # Limitar a 10 por componente
                print(f"\n  {v.severity.value} {v.issue}")
                print(f"  📁 {v.file}:{v.line}")
                print(f"  ❌ Atual: {Fore.RED}{v.current[:80]}...{Style.RESET_ALL}" if len(v.current) > 80 else f"  ❌ Atual: {Fore.RED}{v.current}{Style.RESET_ALL}")
                print(f"  ✅ Esperado: {Fore.GREEN}{v.expected[:80]}...{Style.RESET_ALL}" if len(v.expected) > 80 else f"  ✅ Esperado: {Fore.GREEN}{v.expected}{Style.RESET_ALL}")
            
            if len(violations) > 10:
                print(f"\n  ... e mais {len(violations) - 10} violações")

    def export_json(self, output_file: str):
        """Exporta relatório em JSON"""
        report = {
            'version': '2.2.0',
            'stats': self.stats,
            'violations': [
                {
                    'component': v.component,
                    'file': v.file,
                    'line': v.line,
                    'issue': v.issue,
                    'current': v.current,
                    'expected': v.expected,
                    'severity': v.severity.name
                }
                for v in self.violations
            ]
        }
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n{Fore.GREEN}Relatório exportado para: {output_file}{Style.RESET_ALL}")

def main():
    """Função principal"""
    # Determinar raiz do projeto
    script_dir = Path(__file__).parent
    project_root = script_dir.parent.parent  # Volta 2 níveis
    
    print(f"{Fore.CYAN}🔍 Validador de Conformidade MQTT v2.2.0{Style.RESET_ALL}")
    print(f"Projeto: {project_root}")
    
    validator = MQTTConformanceValidator(project_root)
    
    # Componentes a validar (ordem de prioridade)
    components = [
        ('gateway', 'Gateway'),
        ('config-app/backend', 'Config-App Backend'),
        ('config-app/frontend', 'Config-App Frontend'),
        ('firmware/esp32-relay', 'ESP32 Relay'),
        ('firmware/esp32-relay-esp-idf', 'ESP32 Relay ESP-IDF'),
        ('firmware/esp32-display-v2', 'ESP32 Display v2'),
        ('firmware/esp32-display', 'ESP32 Display v1'),
        ('firmware/esp32-display-esp-idf', 'ESP32 Display ESP-IDF')
    ]
    
    # Permitir validação de componente específico
    if len(sys.argv) > 1:
        component_filter = sys.argv[1]
        components = [(path, name) for path, name in components if component_filter.lower() in name.lower()]
        if not components:
            print(f"{Fore.RED}Componente não encontrado: {component_filter}{Style.RESET_ALL}")
            sys.exit(1)
    
    # Validar cada componente
    for path, name in components:
        validator.validate_component(path, name)
    
    # Imprimir relatório
    validator.print_report()
    
    # Exportar JSON se solicitado
    if '--json' in sys.argv:
        output_file = script_dir / 'conformance_report.json'
        validator.export_json(str(output_file))
    
    # Retornar código de erro se houver violações críticas
    if validator.stats['critical'] > 0:
        print(f"\n{Fore.RED}❌ Validação falhou! Correções críticas necessárias.{Style.RESET_ALL}")
        sys.exit(1)
    elif validator.stats['violations_found'] > 0:
        print(f"\n{Fore.YELLOW}⚠️  Validação com avisos. Revisar violações.{Style.RESET_ALL}")
        sys.exit(0)
    else:
        print(f"\n{Fore.GREEN}✅ Validação passou! Todos os componentes conformes.{Style.RESET_ALL}")
        sys.exit(0)

if __name__ == "__main__":
    main()