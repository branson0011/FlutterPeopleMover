class CacheConfig {
  final int maxSize;
  final Duration maxAge;
  final bool persistToDisk;
  final String? cacheKey;
  final bool enableCompression;
  final int compressionLevel;
  final bool enableEncryption;
  final String? encryptionKey;
  final Duration? refreshInterval;
  final int? maxRetries;
  final Duration? retryDelay;

  const CacheConfig({
    this.maxSize = 100,
    this.maxAge = const Duration(minutes: 30),
    this.persistToDisk = false,
    this.cacheKey,
    this.enableCompression = false,
    this.compressionLevel = 6,
    this.enableEncryption = false,
    this.encryptionKey,
    this.refreshInterval,
    this.maxRetries,
    this.retryDelay,
  });

  CacheConfig copyWith({
    int? maxSize,
    Duration? maxAge,
    bool? persistToDisk,
    String? cacheKey,
    bool? enableCompression,
    int? compressionLevel,
    bool? enableEncryption,
    String? encryptionKey,
    Duration? refreshInterval,
    int? maxRetries,
    Duration? retryDelay,
  }) {
    return CacheConfig(
      maxSize: maxSize ?? this.maxSize,
      maxAge: maxAge ?? this.maxAge,
      persistToDisk: persistToDisk ?? this.persistToDisk,
      cacheKey: cacheKey ?? this.cacheKey,
      enableCompression: enableCompression ?? this.enableCompression,
      compressionLevel: compressionLevel ?? this.compressionLevel,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
    );
  }
}
