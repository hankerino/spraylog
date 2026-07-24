sealed class Result<T, E> {
  const Result();
  factory Result.success(T value) => Success(value);
  factory Result.error(E error) => Error(error);

  Result<U, E> map<U>(U Function(T) f) => switch (this) {
    Success(value: final v) => Result.success(f(v)),
    Error(error: final e) => Result.error(e),
  };

  T unwrap() => switch (this) {
    Success(value: final v) => v,
    Error(error: final e) => throw e,
  };

  T? getOrNull() => switch (this) {
    Success(value: final v) => v,
    Error() => null,
  };
}

final class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);
}

final class Error<T, E> extends Result<T, E> {
  final E error;
  const Error(this.error);
}
