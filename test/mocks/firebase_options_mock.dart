import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptionsMock {
  static const FirebaseOptions testOptions = FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    messagingSenderId: 'test-messaging-sender-id',
    projectId: 'test-project-id',
  );
  
  static FirebaseOptions get currentPlatform => testOptions;
}