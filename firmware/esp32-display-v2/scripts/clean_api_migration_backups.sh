#!/bin/bash

# =============================================================================
# Script de Limpeza de Backups - Migração MQTT para API REST
# AutoTech HMI Display v2
# =============================================================================

echo "==============================================="
echo "🧹 AutoTech - Limpeza de Backups da Migração API"
echo "==============================================="
echo ""

# Definir cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretório raiz do projeto
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}📂 Diretório do projeto: $PROJECT_ROOT${NC}"
echo ""

# Procurar arquivos de backup da migração API
echo "🔍 Procurando arquivos de backup da migração API..."
echo ""

backup_files=($(find . -name "*.backup_api_migration_*" -type f 2>/dev/null | sort))

if [ ${#backup_files[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Nenhum arquivo de backup encontrado.${NC}"
    echo "   Padrão procurado: *.backup_api_migration_*"
    exit 0
fi

echo -e "${GREEN}✅ Encontrados ${#backup_files[@]} arquivo(s) de backup:${NC}"
echo ""

# Listar todos os backups encontrados
for file in "${backup_files[@]}"; do
    size=$(ls -lh "$file" | awk '{print $5}')
    date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d. -f1)
    echo "  📄 $file"
    echo "     💾 Tamanho: $size | 📅 Data: $date"
done

echo ""

# Calcular tamanho total dos backups
total_size=$(find . -name "*.backup_api_migration_*" -type f -exec ls -l {} \; | awk '{sum += $5} END {print sum}')
total_size_mb=$(echo "scale=2; $total_size / 1024 / 1024" | bc -l 2>/dev/null || echo "N/A")

echo -e "${BLUE}📊 Tamanho total dos backups: ${total_size} bytes (~${total_size_mb} MB)${NC}"
echo ""

# Verificar se existe o arquivo de log de backups
backup_log="docs/migrations/BACKUP_LIST_API_MIGRATION.txt"
if [ -f "$backup_log" ]; then
    echo -e "${GREEN}📋 Log de backups encontrado: $backup_log${NC}"
    echo "   Conteúdo do log:"
    echo ""
    while IFS= read -r line; do
        if [[ $line == \[*\]* ]]; then
            echo -e "   ${YELLOW}$line${NC}"
        elif [[ $line == \#* ]]; then
            echo -e "   ${BLUE}$line${NC}"
        else
            echo "   $line"
        fi
    done < "$backup_log"
    echo ""
fi

# Perguntar ao usuário se deseja remover
echo -e "${YELLOW}❓ Deseja remover todos os arquivos de backup da migração API?${NC}"
echo "   Esta ação NÃO pode ser desfeita!"
echo ""
echo "   Opções:"
echo "   [s/S] - Sim, remover todos os backups"
echo "   [n/N] - Não, manter os backups"
echo "   [l/L] - Listar detalhes dos backups primeiro"
echo ""

while true; do
    read -p "Sua escolha [s/n/l]: " choice
    case $choice in
        [Ss]* )
            echo ""
            echo "🗑️  Removendo arquivos de backup..."
            
            removed_count=0
            for file in "${backup_files[@]}"; do
                if rm "$file" 2>/dev/null; then
                    echo -e "   ${GREEN}✅ Removido: $file${NC}"
                    ((removed_count++))
                else
                    echo -e "   ${RED}❌ Erro ao remover: $file${NC}"
                fi
            done
            
            echo ""
            echo -e "${GREEN}🎉 Concluído! Removidos $removed_count arquivo(s) de backup.${NC}"
            
            # Limpar o log de backups
            if [ -f "$backup_log" ]; then
                echo "# Lista de Backups - Migração MQTT para API REST" > "$backup_log"
                echo "# Formato: [TIMESTAMP] [ARQUIVO_ORIGINAL] -> [ARQUIVO_BACKUP]" >> "$backup_log"
                echo "# =====================================================================" >> "$backup_log"
                echo "# Backups removidos em $(date '+%Y-%m-%d %H:%M:%S')" >> "$backup_log"
                echo ""
                echo -e "${GREEN}📋 Log de backups limpo.${NC}"
            fi
            
            # Mostrar espaço liberado
            echo -e "${BLUE}💾 Espaço liberado: ~${total_size_mb} MB${NC}"
            echo ""
            echo -e "${GREEN}✨ Limpeza concluída com sucesso!${NC}"
            break
            ;;
        [Nn]* )
            echo ""
            echo -e "${BLUE}ℹ️  Operação cancelada. Backups mantidos.${NC}"
            echo ""
            echo "💡 Para remover backups individualmente:"
            echo "   rm <nome_do_arquivo>.backup_api_migration_*"
            echo ""
            echo "💡 Para remover todos mais tarde:"
            echo "   bash scripts/clean_api_migration_backups.sh"
            break
            ;;
        [Ll]* )
            echo ""
            echo "📋 Detalhes dos backups:"
            echo ""
            for file in "${backup_files[@]}"; do
                echo -e "${BLUE}📄 $file${NC}"
                
                # Extrair timestamp do nome do arquivo
                timestamp=$(echo "$file" | sed 's/.*backup_api_migration_\([0-9_]*\).*/\1/')
                if [[ $timestamp =~ ^[0-9_]+$ ]]; then
                    # Converter timestamp para formato legível
                    readable_date=$(echo $timestamp | sed 's/_/ /g' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\) \([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
                    echo "   🕐 Backup criado em: $readable_date"
                fi
                
                # Mostrar primeiras linhas do arquivo
                echo "   📝 Primeiras 3 linhas do arquivo:"
                head -n 3 "$file" | sed 's/^/      /'
                
                # Mostrar informações do arquivo
                size=$(ls -lh "$file" | awk '{print $5}')
                echo "   💾 Tamanho: $size"
                echo ""
            done
            echo "Pressione Enter para voltar ao menu..."
            read
            echo -e "${YELLOW}❓ Deseja remover todos os arquivos de backup da migração API?${NC}"
            echo "   [s/S] - Sim, remover todos os backups"
            echo "   [n/N] - Não, manter os backups"
            echo ""
            ;;
        * )
            echo -e "${RED}❌ Opção inválida. Digite 's', 'n' ou 'l'.${NC}"
            ;;
    esac
done

echo ""
echo -e "${BLUE}📝 Nota: Os backups foram criados durante a migração MQTT->API${NC}"
echo -e "${BLUE}   Se o sistema estiver funcionando corretamente, os backups${NC}"
echo -e "${BLUE}   podem ser removidos com segurança.${NC}"
echo ""
echo "==============================================="
echo "🏁 Script de limpeza finalizado"
echo "==============================================="