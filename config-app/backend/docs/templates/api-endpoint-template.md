# Endpoint - [Nome do Endpoint]

Template para documentar novos endpoints da API Config-App.

## 📋 Informações Básicas

- **Método**: `GET|POST|PUT|PATCH|DELETE`
- **URL**: `/api/[resource]/[path]`
- **Versão Adicionada**: `v2.0.0`
- **Tags**: `[Tag1, Tag2]`
- **Autenticação**: `Necessária|Opcional|Não requerida`

## 📝 Descrição

[Descreva brevemente o que este endpoint faz, quando usar e qual problema resolve]

## 🔗 URL e Parâmetros

### URL
```
[METHOD] /api/[resource]/[path]
```

### Parâmetros de Path
| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|-----------|------|-------------|-----------|---------|
| `param1` | `string` | ✅ Sim | Descrição do parâmetro | `example-value` |
| `param2` | `integer` | ❌ Não | Descrição do parâmetro | `123` |

### Parâmetros de Query
| Parâmetro | Tipo | Obrigatório | Padrão | Descrição |
|-----------|------|-------------|--------|-----------|
| `limit` | `integer` | ❌ | `100` | Número máximo de itens |
| `offset` | `integer` | ❌ | `0` | Número de itens a pular |
| `filter` | `string` | ❌ | `null` | Filtro a aplicar |

### Headers
| Header | Obrigatório | Descrição |
|--------|-------------|-----------|
| `Authorization` | ✅ | Bearer token para autenticação |
| `Content-Type` | ✅ | `application/json` |

## 📥 Request Body

### Schema
```json
{
  "type": "object",
  "required": ["field1", "field2"],
  "properties": {
    "field1": {
      "type": "string",
      "description": "Descrição do campo",
      "example": "valor-exemplo"
    },
    "field2": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100,
      "description": "Descrição do campo numérico",
      "example": 42
    },
    "field3": {
      "type": "object",
      "properties": {
        "nested_field": {
          "type": "string",
          "example": "valor-aninhado"
        }
      }
    }
  }
}
```

### Exemplo
```json
{
  "field1": "valor-exemplo",
  "field2": 42,
  "field3": {
    "nested_field": "valor-aninhado"
  }
}
```

## 📤 Responses

### ✅ 200 - Sucesso
```json
{
  "id": 1,
  "field1": "valor-retornado",
  "field2": 42,
  "created_at": "2025-01-22T10:00:00Z",
  "updated_at": "2025-01-22T10:00:00Z"
}
```

### ✅ 201 - Criado (apenas para POST)
```json
{
  "id": 1,
  "field1": "novo-valor",
  "message": "Recurso criado com sucesso"
}
```

### ❌ 400 - Bad Request
```json
{
  "detail": "Dados inválidos fornecidos",
  "error_code": "VALIDATION_ERROR",
  "errors": [
    {
      "field": "field1",
      "message": "Campo obrigatório não informado"
    }
  ]
}
```

### ❌ 401 - Unauthorized
```json
{
  "detail": "Token de autenticação necessário",
  "error_code": "AUTHENTICATION_REQUIRED"
}
```

### ❌ 403 - Forbidden
```json
{
  "detail": "Permissão insuficiente para acessar este recurso",
  "error_code": "PERMISSION_DENIED"
}
```

### ❌ 404 - Not Found
```json
{
  "detail": "Recurso não encontrado",
  "error_code": "RESOURCE_NOT_FOUND"
}
```

### ❌ 409 - Conflict
```json
{
  "detail": "Recurso já existe com este identificador",
  "error_code": "RESOURCE_CONFLICT"
}
```

### ❌ 422 - Unprocessable Entity
```json
{
  "detail": [
    {
      "loc": ["body", "field1"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

### ❌ 500 - Internal Server Error
```json
{
  "detail": "Erro interno do servidor",
  "error_code": "INTERNAL_ERROR"
}
```

## 🔒 Autenticação e Autorização

### Autenticação
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Permissões Necessárias
- `[resource]:read` - Para operações GET
- `[resource]:write` - Para operações POST/PUT/PATCH  
- `[resource]:delete` - Para operações DELETE
- `admin` - Para operações administrativas

### Roles que Podem Acessar
- ✅ **admin** - Acesso total
- ✅ **operator** - Acesso de controle
- ❌ **viewer** - Apenas leitura (se GET)
- ❌ **device** - Não aplicável

## 📝 Exemplos de Uso

### cURL
```bash
# Exemplo básico
curl -X [METHOD] "http://localhost:8081/api/[resource]/[path]" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "field1": "valor-exemplo",
       "field2": 42
     }'

# Exemplo com parâmetros de query
curl -X GET "http://localhost:8081/api/[resource]?limit=10&offset=0" \
     -H "Authorization: Bearer YOUR_TOKEN"
```

### JavaScript (Fetch)
```javascript
// Exemplo com fetch
const response = await fetch('/api/[resource]/[path]', {
  method: '[METHOD]',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    field1: 'valor-exemplo',
    field2: 42
  })
});

const data = await response.json();
console.log(data);
```

### Python (Requests)
```python
import requests

url = "http://localhost:8081/api/[resource]/[path]"
headers = {
    "Authorization": "Bearer YOUR_TOKEN",
    "Content-Type": "application/json"
}
data = {
    "field1": "valor-exemplo", 
    "field2": 42
}

response = requests.[method](url, headers=headers, json=data)
print(response.json())
```

### Python (httpx - Async)
```python
import httpx

async with httpx.AsyncClient() as client:
    response = await client.[method](
        "http://localhost:8081/api/[resource]/[path]",
        headers={"Authorization": "Bearer YOUR_TOKEN"},
        json={"field1": "valor-exemplo", "field2": 42}
    )
    data = response.json()
    print(data)
```

## 🔄 Fluxo de Trabalho

1. **Validação de Input**: Verificar parâmetros e body
2. **Autenticação**: Validar token JWT
3. **Autorização**: Verificar permissões necessárias
4. **Lógica de Negócio**: Processar requisição
5. **Persistência**: Salvar/buscar dados se necessário
6. **Response**: Retornar resultado formatado
7. **Logging**: Registrar evento para auditoria

## ⚠️ Considerações Especiais

### Rate Limiting
- **Usuários**: [X] requests por minuto
- **Dispositivos**: [Y] requests por minuto
- **Admin**: [Z] requests por minuto

### Cache
- **TTL**: [X] segundos para responses GET
- **Invalidação**: Cache invalidado quando recurso é modificado
- **Headers**: `Cache-Control: max-age=[X]`

### Idempotência
- ✅ **GET**: Idempotente
- ❌ **POST**: Não idempotente
- ✅ **PUT**: Idempotente  
- ✅ **PATCH**: Idempotente (neste caso)
- ✅ **DELETE**: Idempotente

### Paginação (se aplicável)
```json
{
  "items": [...],
  "total": 150,
  "page": 1,
  "per_page": 25,
  "pages": 6,
  "has_next": true,
  "has_prev": false
}
```

## 🧪 Testes

### Casos de Teste
1. **Sucesso**: Requisição válida retorna resultado esperado
2. **Validação**: Dados inválidos retornam erro 400
3. **Autenticação**: Sem token retorna erro 401
4. **Autorização**: Sem permissão retorna erro 403
5. **Not Found**: Recurso inexistente retorna erro 404
6. **Conflito**: Duplicação retorna erro 409
7. **Rate Limit**: Excesso de requests retorna erro 429

### Exemplo de Teste (pytest)
```python
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_[endpoint_name]_success():
    """Testa caso de sucesso"""
    response = client.[method]("/api/[resource]/[path]", 
                              json={"field1": "test"})
    assert response.status_code == 200
    data = response.json()
    assert data["field1"] == "test"

def test_[endpoint_name]_validation_error():
    """Testa erro de validação"""
    response = client.[method]("/api/[resource]/[path]", json={})
    assert response.status_code == 422

def test_[endpoint_name]_unauthorized():
    """Testa erro de autenticação"""
    response = client.[method]("/api/[resource]/[path]")
    assert response.status_code == 401
```

## 📊 Métricas e Monitoramento

### Métricas Importantes
- **Latência**: Tempo de resposta do endpoint
- **Throughput**: Requests por segundo
- **Taxa de Erro**: Percentual de respostas 4xx/5xx
- **Disponibilidade**: Uptime do endpoint

### Alertas
- **Alta Latência**: > [X]ms
- **Taxa de Erro**: > [Y]%
- **Volume Anômalo**: > [Z] requests/min

## 📚 Referências

### Documentação Relacionada
- [Esquema do Banco de Dados](../architecture/database-schema.md)
- [Guia de Autenticação](../guides/authentication-guide.md)
- [Padrões de API](../development/coding-standards.md)

### Endpoints Relacionados
- `GET /api/[related-endpoint]` - Descrição
- `POST /api/[another-endpoint]` - Descrição

### Modelos de Dados
- `[ModelName]` - Modelo principal
- `[RelatedModel]` - Modelo relacionado

---

## ✏️ Como Usar Este Template

1. **Copie este arquivo** para `docs/api/endpoints/[nome-endpoint].md`
2. **Substitua todos os placeholders** `[...]` com valores reais
3. **Remova seções** não aplicáveis ao seu endpoint
4. **Adicione seções específicas** se necessário
5. **Teste todos os exemplos** fornecidos
6. **Valide a documentação** com a equipe

### Placeholders a Substituir
- `[Nome do Endpoint]` → Nome descritivo do endpoint
- `[METHOD]` → GET, POST, PUT, PATCH, DELETE
- `[resource]` → Nome do recurso (devices, screens, etc)
- `[path]` → Caminho específico
- `[Tag1, Tag2]` → Tags para organização
- `[X]`, `[Y]`, `[Z]` → Valores numéricos específicos

---

*Template atualizado em: 22/01/2025*