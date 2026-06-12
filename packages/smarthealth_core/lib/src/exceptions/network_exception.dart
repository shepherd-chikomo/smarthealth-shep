class NetworkException implements Exception {
  const NetworkException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'NetworkException: $message${cause != null ? ' ($cause)' : ''}';
}
