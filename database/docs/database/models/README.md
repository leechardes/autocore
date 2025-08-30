# 📋 Database Models

## 📋 Visão Geral

Modelos SQLAlchemy e estruturas de dados do banco AutoCore.

## 🏗️ Arquitetura de Models

### Base Models
- `BaseModel` - Classe base com campos comuns (id, created_at, updated_at)
- `TimestampMixin` - Mixin para timestamps automáticos

### Entity Models
- **User Models**: Usuários e autenticação
- **Device Models**: ESP32s e configurações
- **UI Models**: Telas, componentes e temas
- **Telemetry Models**: Dados históricos

## 📊 Relacionamentos

Consulte o arquivo de relacionamentos completos em [RELATIONSHIPS.md](../../models/RELATIONSHIPS.md).

## 🔧 Repository Pattern

Os models seguem o padrão Repository para abstração de acesso aos dados.

## 📖 Documentação Detalhada

- [Device Models](../../models/DEVICE-MODELS.md)
- [Screen Models](../../models/SCREEN-MODELS.md)
- [User Models](../../models/USER-MODELS.md)
- [Repository Patterns](../services/REPOSITORY-PATTERNS.md)