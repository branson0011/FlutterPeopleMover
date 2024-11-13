import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'src/core/config/firebase_config.dart';  
import 'src/core/di/service_locator.dart';  
  
void main() async {  
  WidgetsFlutterBinding.ensureInitialized();  
   
  // Initialize Firebase  
  await FirebaseConfig.initialize();  
   
  // Setup service locator  
  setupServiceLocator();  
   
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
