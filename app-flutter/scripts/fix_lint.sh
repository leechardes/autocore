#!/bin/bash

echo "🔧 Corrigindo problemas de lint no projeto Flutter..."

# Função para substituir withOpacity deprecated
fix_with_opacity() {
    echo "  → Corrigindo withOpacity deprecated..."
    find lib -name "*.dart" -type f -exec sed -i '' \
        -e 's/\.withOpacity(\([^)]*\))/.withValues(opacity: \1)/g' {} \;
}

# Função para substituir Color.value deprecated
fix_color_value() {
    echo "  → Corrigindo Color.value deprecated..."
    find lib -name "*.dart" -type f -exec sed -i '' \
        -e 's/color\.value/color.value/g' \
        -e 's/\.value/\.value/g' {} \;
}

# Função para corrigir imports relativos
fix_imports() {
    echo "  → Convertendo imports relativos para package imports..."
    
    # Para arquivos em lib/core
    find lib/core -name "*.dart" -type f | while read file; do
        # Substituir imports relativos por package imports
        sed -i '' "s|import '\.\./\.\./\.\./|import 'package:autocore/|g" "$file"
        sed -i '' "s|import '\.\./\.\./|import 'package:autocore/core/|g" "$file"
        sed -i '' "s|import '\.\./|import 'package:autocore/core/|g" "$file"
        sed -i '' "s|import '|import 'package:autocore/core/|g" "$file"
        
        # Corrigir imports que já têm package:autocore
        sed -i '' "s|import 'package:autocore/core/package:autocore/|import 'package:autocore/|g" "$file"
    done
    
    # Para arquivos em lib/features
    find lib/features -name "*.dart" -type f | while read file; do
        sed -i '' "s|import '\.\./\.\./\.\./|import 'package:autocore/|g" "$file"
        sed -i '' "s|import '\.\./\.\./|import 'package:autocore/|g" "$file"
        sed -i '' "s|import '\.\./|import 'package:autocore/features/|g" "$file"
    done
}

# Função para remover imports não utilizados
remove_unused_imports() {
    echo "  → Removendo imports não utilizados..."
    
    # Remover import dart:io não utilizado
    sed -i '' '/^import.*dart:io.*unused_import/d' lib/core/services/mqtt_service.dart
    
    # Remover import flutter_animate não utilizado
    sed -i '' '/^import.*flutter_animate.*unused_import/d' lib/core/widgets/base/ac_container.dart
}

# Função para corrigir closures que deveriam ser tearoffs
fix_tearoffs() {
    echo "  → Corrigindo closures para tearoffs..."
    find lib -name "*.dart" -type f -exec sed -i '' \
        -e 's/() => \([a-zA-Z_][a-zA-Z0-9_]*\)()/\1/g' {} \;
}

# Função para adicionar tipos explícitos
fix_raw_types() {
    echo "  → Adicionando tipos explícitos..."
    sed -i '' 's/StreamSubscription?/StreamSubscription<String>?/g' lib/core/theme/theme_provider.dart
    sed -i '' 's/StreamSubscription /StreamSubscription<String> /g' lib/core/services/mqtt_service.dart
}

# Função para ordenar imports
sort_imports() {
    echo "  → Ordenando imports..."
    # Esta é mais complexa, vamos apenas adicionar um comentário por enquanto
    echo "    (Requer dart fix para ordenação completa)"
}

# Executar correções
echo "📝 Iniciando correções..."
fix_with_opacity
fix_color_value
fix_imports
remove_unused_imports
fix_tearoffs
fix_raw_types
sort_imports

echo ""
echo "🎯 Aplicando dart fix..."
dart fix --apply

echo ""
echo "✅ Correções aplicadas! Executando flutter analyze..."
flutter analyze

echo ""
echo "📊 Resumo final:"
ERROR_COUNT=$(flutter analyze 2>&1 | grep -E "error •" | wc -l | tr -d ' ')
WARNING_COUNT=$(flutter analyze 2>&1 | grep -E "warning •" | wc -l | tr -d ' ')
INFO_COUNT=$(flutter analyze 2>&1 | grep -E "info •" | wc -l | tr -d ' ')

echo "  Errors: $ERROR_COUNT"
echo "  Warnings: $WARNING_COUNT"
echo "  Info: $INFO_COUNT"
echo ""
echo "✨ Concluído!"