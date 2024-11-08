import 'package:firebase_core/firebase_core.dart'
    show FirebaseOptions, DefaultFirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: "AIzaSyAo-5wG-GlRxHJQ3zx35mL2gKX1LH44SLA",
        authDomain: "hikki-806c1.firebaseapp.com",
        projectId: "hikki-806c1",
        storageBucket: "hikki-806c1.firebasestorage.app",
        messagingSenderId: "1020699370879",
        appId: "1:1020699370879:web:25762b3202f5fe77ebe64a",
        measurementId: "G-G1YVTXWHD8",
        databaseURL: 'https://hikki-806c1-default-rtdb.firebaseio.com',
      );
}

