import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/profile/screens/profile_setup_screen.dart';
import '../../features/profile/services/profile_service.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        if (user == null) {
          return const AuthScreen();
        }

        return FutureBuilder<bool>(
          future: ProfileService().isProfileComplete(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final isProfileComplete = profileSnapshot.data ?? false;
            if (!isProfileComplete) {
              return ProfileSetupScreen(
                initialProfile: UserProfile(
                  uid: user.uid,
                  email: user.email!,
                  displayName: user.displayName,
                  photoURL: user.photoURL,
                ),
              );
            }

            return child;
          },
        );
      },
    );
  }
}