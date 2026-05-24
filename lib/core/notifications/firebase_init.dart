import 'package:firebase_core/firebase_core.dart';
import 'package:smarthealth_shep/core/config/firebase_config.dart';

Future<void> initializeFirebase() async {
  if (!FirebaseConfig.isConfigured) return;

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FirebaseConfig.apiKey,
      appId: FirebaseConfig.appId,
      messagingSenderId: FirebaseConfig.messagingSenderId,
      projectId: FirebaseConfig.projectId,
    ),
  );
}
