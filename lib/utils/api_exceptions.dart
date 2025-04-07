class TApiException implements Exception {
  final String message;

  TApiException({this.message = 'Terjadi kesalahan yang tidak diketahui.'});

  @override
  String toString() => message;
}
