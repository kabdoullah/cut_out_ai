import 'dart:typed_data';

abstract class BackgroundRemovalService {
  Future<Uint8List> removeBackground(String imagePath);
}

class BackgroundRemovalException implements Exception {
  final String message;
  const BackgroundRemovalException(this.message);

  @override
  String toString() => message;
}
