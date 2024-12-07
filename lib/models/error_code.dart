enum ErrorCode {
  invalidFile('INVALID_FILE'),
  processingError('PROCESSING_ERROR'),
  labelProcessingFailed('LABEL_PROCESSING_FAILED'),
  databaseError('DATABASE_ERROR'),
  unknownError('UNKNOWN_ERROR');

  final String value;
  const ErrorCode(this.value);

  factory ErrorCode.fromString(String value) {
    return ErrorCode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ErrorCode.unknownError,
    );
  }
}
