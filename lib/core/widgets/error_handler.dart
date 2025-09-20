import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/image_processing/providers/image_view_model.dart';

// Widget pour gérer l'affichage des erreurs de manière centralisée
class ErrorHandler extends ConsumerWidget {
  final Widget child;

  const ErrorHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(errorProvider);

    // Écouter les changements d'erreur
    ref.listen<String?>(errorProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        _showErrorSnackBar(context, ref, next);
      }
    });

    return child;
  }

  void _showErrorSnackBar(BuildContext context, WidgetRef ref, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () {
            ref.read(imageViewModelProvider.notifier).clearError();
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}