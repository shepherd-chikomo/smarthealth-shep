import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/shared/models/facility_public_profile.dart';
import 'package:smarthealth_shep/shared/utils/widget_capture.dart';

Future<void> shareFacilityProfileScreenshot({
  required GlobalKey boundaryKey,
  required FacilityPublicProfile profile,
}) async {
  final facility = profile.facility;
  final caption =
      '${facility.name} on MyHealth\n\nGet the app: ${AppConfig.appDownloadUrl}';

  final bytes = await captureRepaintBoundary(boundaryKey);
  if (bytes == null) {
    await Share.share(caption, subject: facility.name);
    return;
  }

  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/facility_${facility.id}.png');
  await file.writeAsBytes(bytes, flush: true);

  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'image/png', name: '${facility.slug}.png')],
    text: caption,
    subject: facility.name,
  );
}
