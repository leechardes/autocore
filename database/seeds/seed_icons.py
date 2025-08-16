#!/usr/bin/env python3
"""
Script de seed para popular tabela icons com ícones base do sistema AutoCore
"""

import sys
import json
from pathlib import Path

# Adiciona path para importar modules
sys.path.append(str(Path(__file__).parent.parent))

from shared.repositories import icons

def seed_icons():
    """Popula tabela icons com ícones padrão do sistema"""
    
    # Ícones de Iluminação
    lighting_icons = [
        {
            'name': 'light',
            'display_name': 'Luz',
            'category': 'lighting',
            'lucide_name': 'lightbulb',
            'material_name': 'lightbulb',
            'lvgl_symbol': 'LV_SYMBOL_LIGHT',
            'unicode_char': '\uf0eb',
            'emoji': '💡',
            'description': 'Ícone genérico para iluminação',
            'tags': json.dumps(['luz', 'iluminação', 'light', 'lampada'])
        },
        {
            'name': 'light_high',
            'display_name': 'Farol Alto',
            'category': 'lighting',
            'lucide_name': 'zap',
            'material_name': 'flash_on',
            'lvgl_symbol': 'LV_SYMBOL_LIGHT',
            'unicode_char': '\uf0e7',
            'emoji': '🔦',
            'description': 'Farol alto do veículo',
            'tags': json.dumps(['farol', 'alto', 'high', 'beam', 'headlight'])
        },
        {
            'name': 'light_low',
            'display_name': 'Farol Baixo',
            'category': 'lighting',
            'lucide_name': 'lightbulb',
            'material_name': 'lightbulb',
            'lvgl_symbol': 'LV_SYMBOL_LIGHT',
            'unicode_char': '\uf0eb',
            'emoji': '💡',
            'description': 'Farol baixo do veículo',
            'tags': json.dumps(['farol', 'baixo', 'low', 'beam', 'headlight'])
        },
        {
            'name': 'fog_light',
            'display_name': 'Farol de Neblina',
            'category': 'lighting',
            'lucide_name': 'cloud-fog',
            'material_name': 'foggy',
            'lvgl_symbol': 'LV_SYMBOL_WARNING',
            'unicode_char': '\uf0c2',
            'emoji': '🌫️',
            'description': 'Farol de neblina',
            'tags': json.dumps(['neblina', 'fog', 'light', 'farol'])
        },
        {
            'name': 'work_light',
            'display_name': 'Luz de Trabalho',
            'category': 'lighting',
            'lucide_name': 'flashlight',
            'material_name': 'flashlight_on',
            'lvgl_symbol': 'LV_SYMBOL_LIGHT',
            'unicode_char': '\uf526',
            'emoji': '🔦',
            'description': 'Luz auxiliar para trabalho',
            'tags': json.dumps(['trabalho', 'work', 'aux', 'auxiliar'])
        }
    ]
    
    # Ícones de Navegação
    navigation_icons = [
        {
            'name': 'home',
            'display_name': 'Início',
            'category': 'navigation',
            'lucide_name': 'home',
            'material_name': 'home',
            'lvgl_symbol': 'LV_SYMBOL_HOME',
            'unicode_char': '\uf015',
            'emoji': '🏠',
            'description': 'Página inicial',
            'tags': json.dumps(['home', 'início', 'principal', 'main'])
        },
        {
            'name': 'back',
            'display_name': 'Voltar',
            'category': 'navigation',
            'lucide_name': 'arrow-left',
            'material_name': 'arrow_back',
            'lvgl_symbol': 'LV_SYMBOL_LEFT',
            'unicode_char': '\uf053',
            'emoji': '⬅️',
            'description': 'Botão voltar',
            'tags': json.dumps(['voltar', 'back', 'anterior', 'previous'])
        },
        {
            'name': 'forward',
            'display_name': 'Avançar',
            'category': 'navigation',
            'lucide_name': 'arrow-right',
            'material_name': 'arrow_forward',
            'lvgl_symbol': 'LV_SYMBOL_RIGHT',
            'unicode_char': '\uf054',
            'emoji': '➡️',
            'description': 'Botão avançar',
            'tags': json.dumps(['avançar', 'forward', 'próximo', 'next'])
        },
        {
            'name': 'settings',
            'display_name': 'Configurações',
            'category': 'navigation',
            'lucide_name': 'settings',
            'material_name': 'settings',
            'lvgl_symbol': 'LV_SYMBOL_SETTINGS',
            'unicode_char': '\uf013',
            'emoji': '⚙️',
            'description': 'Configurações do sistema',
            'tags': json.dumps(['configurações', 'settings', 'config', 'setup'])
        },
        {
            'name': 'menu',
            'display_name': 'Menu',
            'category': 'navigation',
            'lucide_name': 'menu',
            'material_name': 'menu',
            'lvgl_symbol': 'LV_SYMBOL_LIST',
            'unicode_char': '\uf0c9',
            'emoji': '📋',
            'description': 'Menu principal',
            'tags': json.dumps(['menu', 'lista', 'opções', 'options'])
        }
    ]
    
    # Ícones de Controle
    control_icons = [
        {
            'name': 'power',
            'display_name': 'Liga/Desliga',
            'category': 'control',
            'lucide_name': 'power',
            'material_name': 'power_settings_new',
            'lvgl_symbol': 'LV_SYMBOL_POWER',
            'unicode_char': '\uf011',
            'emoji': '⚡',
            'description': 'Controle de energia',
            'tags': json.dumps(['power', 'energia', 'ligar', 'desligar'])
        },
        {
            'name': 'play',
            'display_name': 'Iniciar',
            'category': 'control',
            'lucide_name': 'play',
            'material_name': 'play_arrow',
            'lvgl_symbol': 'LV_SYMBOL_PLAY',
            'unicode_char': '\uf04b',
            'emoji': '▶️',
            'description': 'Iniciar operação',
            'tags': json.dumps(['play', 'iniciar', 'start', 'começar'])
        },
        {
            'name': 'stop',
            'display_name': 'Parar',
            'category': 'control',
            'lucide_name': 'square',
            'material_name': 'stop',
            'lvgl_symbol': 'LV_SYMBOL_STOP',
            'unicode_char': '\uf04d',
            'emoji': '⏹️',
            'description': 'Parar operação',
            'tags': json.dumps(['stop', 'parar', 'pausa', 'halt'])
        },
        {
            'name': 'pause',
            'display_name': 'Pausar',
            'category': 'control',
            'lucide_name': 'pause',
            'material_name': 'pause',
            'lvgl_symbol': 'LV_SYMBOL_PAUSE',
            'unicode_char': '\uf04c',
            'emoji': '⏸️',
            'description': 'Pausar operação',
            'tags': json.dumps(['pause', 'pausar', 'hold', 'wait'])
        },
        {
            'name': 'winch_in',
            'display_name': 'Guincho Recolher',
            'category': 'control',
            'lucide_name': 'rotate-ccw',
            'material_name': 'rotate_left',
            'lvgl_symbol': 'LV_SYMBOL_LOOP',
            'unicode_char': '\uf0e2',
            'emoji': '🔄',
            'description': 'Recolher guincho',
            'tags': json.dumps(['guincho', 'winch', 'recolher', 'in', 'pull'])
        },
        {
            'name': 'winch_out',
            'display_name': 'Guincho Soltar',
            'category': 'control',
            'lucide_name': 'rotate-cw',
            'material_name': 'rotate_right',
            'lvgl_symbol': 'LV_SYMBOL_LOOP',
            'unicode_char': '\uf01e',
            'emoji': '🔄',
            'description': 'Soltar guincho',
            'tags': json.dumps(['guincho', 'winch', 'soltar', 'out', 'release'])
        },
        {
            'name': 'aux',
            'display_name': 'Auxiliar',
            'category': 'control',
            'lucide_name': 'more-horizontal',
            'material_name': 'more_horiz',
            'lvgl_symbol': 'LV_SYMBOL_SETTINGS',
            'unicode_char': '\uf141',
            'emoji': '🔧',
            'description': 'Função auxiliar genérica',
            'tags': json.dumps(['aux', 'auxiliar', 'extra', 'other'])
        }
    ]
    
    # Ícones de Status
    status_icons = [
        {
            'name': 'ok',
            'display_name': 'OK',
            'category': 'status',
            'lucide_name': 'check',
            'material_name': 'check',
            'lvgl_symbol': 'LV_SYMBOL_OK',
            'unicode_char': '\uf00c',
            'emoji': '✅',
            'description': 'Status OK/Sucesso',
            'tags': json.dumps(['ok', 'success', 'check', 'valid'])
        },
        {
            'name': 'warning',
            'display_name': 'Aviso',
            'category': 'status',
            'lucide_name': 'alert-triangle',
            'material_name': 'warning',
            'lvgl_symbol': 'LV_SYMBOL_WARNING',
            'unicode_char': '\uf071',
            'emoji': '⚠️',
            'description': 'Aviso/Atenção',
            'tags': json.dumps(['warning', 'aviso', 'atenção', 'alert'])
        },
        {
            'name': 'error',
            'display_name': 'Erro',
            'category': 'status',
            'lucide_name': 'x-circle',
            'material_name': 'error',
            'lvgl_symbol': 'LV_SYMBOL_CLOSE',
            'unicode_char': '\uf057',
            'emoji': '❌',
            'description': 'Erro/Falha',
            'tags': json.dumps(['error', 'erro', 'fail', 'problem'])
        },
        {
            'name': 'wifi',
            'display_name': 'WiFi',
            'category': 'status',
            'lucide_name': 'wifi',
            'material_name': 'wifi',
            'lvgl_symbol': 'LV_SYMBOL_WIFI',
            'unicode_char': '\uf1eb',
            'emoji': '📶',
            'description': 'Status WiFi',
            'tags': json.dumps(['wifi', 'wireless', 'network', 'internet'])
        },
        {
            'name': 'battery',
            'display_name': 'Bateria',
            'category': 'status',
            'lucide_name': 'battery',
            'material_name': 'battery_full',
            'lvgl_symbol': 'LV_SYMBOL_BATTERY_FULL',
            'unicode_char': '\uf240',
            'emoji': '🔋',
            'description': 'Status da bateria',
            'tags': json.dumps(['battery', 'bateria', 'power', 'charge'])
        },
        {
            'name': 'bluetooth',
            'display_name': 'Bluetooth',
            'category': 'status',
            'lucide_name': 'bluetooth',
            'material_name': 'bluetooth',
            'lvgl_symbol': 'LV_SYMBOL_BLUETOOTH',
            'unicode_char': '\uf293',
            'emoji': '📶',
            'description': 'Status Bluetooth',
            'tags': json.dumps(['bluetooth', 'wireless', 'connection', 'bt'])
        }
    ]
    
    # Ícones Customizados (apenas estrutura, SVG seria adicionado posteriormente)
    custom_icons = [
        {
            'name': 'compressor',
            'display_name': 'Compressor de Ar',
            'category': 'control',
            'is_custom': True,
            'unicode_char': '\uf1b6',
            'emoji': '💨',
            'description': 'Compressor de ar do sistema',
            'tags': json.dumps(['compressor', 'ar', 'air', 'pressure'])
        },
        {
            'name': '4x4_mode',
            'display_name': 'Modo 4x4',
            'category': 'control',
            'is_custom': True,
            'unicode_char': '\uf1b9',
            'emoji': '🚙',
            'description': 'Ativação do modo 4x4',
            'tags': json.dumps(['4x4', 'tração', 'all-wheel', 'drive'])
        },
        {
            'name': 'diff_lock',
            'display_name': 'Bloqueio de Diferencial',
            'category': 'control',
            'is_custom': True,
            'unicode_char': '\uf023',
            'emoji': '🔒',
            'description': 'Bloqueio do diferencial',
            'tags': json.dumps(['diff', 'diferencial', 'lock', 'bloqueio'])
        }
    ]
    
    # Combinar todos os ícones
    all_icons = lighting_icons + navigation_icons + control_icons + status_icons + custom_icons
    
    print(f"Inserindo {len(all_icons)} ícones no banco de dados...")
    
    # Inserir ícones
    try:
        inserted_count = icons.bulk_insert(all_icons)
        print(f"✅ {inserted_count} ícones inseridos com sucesso!")
        
        # Mostrar estatísticas
        categories = icons.get_categories()
        print(f"\n📊 Categorias criadas: {len(categories)}")
        for category in categories:
            count = len(icons.get_all(category=category))
            print(f"  • {category}: {count} ícones")
        
        return True
        
    except Exception as e:
        print(f"❌ Erro ao inserir ícones: {str(e)}")
        return False

def main():
    """Função principal"""
    print("🎨 AutoCore - Seed de Ícones")
    print("=" * 40)
    
    success = seed_icons()
    
    if success:
        print("\n🎉 Seed completado com sucesso!")
        print("Os ícones base do sistema foram instalados.")
    else:
        print("\n💥 Erro durante o seed!")
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())