# AutoCore - Brand Assets

## Logo e Identidade Visual

### Arquivos Disponíveis

#### Logo Completa
- **Localização**: `/docs/assets/logo-complete.png`
- **Uso**: Material de marketing, apresentações, documentação
- **Formato**: PNG com fundo transparente
- **Conteúdo**: Ícone + "AutoCore" + "Smart Vehicle Gateway"

#### Componentes React
- **Localização**: `/config-app/frontend/src/components/AutoCoreLogo.jsx`
- **Componentes disponíveis**:
  - `AutoCoreIcon` - Apenas o ícone hexagonal
  - `AutoCoreLogo` - Logo completa configurável
  - `AutoCoreLogoCompact` - Versão compacta para headers

### Cores da Marca

#### Cores Principais
- **Azul Principal**: `#4A90E2` - Hexágono central, conexões
- **Laranja Accent**: `#FF7A59` - Hexágono externo, pontos de conexão

#### Cores de Texto
- **Título**: `#1F2937` (gray-800) / `#FFFFFF` (white no dark mode)
- **Subtítulo**: `#4B5563` (gray-600) / `#9CA3AF` (gray-400 no dark mode)

### Uso dos Componentes

#### Ícone Sozinho
```jsx
import { AutoCoreIcon } from '@/components/AutoCoreLogo';

// Ícone padrão (48px)
<AutoCoreIcon />

// Ícone grande (64px)
<AutoCoreIcon size={64} />

// Com classe CSS
<AutoCoreIcon className="animate-pulse" />
```

#### Logo Completa
```jsx
import { AutoCoreLogo } from '@/components/AutoCoreLogo';

// Logo completa padrão
<AutoCoreLogo />

// Sem subtítulo
<AutoCoreLogo showSubtitle={false} />

// Apenas ícone
<AutoCoreLogo showText={false} />

// Tamanhos customizados
<AutoCoreLogo 
  iconSize={64}
  textSize="text-4xl"
  subtitleSize="text-base"
/>
```

#### Logo Compacta (Headers)
```jsx
import { AutoCoreLogoCompact } from '@/components/AutoCoreLogo';

// Uso em headers e menus
<AutoCoreLogoCompact />
```

### Significado do Design

#### Hexágono
- Representa **estrutura e estabilidade**
- Forma eficiente encontrada na natureza
- Simboliza a **modularidade** do sistema

#### Conexões Laterais
- Representam os **múltiplos dispositivos ESP32**
- Mostram a natureza **distribuída** do sistema
- Indicam **comunicação bidirecional**

#### Cores
- **Azul**: Tecnologia, confiança, inteligência
- **Laranja**: Energia, inovação, ação

### Diretrizes de Uso

#### Fazer
- ✅ Usar as cores oficiais da marca
- ✅ Manter proporções ao redimensionar
- ✅ Usar fundo claro ou escuro para contraste
- ✅ Usar componentes React quando possível

#### Não Fazer
- ❌ Distorcer as proporções
- ❌ Alterar as cores principais
- ❌ Adicionar efeitos desnecessários
- ❌ Usar em fundos que prejudiquem visibilidade

### Aplicações

#### Interface Web
- Header principal: `AutoCoreLogoCompact`
- Página de login: `AutoCoreLogo` completa
- Favicon: `AutoCoreIcon` exportado como SVG

#### Documentação
- README: Logo PNG completa
- Apresentações: Logo com fundo apropriado
- Diagramas: Ícone como elemento visual

#### Hardware
- Adesivos: Logo em alta resolução
- Cases 3D: Gravação do ícone
- PCBs: Silkscreen do ícone simplificado

### Exportação

Para exportar o ícone como SVG standalone:

```jsx
// Copie o conteúdo SVG do AutoCoreIcon
// Salve como autocore-icon.svg
```

Para gerar PNG em diferentes tamanhos:
1. Use o componente React com size desejado
2. Capture screenshot
3. Ou use ferramenta de conversão SVG para PNG

### Licença de Uso

A logo e identidade visual do AutoCore são propriedade do projeto.
Uso permitido para:
- Implementações do sistema AutoCore
- Documentação relacionada
- Material educacional com atribuição

Para uso comercial ou modificações, consulte a licença do projeto.