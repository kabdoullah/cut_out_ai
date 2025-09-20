import 'package:equatable/equatable.dart';

class AppImage extends Equatable {
  final String id;
  final String originalPath;
  final String? processedPath;
  final DateTime createdAt;
  final String name;
  final AppImageStatus status;

  const AppImage({
    required this.id,
    required this.originalPath,
    this.processedPath,
    required this.createdAt,
    required this.name,
    this.status = AppImageStatus.pending,
  });

  // Factory pour créer une nouvelle image
  factory AppImage.create({
    required String originalPath,
    required String name,
  }) {
    return AppImage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalPath: originalPath,
      createdAt: DateTime.now(),
      name: name,
      status: AppImageStatus.pending,
    );
  }

  // Méthode copyWith pour l'immutabilité (pattern important en Flutter)
  AppImage copyWith({
    String? id,
    String? originalPath,
    String? processedPath,
    DateTime? createdAt,
    String? name,
    AppImageStatus? status,
  }) {
    return AppImage(
      id: id ?? this.id,
      originalPath: originalPath ?? this.originalPath,
      processedPath: processedPath ?? this.processedPath,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }

  // Conversion en Map pour la persistance (SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalPath': originalPath,
      'processedPath': processedPath,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'status': status.name,
    };
  }

  // Factory depuis Map (pour charger depuis SharedPreferences)
  factory AppImage.fromJson(Map<String, dynamic> json) {
    return AppImage(
      id: json['id'] as String,
      originalPath: json['originalPath'] as String,
      processedPath: json['processedPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      name: json['name'] as String,
      status: AppImageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppImageStatus.pending,
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    originalPath,
    processedPath,
    createdAt,
    name,
    status,
  ];
}

// États possibles d'une image
enum AppImageStatus {
  pending, // En attente de traitement
  processing, // En cours de traitement
  completed, // Traitement terminé avec succès
  failed, // Échec du traitement
}

// Extension pour des méthodes utiles sur l'enum
extension AppImageStatusExtension on AppImageStatus {
  bool get isPending => this == AppImageStatus.pending;
  bool get isProcessing => this == AppImageStatus.processing;
  bool get isCompleted => this == AppImageStatus.completed;
  bool get isFailed => this == AppImageStatus.failed;

  String get displayName {
    switch (this) {
      case AppImageStatus.pending:
        return 'En attente';
      case AppImageStatus.processing:
        return 'En cours';
      case AppImageStatus.completed:
        return 'Terminé';
      case AppImageStatus.failed:
        return 'Échec';
    }
  }

  // Couleur associée au statut
  String get colorHex {
    switch (this) {
      case AppImageStatus.pending:
        return '#6B7280'; // Gris
      case AppImageStatus.processing:
        return '#3B82F6'; // Bleu
      case AppImageStatus.completed:
        return '#10B981'; // Vert
      case AppImageStatus.failed:
        return '#EF4444'; // Rouge
    }
  }
}

class ImageMetadata {
  final int width;
  final int height;
  final int sizeInBytes;
  final String format;

  const ImageMetadata({
    required this.width,
    required this.height,
    required this.sizeInBytes,
    required this.format,
  });

  // Taille formatée en MB/KB
  String get formattedSize {
    if (sizeInBytes > 1024 * 1024) {
      final mb = sizeInBytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } else {
      final kb = sizeInBytes / 1024;
      return '${kb.toStringAsFixed(0)} KB';
    }
  }

  // Résolution formatée
  String get resolution => '${width}x$height';
}

// Exception personnalisée pour le traitement d'image
class ImageProcessingException implements Exception {
  final String message;
  const ImageProcessingException(this.message);

  @override
  String toString() => message;
}