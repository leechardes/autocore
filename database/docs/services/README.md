# 🔧 Database Services

## 📋 Visão Geral

Documentação dos serviços e padrões de acesso aos dados do banco AutoCore.

## 🏗️ Arquitetura de Serviços

### Repository Pattern
Abstração para acesso aos dados seguindo o padrão Repository.

### Service Layer
Camada de negócio que utiliza os repositories.

### Data Access
- **Repositories**: Acesso direto aos dados
- **Services**: Lógica de negócio
- **DTOs**: Transfer Objects

## 📊 Padrões Implementados

- **Repository Pattern**: Para abstração de dados
- **Unit of Work**: Para transações complexas
- **Specification Pattern**: Para consultas dinâmicas

## 📖 Documentação Detalhada

- [Repository Patterns](REPOSITORY-PATTERNS.md)