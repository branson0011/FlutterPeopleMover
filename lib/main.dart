import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'package:firebase_core/firebase_core.dart';  
import 'src/core/navigation/navigation_service.dart';  
import 'src/core/navigation/app_router.dart';  
import 'src/features/navigation/screens/main_navigation_screen.dart';  
import 'src/features/recommendation/providers/recommendation_provider.dart';  
import 'src/core/navigation/auth_wrapper.dart';  
import 'src/features/auth/providers/auth_provider.dart';  
import 'src/features/profile/providers/profile_provider.dart';  
import 'src/features/preferences/providers/preference_provider.dart';  
import 'src/features/preferences/screens/preference_management_screen.dart';  
import 'src/features/preferences/screens/preference_onboarding_screen.dart';  
import 'src/features/preferences/models/user_preferences.dart';  
import 'src/features/preferences/services/preference_service.dart';  
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
        Provider<NavigationService>(create: (_) => NavigationService()),  
        ChangeNotifierProvider(create: (_) => AuthProvider()),  
        ChangeNotifierProvider(create: (_) => ProfileProvider()),  
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),  
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),  
      ],  
      child: MaterialApp(  
        navigatorKey: Provider.of<NavigationService>(context, listen: false).navigatorKey,  
        onGenerateRoute: AppRouter.generateRoute,  
        title: 'People Mover',  
        theme: ThemeData(  
         useMaterial3: true,  
         colorScheme: ColorScheme.fromSeed(  
          seedColor: const Color(0xFF2196F3),  
         ),  
        ),  
        home: AuthWrapper(  
         child: const MainNavigationScreen(),  
        ),  
        routes: {  
         '/': (context) => const AuthWrapper(),  
         '/profile': (context) => const ProfileScreen(),  
         '/recommendations': (context) => const RecommendationScreen(),  
         '/preferences': (context) => const PreferenceManagementScreen(),  
         '/preferences/onboarding': (context) => PreferenceOnboardingScreen(userId: ''),  
        },  
      ),  
    );  
  }  
}
