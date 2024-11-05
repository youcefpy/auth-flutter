import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../screens/qr_code_screen.dart';
import '../screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
      if(Firebase.apps.isEmpty){
      FirebaseOptions firebaseOptions = FirebaseOptions(
      apiKey: "myApiKey",
      appId: "1:296731516235:android:3fb70f7637635dfe44dcce",
      messagingSenderId: "296731516235",
      projectId: "aseel-auth",
    );

    await Firebase.initializeApp(name: "aseel-auth",options: firebaseOptions);
      }
      
    
   
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges() as Stream<Object?>,
        builder: (ctx, userSnapShot) {
          if (userSnapShot.hasData) {
            return QrCodeScreen();
          }
          return AuthScreen();
        },
      ),
    );
  }
}
