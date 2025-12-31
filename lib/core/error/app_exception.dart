class AppException implements Exception {
  final String message;
  final String userFriendlyMessage;
  final int? statusCode;

  AppException({
    required this.message,
    this.userFriendlyMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.',
    this.statusCode,
  });

  @override
  String toString() => 'AppException: $message (Status: $statusCode)';
}
