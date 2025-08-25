# A40 - Cleanup Agent

## 📋 Objetivo
Executar limpeza conservativa do projeto Flutter conforme CLEANUP-PLAN.md, removendo código morto, arquivos obsoletos e organizando estrutura.

## 🎯 Tarefas

### 1. Análise & Identificação
- [ ] Identificar arquivos não utilizados
- [ ] Detectar imports não utilizados
- [ ] Encontrar código comentado obsoleto
- [ ] Listar widgets deprecated
- [ ] Mapear duplicações de código

### 2. Remoção Segura
- [ ] Backup antes de remover
- [ ] Remover arquivos obsoletos
- [ ] Limpar imports não utilizados
- [ ] Deletar código comentado antigo
- [ ] Remover packages não utilizados

### 3. Organização de Estrutura
- [ ] Reorganizar pastas por feature
- [ ] Consolidar arquivos similares
- [ ] Padronizar nomenclatura
- [ ] Criar barrel exports
- [ ] Atualizar documentação

### 4. Limpeza de Assets
- [ ] Remover imagens não utilizadas
- [ ] Otimizar tamanho de assets
- [ ] Limpar fonts duplicadas
- [ ] Organizar pasta assets
- [ ] Atualizar pubspec.yaml

## 🔧 Comandos

```bash
# Análise de código não utilizado
flutter pub run dart_code_metrics:metrics check-unused-code lib
flutter pub run dart_code_metrics:metrics check-unused-files lib

# Limpeza de imports
dart fix --apply
flutter format lib/

# Análise de dependencies
flutter pub deps
flutter pub outdated

# Limpeza de cache
flutter clean
flutter pub cache clean --force
cd android && ./gradlew clean

# Backup antes de limpeza
git stash
git checkout -b cleanup-backup
```

## ✅ Checklist de Validação

### Antes da Limpeza
- [ ] Backup completo criado
- [ ] Branch separada para cleanup
- [ ] Testes rodando com sucesso
- [ ] Lista de arquivos para remover
- [ ] Documentação de mudanças

### Durante a Limpeza
- [ ] Remover um arquivo por vez
- [ ] Testar após cada remoção
- [ ] Verificar dependencies
- [ ] Atualizar imports
- [ ] Manter git commits granulares

### Após a Limpeza
- [ ] 0 warnings no analyzer
- [ ] Todos os testes passando
- [ ] App funcionando normalmente
- [ ] Documentação atualizada
- [ ] Métricas de redução

## 📊 Resultado Esperado

### Métricas de Limpeza
```yaml
files:
  before: 250
  after: 180
  removed: 70
  reduction: "28%"

lines_of_code:
  before: 15000
  after: 11000
  removed: 4000
  reduction: "27%"

dependencies:
  before: 45
  after: 32
  removed: 13
  reduction: "29%"

assets:
  before: "15MB"
  after: "8MB"
  removed: "7MB"
  reduction: "47%"
```

## 🚀 Estratégia de Implementação

### Fase 1: Identificação (30 min)
```bash
# Listar arquivos não utilizados
find lib -name "*.dart" | while read file; do
  grep -r "$(basename $file .dart)" lib --include="*.dart" || echo "Unused: $file"
done

# Código comentado
grep -r "^[[:space:]]*//.*" lib | wc -l

# Imports não utilizados
flutter analyze | grep "unused_import"
```

### Fase 2: Backup & Preparação (15 min)
```bash
# Criar backup
git checkout -b cleanup-$(date +%Y%m%d)
tar -czf backup-before-cleanup.tar.gz lib/

# Documentar estado atual
flutter analyze > before-cleanup.txt
find lib -name "*.dart" | wc -l > file-count-before.txt
```

### Fase 3: Remoção Conservativa (1h)
```bash
# Remover arquivos identificados
rm lib/legacy/old_widget.dart
rm lib/unused/deprecated_service.dart

# Limpar imports
dart fix --apply

# Remover packages
flutter pub remove unused_package
```

### Fase 4: Reorganização (1h)
```
lib/
├── core/           # Shared core functionality
├── features/       # Feature modules
│   ├── auth/
│   ├── dashboard/
│   └── settings/
├── shared/         # Shared widgets/utils
└── main.dart
```

## ⚠️ Pontos de Atenção

### Arquivos Suspeitos de Obsoletos
```
lib/legacy/
lib/old/
lib/backup/
lib/temp/
lib/test_*.dart
lib/**/*_old.dart
lib/**/*_backup.dart
lib/**/*_deprecated.dart
```

### Código a Verificar
- Widgets não referenciados
- Services duplicados
- Models antigos
- Providers não utilizados
- Utils deprecated

### Riscos
- Remover arquivo ainda em uso
- Quebrar imports circulares
- Deletar configurações importantes
- Perder customizações locais
- Remover código de feature flags

## 📝 Template de Log

```
[HH:MM:SS] 🚀 [A40] Iniciando Cleanup
[HH:MM:SS] 🔍 [A40] Analisando arquivos não utilizados
[HH:MM:SS] 📊 [A40] Identificados: 70 arquivos obsoletos
[HH:MM:SS] 💾 [A40] Criando backup completo
[HH:MM:SS] 🗑️ [A40] Removendo arquivos obsoletos
[HH:MM:SS] ✅ [A40] 35 arquivos removidos com segurança
[HH:MM:SS] 📁 [A40] Reorganizando estrutura
[HH:MM:SS] ✅ [A40] Estrutura otimizada
[HH:MM:SS] 📊 [A40] Redução: 28% files, 27% LOC
[HH:MM:SS] ✅ [A40] Cleanup CONCLUÍDO
```

---
**Data de Criação**: 25/08/2025
**Tipo**: Maintenance
**Prioridade**: Baixa
**Estimativa**: 2.5 horas
**Status**: Pronto para Execução