# 📋 Checklist - Formatação com SD Card Formatter

## Durante a Formatação

### 🟢 Sinais Positivos:
- [ ] Progresso constante sem pausas longas
- [ ] Velocidade consistente
- [ ] Sem mensagens de erro
- [ ] Tempo dentro do esperado (30-40 min para 64GB)

### 🔴 Sinais de Problema:
- [ ] Formatação muito lenta (> 1 hora)
- [ ] Travamentos ou pausas longas
- [ ] Mensagens de erro
- [ ] Formatação falha antes de completar

## Após a Formatação

### ✅ Se Formatou com Sucesso:

1. **Teste Rápido de Escrita**
   ```bash
   # No Terminal do Mac
   # Assumindo que o SD Card está em /Volumes/SDCARD
   time dd if=/dev/zero of=/Volumes/SDCARD/test.img bs=1M count=100
   ```
   - Deve escrever 100MB em < 10 segundos

2. **Verificar Capacidade Real**
   ```bash
   # Ver tamanho real vs anunciado
   diskutil info /dev/disk4 | grep "Disk Size"
   ```
   - 64GB deve mostrar ~59-62GB utilizáveis

3. **Teste com F3 (detecta cartões falsos)**
   ```bash
   # Instalar F3
   brew install f3
   
   # Testar cartão (demora ~30 min)
   f3write /Volumes/SDCARD/
   f3read /Volumes/SDCARD/
   ```

### ❌ Se Falhou na Formatação:

**Possíveis Causas:**
1. **Cartão com defeito físico** - Trocar cartão
2. **Cartão falso/counterfeit** - Capacidade real menor que anunciada
3. **Leitor de cartão com problema** - Testar outro leitor/porta USB
4. **Cartão travado em read-only** - Verificar trava física

**Diagnóstico Adicional:**
```bash
# Ver erros do sistema
log show --predicate 'process == "kernel"' --last 5m | grep -i "disk\|error"

# Verificar SMART data (se suportado)
diskutil info /dev/disk4 | grep -i "smart"
```

## 🎯 Próximos Passos Após Formatação

### Opção 1: Raspberry Pi Imager (Recomendado)
1. Baixar: https://www.raspberrypi.com/software/
2. Escolher: **Raspberry Pi OS Lite (32-bit)**
3. Configurar (⚙️):
   - ✅ Hostname: `raspberrypi`
   - ✅ Enable SSH
   - ✅ Set username/password
   - ✅ Configure WiFi
   - ✅ Set locale settings

### Opção 2: Script Manual
```bash
# Usar nosso script
cd /Users/leechardes/Projetos/AutoCore/raspberry-pi/scripts
./prepare_sdcard_mac.sh
```

### Opção 3: Balena Etcher
1. Baixar: https://etcher.balena.io/
2. Selecionar imagem `.img`
3. Flash!

## 🔬 Teste Detalhado Pós-Formatação

```bash
# Script de teste completo
cat > test_fresh_sdcard.sh << 'EOF'
#!/bin/bash
echo "=== TESTE DE SD CARD FORMATADO ==="

# 1. Informações básicas
echo -e "\n1. INFORMAÇÕES DO CARTÃO:"
diskutil info /dev/disk4 | grep -E "Device|Media Name|Disk Size|Writable"

# 2. Teste de escrita sequencial
echo -e "\n2. TESTE DE ESCRITA (100MB):"
time dd if=/dev/zero of=/Volumes/*/test100.img bs=1M count=100 2>&1 | grep -E "bytes|copied"

# 3. Teste de leitura
echo -e "\n3. TESTE DE LEITURA:"
time dd if=/Volumes/*/test100.img of=/dev/null bs=1M 2>&1 | grep -E "bytes|copied"

# 4. Teste de arquivos pequenos
echo -e "\n4. TESTE COM 1000 ARQUIVOS PEQUENOS:"
mkdir -p /Volumes/*/test_files
time for i in {1..1000}; do echo "test" > /Volumes/*/test_files/file_$i.txt; done

# 5. Limpeza
rm -rf /Volumes/*/test*

echo -e "\n=== TESTE CONCLUÍDO ==="
EOF

chmod +x test_fresh_sdcard.sh
./test_fresh_sdcard.sh
```

## 📊 Resultados Esperados

### 🟢 Cartão BOM:
- Escrita: > 10 MB/s
- Leitura: > 20 MB/s
- 1000 arquivos: < 10 segundos
- Sem erros no console

### 🟡 Cartão MEDIANO:
- Escrita: 5-10 MB/s
- Leitura: 10-20 MB/s
- 1000 arquivos: 10-30 segundos
- Funcional mas lento

### 🔴 Cartão RUIM:
- Escrita: < 5 MB/s
- Leitura: < 10 MB/s
- 1000 arquivos: > 30 segundos
- Considere substituir

## 💡 Dicas Importantes

1. **Durante a formatação:**
   - NÃO remova o cartão
   - NÃO desligue o computador
   - NÃO use o cartão em outro programa

2. **Se o Mac ejetar o cartão durante formatação:**
   - Normal em alguns casos
   - O SD Formatter continua trabalhando
   - Aguarde conclusão

3. **Após formatação bem-sucedida:**
   - O cartão aparecerá vazio
   - Capacidade pode ser ~7% menor (normal)
   - Nome do volume será o configurado

## 🚨 Quando Desistir do Cartão

❌ **Descarte o cartão se:**
- Formatação falha 3x seguidas
- Teste F3 detecta fraude
- Velocidade < 3 MB/s consistentemente
- Erros de I/O frequentes
- Cartão aquece muito durante uso

✅ **Cartões recomendados para substituição:**
1. SanDisk Extreme A2 (32GB) - R$ 80
2. Samsung EVO Select A2 (32GB) - R$ 70
3. Kingston Canvas Go Plus (32GB) - R$ 65

---

*Aguarde a formatação completar e execute os testes acima!*