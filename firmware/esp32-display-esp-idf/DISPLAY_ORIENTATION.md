# Guia de Orientação do Display ILI9341 - ESP32-2432S028R

## Visão Geral

Este documento detalha a configuração correta de orientação para o display ILI9341 no módulo ESP32-2432S028R, incluindo a solução para problemas comuns de rotação e inversão de cores.

## Especificações do Hardware

- **Módulo**: ESP32-2432S028R
- **Controlador**: ILI9341
- **Resolução Nativa**: 240x320 pixels (portrait)
- **Resolução em Landscape**: 320x240 pixels
- **Interface**: SPI @ 65MHz
- **Cor**: RGB565 (16-bit)

## Registro MADCTL (Memory Access Control)

O registro MADCTL (0x36) controla como os dados são escritos na memória do display. Cada bit tem uma função específica:

| Bit | Nome | Função |
|-----|------|--------|
| D7  | MY   | Row Address Order (espelhamento vertical) |
| D6  | MX   | Column Address Order (espelhamento horizontal) |
| D5  | MV   | Row/Column Exchange (troca linha/coluna - rotação 90°) |
| D4  | ML   | Vertical Refresh Order |
| D3  | BGR  | RGB/BGR Order (ordem das cores) |
| D2  | MH   | Horizontal Refresh Order |
| D1  | -    | Reservado |
| D0  | -    | Reservado |

## Configuração Descoberta

### Problema Original
- Display mostrava orientação incorreta (seta apontando para baixo/lados)
- Cores invertidas (vermelho no lugar de azul)
- Rotação não respondia às mudanças

### Solução Encontrada

Para o ESP32-2432S028R em modo landscape (320x240):

```c
MADCTL = 0x00  // Sem rotação, modo RGB
```

Esta configuração resulta em:
- ✅ Orientação correta (seta apontando para cima)
- ✅ Cores corretas (RGB ao invés de BGR)
- ✅ Display em landscape (320x240)

## Configurações por Rotação

```c
switch(rotation) {
    case 0:  // Portrait (240x320)
        madctl = 0xC0;  // MY + MX
        break;
        
    case 1:  // Landscape 90° (320x240) - PADRÃO
        madctl = 0x00;  // Configuração funcional
        break;
        
    case 2:  // Portrait invertido (240x320)
        madctl = 0x00;
        break;
        
    case 3:  // Landscape 270° (320x240)
        madctl = 0xC0;  // MY + MX
        break;
}
```

## Processo de Debug

### 1. Identificação do Problema
- Display usando rotação incorreta (case 3 ao invés de 1)
- Função `display_set_rotation` sobrescrevendo configuração inicial
- Valores MADCTL inconsistentes entre funções

### 2. Testes Realizados

| MADCTL | Binário   | Bits Ativos | Resultado |
|--------|-----------|-------------|-----------|
| 0x28   | 0010 1000 | MV + BGR    | Cores erradas (vermelho/azul invertidos) |
| 0x20   | 0010 0000 | MV          | Cores OK, seta para direita |
| 0xA0   | 1010 0000 | MY + MV     | Cores OK, seta para esquerda |
| 0x60   | 0110 0000 | MX + MV     | Cores OK, seta para direita |
| 0xE0   | 1110 0000 | MY+MX+MV    | Cores OK, seta para esquerda |
| 0x00   | 0000 0000 | Nenhum      | **Cores OK, seta para cima ✓** |

### 3. Metodologia de Teste

Para testar a orientação, foi criado um padrão de teste com:
- **Faixa Superior (Branca)**: Contém seta apontando para direita
- **Faixa Central (Verde)**: Contém seta apontando para cima
- **Faixa Inferior (Azul)**: Sem elementos

A orientação correta mostra:
- Faixa branca no topo
- Faixa verde no meio com seta apontando para cima
- Faixa azul na parte inferior

## Código de Teste de Orientação

```c
// Limpar tela
display_clear(ui.display, COLOR_BLACK);

// Desenhar três faixas coloridas
display_fill_rect(ui.display, 0, 0, 320, 80, COLOR_WHITE);    // Topo
display_fill_rect(ui.display, 0, 80, 320, 80, COLOR_GREEN);   // Meio
display_fill_rect(ui.display, 0, 160, 320, 80, COLOR_BLUE);   // Base

// Desenhar seta para cima na faixa verde (orientação de referência)
// Haste vertical
for(int i = -5; i <= 5; i++) {
    display_draw_line(ui.display, 160 + i, 140, 160 + i, 100, COLOR_BLACK);
}

// Ponta da seta (formato V invertido)
for(int i = 0; i < 20; i++) {
    display_draw_pixel(ui.display, 160 - i, 100 + i, COLOR_BLACK);
    display_draw_pixel(ui.display, 160 + i, 100 + i, COLOR_BLACK);
}
```

## Troubleshooting

### Display em Branco
- Verificar backlight (GPIO 21)
- Verificar sequência de reset
- Reduzir SPI clock para 10MHz para teste

### Cores Invertidas
- Trocar entre RGB (0x00) e BGR (0x08) no bit D3 do MADCTL
- ESP32-2432S028R usa RGB (não BGR)

### Orientação Incorreta
- Verificar valor do CONFIG_ESP32_DISPLAY_ROTATION no sdkconfig
- Confirmar que `display_set_rotation` não está sobrescrevendo MADCTL
- Adicionar logs para debug:
```c
ESP_LOGI(TAG, "MADCTL enviado: 0x%02X", madctl);
```

### Display Espelhado
- Ajustar bits MY (0x80) e MX (0x40)
- Testar combinações diferentes

## Notas Importantes

1. **Configuração Única**: O ESP32-2432S028R tem peculiaridades que diferem de outras placas com ILI9341
2. **RGB vs BGR**: Este módulo específico usa RGB, não BGR como muitos exemplos online
3. **Rotação Hardware**: Alguns módulos têm o display fisicamente montado em orientações diferentes
4. **Sincronização**: Sempre sincronizar valores MADCTL entre `display_driver_init` e `display_set_rotation`

## Referências

- [ILI9341 Datasheet](https://www.displayfuture.com/Display/datasheet/controller/ILI9341.pdf)
- [ESP32-2432S028R Documentation](https://www.waveshare.com/wiki/ESP32-2432S028)
- Código fonte: `components/display_driver/src/ili9341.c`

## Histórico de Mudanças

- **2025-01-18**: Configuração inicial corrigida - MADCTL = 0x00 para landscape
- **2025-01-18**: Documentação criada após debug extensivo de orientação

---

*Documento gerado após sessão de debug para resolver problemas de orientação e cores no display.*