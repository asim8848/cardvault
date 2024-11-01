import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/bank_provider.dart';
import 'providers/card_provider.dart';
import 'providers/connectivity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CardProvider>(
          create: (_) => CardProvider(),
          update: (_, auth, previousCards) =>
              CardProvider()..updateUser(auth.user),
        ),
        ChangeNotifierProvider(create: (_) => BankProvider()),
      ],
      child: const AppVault(),
    ),
  );
}
