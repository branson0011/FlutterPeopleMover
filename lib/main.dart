import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'package:firebase_core/firebase_core.dart';  
import 'src/core/navigation/auth_wrapper.dart';  
import 'src/features/auth/providers/auth_provider.dart';  
import 'src/features/profile/providers/profile_provider.dart';  
import 'firebase_options.dart';  
  
void main() async {  
  WidgetsFlutterBinding.ensureInitialized();  
  await Firebase.initializeApp(  
   options: DefaultFirebaseOptions.currentPlatform,  
  );  
   
  runApp(const MyApp());  
}  
  
class MyApp extends StatelessWidget {  
  const MyApp({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
   return MultiProvider(  
    providers: [  
      ChangeNotifierProvider(create: (_) => AuthProvider()),  
      ChangeNotifierProvider(create: (_) => ProfileProvider()),  
    ],  
    child: MaterialApp(  
      title: 'People Mover',  
      theme: ThemeData(  
       useMaterial3: true,  
       colorScheme: ColorScheme.fromSeed(  
        seedColor: const Color(0xFF2196F3),  
       ),  
      ),  
      home: AuthWrapper(  
       child: const HomeScreen(),  
      ),  
      routes: {  
       '/profile-setup': (context) => const ProfileSetupScreen(),  
       '/home': (context) => const HomeScreen(),  
      },  
    ),  
   );  
  }  
}