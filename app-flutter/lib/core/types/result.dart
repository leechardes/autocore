/// Result pattern para operações que podem falhar
library;

import 'package:autocore_app/core/exceptions/app_exceptions.dart';

/// Sealed class para representar resultado de operações
sealed class Result<T> {
  const Result();

  /// Execute diferentes callbacks baseado no resultado
  R fold<R>(
    R Function(AppException error) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success(data: final data) => onSuccess(data),
      Failure(error: final error) => onFailure(error),
    };
  }

  /// Retorna true se é Success
  bool get isSuccess => this is Success<T>;

  /// Retorna true se é Failure
  bool get isFailure => this is Failure<T>;

  /// Obtém dados se Success, senão null
  T? get dataOrNull => switch (this) {
    Success(data: final data) => data,
    Failure() => null,
  };

  /// Obtém erro se Failure, senão null
  AppException? get errorOrNull => switch (this) {
    Success() => null,
    Failure(error: final error) => error,
  };

  /// Transforma dados se Success
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => Success(transform(data)),
      Failure(error: final error) => Failure(error),
    };
  }

  /// Transforma erro se Failure
  Result<T> mapError(AppException Function(AppException error) transform) {
    return switch (this) {
      Success(data: final data) => Success(data),
      Failure(error: final error) => Failure(transform(error)),
    };
  }

  /// Chain operations que podem falhar
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => transform(data),
      Failure(error: final error) => Failure(error),
    };
  }
}

/// Resultado de sucesso
class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Success<T> &&
            runtimeType == other.runtimeType &&
            data == other.data;
  }

  @override
  int get hashCode => data.hashCode;
}

/// Resultado de falha
class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppException error;

  @override
  String toString() => 'Failure($error)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Failure<T> &&
            runtimeType == other.runtimeType &&
            error == other.error;
  }

  @override
  int get hashCode => error.hashCode;
}

/// Extensions para facilitar uso
extension ResultExtensions<T> on Result<T> {
  /// Get data or throw exception
  T getOrThrow() {
    return switch (this) {
      Success(data: final data) => data,
      Failure(error: final error) => throw error,
    };
  }

  /// Get data or return default
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => defaultValue,
    };
  }

  /// Get data or compute default
  T getOrCompute(T Function() compute) {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => compute(),
    };
  }
}

/// Utility functions para criar Results
abstract class ResultUtils {
  /// Executa função e captura exceptions
  static Result<T> tryCall<T>(T Function() fn) {
    try {
      return Success(fn());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ParseException('Unexpected error: $e'));
    }
  }

  /// Versão async do tryCall
  static Future<Result<T>> tryCallAsync<T>(Future<T> Function() fn) async {
    try {
      final result = await fn();
      return Success(result);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ParseException('Unexpected error: $e'));
    }
  }

  /// Combine múltiplos results
  static Result<List<T>> combineResults<T>(List<Result<T>> results) {
    final List<T> data = [];

    for (final result in results) {
      if (result.isFailure) {
        final error = result.errorOrNull;
        return Failure(error ?? const ParseException('Unknown error'));
      }
      final value = result.dataOrNull;
      if (value != null) {
        data.add(value);
      }
    }

    return Success(data);
  }
}
