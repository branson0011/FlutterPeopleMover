enum LoadingStatus {
  initial,
  loading,
  success,
  error
}

class LoadingState<T> {
  final LoadingStatus status;
  final T? data;
  final String? error;

  const LoadingState._({
    this.status = LoadingStatus.initial,
    this.data,
    this.error,
  });

  factory LoadingState.initial() => const LoadingState._();

  factory LoadingState.loading() => const LoadingState._(
    status: LoadingStatus.loading,
  );

  factory LoadingState.success(T data) => LoadingState._(
    status: LoadingStatus.success,
    data: data,
  );

  factory LoadingState.error(String error) => LoadingState._(
    status: LoadingStatus.error,
    error: error,
  );

  bool get isLoading => status == LoadingStatus.loading;
  bool get isSuccess => status == LoadingStatus.success;
  bool get isError => status == LoadingStatus.error;
}