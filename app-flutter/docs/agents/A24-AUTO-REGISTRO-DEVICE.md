# A24 - Agente de Auto-Registro de Dispositivo Flutter

## 📋 Objetivo
Implementar sistema de auto-registro automático do dispositivo Flutter no backend da API, verificando se já está registrado e fazendo o registro automático na primeira execução.

## 🎯 Tarefas
1. Criar serviço de registro de dispositivo (DeviceRegistrationService)
2. Implementar verificação de registro existente
3. Adicionar auto-registro na inicialização do app
4. Integrar com ConfigService para validar antes de buscar configuração
5. Persistir UUID do dispositivo localmente
6. Adicionar logs detalhados do processo
7. Testar fluxo completo de registro e configuração

## 🔧 Implementação

### 1. DeviceRegistrationService
- Criar serviço singleton para gerenciar registro
- Gerar UUID único para o dispositivo se não existir
- Verificar se dispositivo está registrado via API
- Fazer auto-registro se necessário
- Persistir informações localmente

### 2. Fluxo de Registro
```
App Inicia → Verifica UUID local → 
  Se não existe → Gera novo UUID → Salva localmente
  Se existe → Usa UUID salvo
→ Tenta buscar config com UUID
  Se 404 → Registra dispositivo → Busca config novamente
  Se OK → Continua normalmente
```

### 3. Dados do Dispositivo
- UUID: Gerado ou recuperado do storage
- Name: "AutoCore Flutter App"
- Type: "esp32_display"
- MAC: Gerado baseado no UUID
- IP: IP local do dispositivo
- Firmware Version: Versão do app
- Hardware Version: "Flutter-v1.0"
- Capabilities: touch, wifi, responsive

## 📁 Arquivos a Criar/Modificar
1. `lib/infrastructure/services/device_registration_service.dart` - NOVO
2. `lib/infrastructure/services/config_service.dart` - Integrar auto-registro
3. `lib/main.dart` - Chamar registro na inicialização
4. `lib/core/constants/device_constants.dart` - NOVO (constantes do dispositivo)

## ✅ Checklist de Validação
- [ ] UUID é gerado e persistido corretamente
- [ ] Verificação de registro funciona
- [ ] Auto-registro é feito quando necessário
- [ ] Config é buscada após registro
- [ ] Logs mostram processo completo
- [ ] App não trava se API estiver offline
- [ ] Registro é feito apenas uma vez

## 📊 Resultado Esperado
App Flutter se auto-registra na primeira execução e consegue buscar sua configuração do endpoint `/api/config/full/{device_uuid}` sem erros 404.

## 🚀 Comando de Execução
```bash
cd /Users/leechardes/Projetos/AutoCore/app-flutter
flutter analyze
flutter run
```

## 📝 Observações
- O UUID deve ser único e persistente para cada instalação
- O registro deve ser idempotente (múltiplas tentativas não causam erro)
- Deve funcionar offline (não travar o app)
- Usar SharedPreferences para persistir dados localmente