import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/core/location/location_exceptions.dart';
import 'package:smarthealth_shep/core/location/location_permission_handler.dart';
import 'package:smarthealth_shep/core/location/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(service.dispose);
  return service;
});

final locationPermissionHandlerProvider =
    Provider<LocationPermissionHandler>((ref) {
  return const LocationPermissionHandler();
});

/// Presents a settings redirect dialog when location is permanently denied.
Future<void> showLocationPermissionDialog(
  BuildContext context,
  LocationPermissionDeniedException error,
) async {
  if (!context.mounted || !error.shouldOpenSettings) return;

  final handler = LocationPermissionHandler();
  await handler.handlePermissionDenied(
    error: error,
    showDialog: ({
      required title,
      required message,
      required confirmLabel,
      cancelLabel,
    }) {
      return showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (cancelLabel != null)
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(cancelLabel),
              ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
    },
  );
}
