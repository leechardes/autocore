#!/usr/bin/env python3
"""
Script de teste para funcionalidades da tabela icons
"""

import sys
import json
from pathlib import Path

# Adiciona path para importar modules
sys.path.append(str(Path(__file__).parent.parent))

from shared.repositories import icons

def test_basic_operations():
    """Testa operações básicas do repository"""
    print("🔍 Testando operações básicas...")
    
    # Listar todos os ícones
    all_icons = icons.get_all()
    print(f"  • Total de ícones: {len(all_icons)}")
    
    # Listar por categoria
    lighting_icons = icons.get_all(category='lighting')
    print(f"  • Ícones de iluminação: {len(lighting_icons)}")
    
    # Buscar por nome
    light_icon = icons.get_by_name('light')
    if light_icon:
        print(f"  • Ícone 'light': {light_icon.display_name}")
    
    # Categorias disponíveis
    categories = icons.get_categories()
    print(f"  • Categorias: {categories}")

def test_platform_mappings():
    """Testa mapeamentos por plataforma"""
    print("\n🌐 Testando mapeamentos por plataforma...")
    
    # Mapeamento para Web
    web_mapping = icons.get_platform_mapping('web')
    print(f"  • Web - Total: {len(web_mapping)} ícones")
    print(f"    Exemplo: light = {web_mapping.get('light', 'N/A')}")
    
    # Mapeamento para Mobile
    mobile_mapping = icons.get_platform_mapping('mobile')
    print(f"  • Mobile - Total: {len(mobile_mapping)} ícones")
    print(f"    Exemplo: power = {mobile_mapping.get('power', 'N/A')}")
    
    # Mapeamento para ESP32
    esp32_mapping = icons.get_platform_mapping('esp32')
    print(f"  • ESP32 - Total: {len(esp32_mapping)} ícones")
    print(f"    Exemplo: ok = {esp32_mapping.get('ok', 'N/A')}")

def test_fallbacks():
    """Testa sistema de fallbacks"""
    print("\n🔄 Testando sistema de fallbacks...")
    
    # Buscar ícone com fallbacks
    icon_with_fallbacks = icons.get_with_fallbacks('power')
    if icon_with_fallbacks:
        print(f"  • Ícone: {icon_with_fallbacks['display_name']}")
        print(f"  • Lucide: {icon_with_fallbacks['lucide_name']}")
        print(f"  • Material: {icon_with_fallbacks['material_name']}")
        print(f"  • LVGL: {icon_with_fallbacks['lvgl_symbol']}")
        print(f"  • Emoji: {icon_with_fallbacks['emoji']}")

def test_search():
    """Testa funcionalidade de busca"""
    print("\n🔍 Testando busca...")
    
    # Buscar por termo
    search_results = icons.search('luz')
    print(f"  • Busca por 'luz': {len(search_results)} resultados")
    for result in search_results[:3]:  # Mostrar apenas primeiros 3
        print(f"    - {result.name}: {result.display_name}")
    
    # Buscar por categoria
    control_results = icons.search('control')
    print(f"  • Busca por 'control': {len(control_results)} resultados")

def test_custom_icons():
    """Testa criação de ícones customizados"""
    print("\n🎨 Testando ícones customizados...")
    
    # Criar ícone customizado
    custom_svg = '''<svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
        <circle cx="12" cy="12" r="10"/>
        <line x1="12" y1="8" x2="12" y2="12"/>
        <line x1="12" y1="16" x2="12.01" y2="16"/>
    </svg>'''
    
    try:
        custom_icon = icons.create_custom(
            name='test_custom',
            svg_content=custom_svg,
            display_name='Ícone de Teste',
            category='test',
            description='Ícone customizado para teste'
        )
        print(f"  • Ícone customizado criado: {custom_icon.name}")
        
        # Buscar o ícone criado
        found_icon = icons.get_by_name('test_custom')
        if found_icon:
            print(f"  • Confirmado: {found_icon.display_name} (is_custom: {found_icon.is_custom})")
        
        # Remover ícone de teste
        if icons.delete(custom_icon.id):
            print(f"  • Ícone de teste removido")
            
    except Exception as e:
        print(f"  • Erro ao criar ícone customizado: {e}")

def show_icon_details(icon_name):
    """Mostra detalhes completos de um ícone"""
    print(f"\n📋 Detalhes do ícone '{icon_name}':")
    
    icon_details = icons.get_with_fallbacks(icon_name)
    if not icon_details:
        print("  • Ícone não encontrado")
        return
    
    print(f"  • ID: {icon_details['id']}")
    print(f"  • Nome: {icon_details['name']}")
    print(f"  • Título: {icon_details['display_name']}")
    print(f"  • Categoria: {icon_details['category']}")
    print(f"  • Customizado: {icon_details['is_custom']}")
    print(f"  • Descrição: {icon_details['description']}")
    
    print("  • Mapeamentos:")
    if icon_details['lucide_name']:
        print(f"    - Lucide: {icon_details['lucide_name']}")
    if icon_details['material_name']:
        print(f"    - Material: {icon_details['material_name']}")
    if icon_details['fontawesome_name']:
        print(f"    - FontAwesome: {icon_details['fontawesome_name']}")
    if icon_details['lvgl_symbol']:
        print(f"    - LVGL: {icon_details['lvgl_symbol']}")
    if icon_details['unicode_char']:
        print(f"    - Unicode: {icon_details['unicode_char']}")
    if icon_details['emoji']:
        print(f"    - Emoji: {icon_details['emoji']}")

def main():
    """Função principal"""
    print("🎨 AutoCore - Teste do Sistema de Ícones")
    print("=" * 50)
    
    try:
        test_basic_operations()
        test_platform_mappings()
        test_fallbacks()
        test_search()
        test_custom_icons()
        
        # Mostrar detalhes de alguns ícones específicos
        show_icon_details('power')
        show_icon_details('compressor')
        
        print("\n✅ Todos os testes executados com sucesso!")
        
    except Exception as e:
        print(f"\n❌ Erro durante os testes: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())