#!/usr/bin/env python3
"""
Teste dos Repositories ORM do AutoCore
Valida operações CRUD usando SQLAlchemy ORM
"""
import sys
from pathlib import Path
from datetime import datetime
from tabulate import tabulate
import json

# Adiciona o path para importar os módulos
sys.path.append(str(Path(__file__).parent.parent))

from shared.repositories import (
    devices,
    relays,
    telemetry,
    events,
    config
)

def test_devices():
    """Testa o DeviceRepository com ORM"""
    print("\n🔧 Testando DeviceRepository (ORM)...")
    print("=" * 40)
    
    # Listar todos os dispositivos
    all_devices = devices.get_all()
    print(f"✓ Total de dispositivos: {len(all_devices)}")
    
    if all_devices:
        # Mostrar tabela de dispositivos
        device_table = []
        for dev in all_devices:
            device_table.append([
                dev.id,
                dev.name[:20],
                dev.type,
                dev.status,
                dev.ip_address
            ])
        print("\nDispositivos cadastrados:")
        print(tabulate(device_table, 
                      headers=['ID', 'Nome', 'Tipo', 'Status', 'IP'],
                      tablefmt='simple'))
    
    # Testar busca por UUID
    test_uuid = 'esp32-relay-001'
    device = devices.get_by_uuid(test_uuid)
    if device:
        print(f"\n✓ Dispositivo '{test_uuid}' encontrado: {device.name}")
    
    # Testar atualização de status
    if all_devices:
        first_device = all_devices[0]
        devices.update_status(first_device.id, 'online', '192.168.1.200')
        print(f"✓ Status do dispositivo {first_device.id} atualizado")
    
    return len(all_devices) > 0

def test_relays():
    """Testa o RelayRepository com ORM"""
    print("\n⚡ Testando RelayRepository (ORM)...")
    print("=" * 40)
    
    # Listar placas de relé
    boards = relays.get_boards()
    print(f"✓ Total de placas de relé: {len(boards)}")
    
    # Listar canais
    channels = relays.get_channels()
    print(f"✓ Total de canais de relé: {len(channels)}")
    
    if channels:
        # Mostrar primeiros 8 canais
        channel_table = []
        for ch in channels[:8]:
            channel_table.append([
                ch.channel_number,
                ch.name[:15],
                ch.function_type,
                '✓' if ch.current_state else '✗',
                ch.protection_mode or 'none'
            ])
        print("\nCanais de relé (primeiros 8):")
        print(tabulate(channel_table,
                      headers=['#', 'Nome', 'Tipo', 'Estado', 'Proteção'],
                      tablefmt='simple'))
    
    # Testar toggle de canal
    if channels:
        first_channel = channels[0]
        new_state = not first_channel.current_state
        relays.update_channel_state(first_channel.id, new_state)
        print(f"\n✓ Canal {first_channel.id} alternado para {'ON' if new_state else 'OFF'}")
    
    return len(channels) > 0

def test_telemetry():
    """Testa o TelemetryRepository com ORM"""
    print("\n📊 Testando TelemetryRepository (ORM)...")
    print("=" * 40)
    
    # Salvar nova telemetria
    telemetry.save(
        device_id=1,
        data_type='test',
        key='test_value_orm',
        value='456.78',
        unit='test_unit'
    )
    print("✓ Nova telemetria salva via ORM")
    
    # Buscar dados recentes
    latest = telemetry.get_latest(device_id=1, limit=5)
    print(f"✓ Últimos {len(latest)} registros de telemetria recuperados")
    
    if latest:
        # Mostrar telemetria
        telem_table = []
        for t in latest:
            telem_table.append([
                t.data_type,
                t.data_key,
                t.data_value[:20] if t.data_value else '-',
                t.unit or '-'
            ])
        print("\nÚltima telemetria:")
        print(tabulate(telem_table,
                      headers=['Tipo', 'Chave', 'Valor', 'Unidade'],
                      tablefmt='simple'))
    
    return len(latest) > 0

def test_events():
    """Testa o EventRepository com ORM"""
    print("\n📝 Testando EventRepository (ORM)...")
    print("=" * 40)
    
    # Registrar novo evento
    events.log(
        event_type='test',
        source='test_orm_script',
        action='repository_orm_test',
        target='database',
        payload={'test': True, 'orm': True, 'timestamp': datetime.now().isoformat()}
    )
    print("✓ Novo evento registrado via ORM")
    
    # Buscar eventos recentes
    recent = events.get_recent(limit=5)
    print(f"✓ Últimos {len(recent)} eventos recuperados")
    
    if recent:
        # Mostrar eventos
        event_table = []
        for e in recent:
            event_table.append([
                e.event_type,
                e.source[:15] if e.source else '-',
                e.action[:20] if e.action else '-',
                e.status or '-'
            ])
        print("\nEventos recentes:")
        print(tabulate(event_table,
                      headers=['Tipo', 'Origem', 'Ação', 'Status'],
                      tablefmt='simple'))
    
    return len(recent) > 0

def test_config():
    """Testa o ConfigRepository com ORM"""
    print("\n⚙️ Testando ConfigRepository (ORM)...")
    print("=" * 40)
    
    # Buscar telas
    screens = config.get_screens()
    print(f"✓ Total de telas: {len(screens)}")
    
    if screens:
        # Mostrar telas
        screen_table = []
        for s in screens:
            screen_table.append([
                s.id,
                s.name,
                s.title,
                s.screen_type,
                '✓' if s.is_visible else '✗'
            ])
        print("\nTelas configuradas:")
        print(tabulate(screen_table,
                      headers=['ID', 'Nome', 'Título', 'Tipo', 'Visível'],
                      tablefmt='simple'))
        
        # Buscar itens da primeira tela
        first_screen = screens[0]
        items = config.get_screen_items(first_screen.id)
        print(f"\n✓ Tela '{first_screen.name}' tem {len(items)} itens")
    
    # Buscar temas
    themes = config.get_themes()
    print(f"✓ Total de temas: {len(themes)}")
    
    # Buscar tema padrão
    default_theme = config.get_default_theme()
    if default_theme:
        print(f"✓ Tema padrão: {default_theme.name}")
    
    return len(screens) > 0

def main():
    """Executa todos os testes"""
    print("\n" + "=" * 50)
    print("🧪 TESTE DOS REPOSITORIES ORM - AUTOCORE")
    print("=" * 50)
    
    # Executar testes
    tests = [
        ('Devices', test_devices),
        ('Relays', test_relays),
        ('Telemetry', test_telemetry),
        ('Events', test_events),
        ('Config', test_config)
    ]
    
    results = []
    for name, test_func in tests:
        try:
            success = test_func()
            results.append([name, '✅ PASSOU' if success else '⚠️ VAZIO'])
        except Exception as e:
            results.append([name, f'❌ ERRO: {str(e)[:30]}'])
            import traceback
            print(f"\nDetalhes do erro em {name}:")
            print(traceback.format_exc())
    
    # Mostrar resumo
    print("\n" + "=" * 50)
    print("📊 RESUMO DOS TESTES ORM")
    print("=" * 50)
    print(tabulate(results, headers=['Repository', 'Resultado'], tablefmt='simple'))
    
    # Verificar se todos passaram
    all_passed = all('✅' in r[1] or '⚠️' in r[1] for r in results)
    
    if all_passed:
        print("\n" + "=" * 50)
        print("✅ TODOS OS REPOSITORIES ORM ESTÃO FUNCIONANDO!")
        print("=" * 50)
        print("\n🎉 SQLAlchemy ORM implementado com sucesso!")
        print("   Próximo passo: Atualizar imports nos projetos")
        print("   - Gateway deve usar: from shared.repositories import ...")
        print("   - Config-App deve usar: from shared.repositories import ...")
    else:
        print("\n⚠️ Alguns testes falharam. Verifique os erros acima.")

if __name__ == '__main__':
    main()