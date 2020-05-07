class HttpException implements Exception {
  String mesaage;
  HttpException(this.mesaage);
  @override
  String toString() {
    return this.mesaage;
  }
}
