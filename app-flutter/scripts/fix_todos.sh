#!/bin/bash

# Script para padronizar TODOs no formato correto para a extensão TODO Tree

echo "🔍 Verificando e corrigindo formato dos TODOs..."
echo "============================================="
echo ""

# Contar TODOs atuais
TOTAL_TODOS=$(grep -r "TODO" lib --include="*.dart" | wc -l)
echo "📊 Total de TODOs encontrados: $TOTAL_TODOS"
echo ""

# Mostrar diferentes formatos encontrados
echo "📝 Formatos de TODO encontrados:"
echo "---------------------------------"
grep -r "TODO" lib --include="*.dart" | sed 's/.*\(\/\/.*TODO[^:]*:\?\).*/\1/' | sort | uniq -c | sort -rn
echo ""

# Sugestão de padronização
echo "✅ Formato recomendado para detecção pela extensão:"
echo "---------------------------------------------------"
echo "// TODO: Descrição simples"
echo "// TODO(autor): Descrição com autor"
echo "// FIXME: Algo que precisa ser corrigido"
echo "// HACK: Solução temporária"
echo "// NOTE: Nota importante"
echo ""

# Listar TODOs que podem não ser detectados (sem : após TODO)
echo "⚠️ TODOs que podem não ser detectados (falta ':'):"
echo "---------------------------------------------------"
grep -rn "TODO[^:(]" lib --include="*.dart" | grep -v "TODO:" | grep -v "TODO(" | head -10

echo ""
echo "💡 Dica: Para que a extensão TODO Tree detecte corretamente:"
echo "1. Reinicie o VSCode após criar .vscode/settings.json"
echo "2. Clique em 'Refresh' no painel TODO Tree"
echo "3. Verifique se a extensão está instalada: 'Gruntfuggly.todo-tree'"
echo ""
echo "🔧 Para corrigir automaticamente, você pode usar:"
echo "   sed -i '' 's/TODO /TODO: /g' lib/**/*.dart"
echo "   (mas revise antes de aplicar!)"