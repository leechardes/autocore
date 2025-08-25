/// Base Repository interface para padronizar operações
library;

import 'package:autocore_app/core/types/result.dart';

/// Interface base para todos os repositories
abstract class BaseRepository {
  /// Limpa cache se aplicável
  Future<void> clearCache();

  /// Verifica se está online
  Future<bool> isOnline();
}

/// Repository para operações CRUD básicas
abstract class CrudRepository<T, ID> extends BaseRepository {
  /// Busca item por ID
  Future<Result<T?>> getById(ID id);

  /// Busca todos os itens
  Future<Result<List<T>>> getAll();

  /// Cria novo item
  Future<Result<T>> create(T item);

  /// Atualiza item existente
  Future<Result<T>> update(ID id, T item);

  /// Remove item
  Future<Result<bool>> delete(ID id);
}

/// Repository para operações de busca
abstract class SearchableRepository<T> extends BaseRepository {
  /// Busca itens com filtros
  Future<Result<List<T>>> search({
    String? query,
    Map<String, dynamic>? filters,
    int? limit,
    int? offset,
  });
}

/// Repository com cache
abstract class CachedRepository<T> extends BaseRepository {
  /// Força refresh do cache
  Future<Result<T>> refresh();

  /// Obtém dados do cache
  Future<Result<T?>> getCached();

  /// Salva no cache
  Future<void> saveToCache(T data);
}
