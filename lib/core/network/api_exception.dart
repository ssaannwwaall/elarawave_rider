/// Thin wrapper so callers can show a friendly message without caring
/// whether the failure came from the network layer or the API's own
/// `success: false` response.
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}
