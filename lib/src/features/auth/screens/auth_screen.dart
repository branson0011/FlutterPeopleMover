import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'package:firebase_auth/firebase_auth.dart';  
import '../services/error_service.dart';  
import '../services/social_auth_service.dart';  
import '../services/biometric/biometric_service.dart';  
import '../providers/auth_provider.dart';  
import '../models/auth_form_state.dart';  
  
// Extracted Widgets  
class AuthTextField extends StatelessWidget {  
  final String label;  
  final String hint;  
  final IconData prefixIcon;  
  final TextEditingController controller;  
  final bool isPassword;  
  final TextInputType? keyboardType;  
  final String? Function(String?)? validator;  
  final VoidCallback? onEditingComplete;  
  final FocusNode? focusNode;  

  const AuthTextField({  
   Key? key,  
   required this.label,  
   required this.hint,  
   required this.prefixIcon,  
   required this.controller,  
   this.isPassword = false,  
   this.keyboardType,  
   this.validator,  
   this.onEditingComplete,  
   this.focusNode,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return TextFormField(  
    controller: controller,  
    decoration: InputDecoration(  
      labelText: label,  
      hintText: hint,  
      prefixIcon: Icon(prefixIcon),  
    ),  
    obscureText: isPassword,  
    keyboardType: keyboardType,  
    validator: validator,  
    onEditingComplete: onEditingComplete,  
    focusNode: focusNode,  
   );  
  }  
}  
  
class AuthScreen extends StatefulWidget {  
  const AuthScreen({super.key});  
  
  @override  
  State<AuthScreen> createState() => _AuthScreenState();  
}  
  
class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {  
  final _formKey = GlobalKey<FormState>();  
  final _emailController = TextEditingController();  
  final _passwordController = TextEditingController();  
  final _nameController = TextEditingController();  
  final _emailFocus = FocusNode();  
  final _passwordFocus = FocusNode();  
   
  late AnimationController _animationController;  
  late Animation<double> _fadeAnimation;  
  late Animation<Offset> _slideAnimation;  
   
  late final BiometricService _biometricService = BiometricService();  
  bool _biometricsAvailable = false;  
  late AuthFormState _formState;  
  bool _isLoading = false;  
  String? _errorMessage;  
  
  @override  
  void initState() {  
   super.initState();  
   _formState = AuthFormState();  
   _checkBiometrics();  
   _initializeControllers();  
   _initializeAnimations();  
   _setupListeners();  
  }  
  
  // Extracted Methods  
  Future<void> _handleAuthentication({bool isSocialAuth = false, String? provider}) async {  
   setState(() {  
    _isLoading = true;  
    _errorMessage = null;  
   });  
  
   try {  
    final authProvider = Provider.of<AuthProvider>(context, listen: false);  
    UserCredential? userCredential;  
  
    if (isSocialAuth && provider != null) {  
      userCredential = await _handleSocialAuthentication(authProvider, provider);  
    } else {  
      userCredential = await _handleFormAuthentication(authProvider);  
    }  
  
    if (userCredential != null && mounted) {  
      await _handleSuccessfulAuthentication(userCredential, provider);  
    }  
   } catch (e) {  
    if (mounted) {  
      setState(() => _errorMessage = ErrorService.handleException(e));  
    }  
   } finally {  
    if (mounted) {  
      setState(() => _isLoading = false);  
    }  
   }  
  }  
  
  Future<UserCredential?> _handleSocialAuthentication(AuthProvider authProvider, String provider) async {  
    try {  
      switch (provider) {  
        case 'google':  
          final result = await authProvider.signInWithGoogle();  
          if (result == null) throw Exception('Google sign in failed');  
          return result;  
        case 'apple':  
          final result = await authProvider.signInWithApple();  
          if (result == null) throw Exception('Apple sign in failed');  
          return result;  
        default:  
          return null;  
      }  
    } catch (e) {  
      setState(() => _errorMessage = 'Social authentication failed: ${e.toString()}');  
      return null;  
    }  
  }  
  
  Future<UserCredential?> _handleFormAuthentication(AuthProvider authProvider) async {  
   if (_formState.isLogin) {  
    final result = await authProvider.signIn(  
      _emailController.text.trim(),  
      _passwordController.text,  
    );  
    if (result.isSuccess) {  
      return result.userCredential;  
    } else {  
      throw Exception(result.error);  
    }  
   } else {  
    final result = await authProvider.signUp(  
      email: _emailController.text.trim(),  
      password: _passwordController.text,  
      name: _nameController.text.trim(),  
    );  
    if (result.isSuccess) {  
      return result.userCredential;  
    } else {  
      throw Exception(result.error);  
    }  
   }  
  }  
  
  Future<void> _handleSuccessfulAuthentication(UserCredential userCredential, String? provider) async {  
   if (_biometricsAvailable && provider != null) {  
    await _storeBiometricCredentials(userCredential, provider);  
   }  
  
   if (mounted) {  
    final profileService = Provider.of<ProfileService>(context, listen: false);  
    final isProfileComplete = await profileService.isProfileComplete(  
      userCredential.user!.uid,  
    );  
  
    if (!isProfileComplete && mounted) {  
      await profileService.createInitialProfile(userCredential);  
      Navigator.of(context).pushReplacementNamed('/profile-setup');  
    } else if (mounted) {  
      Navigator.of(context).pushReplacementNamed('/home');  
    }  
   }  
  }  
  
  Future<void> _checkBiometrics() async {  
   final isAvailable = await _biometricService.isBiometricAvailable();  
   setState(() => _biometricsAvailable = isAvailable);  
  }  
  
  void _initializeControllers() {  
   _animationController = AnimationController(  
    vsync: this,  
    duration: const Duration(milliseconds: 1500),  
   );  
   _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(  
    CurvedAnimation(  
      parent: _animationController,  
      curve: Curves.easeInOut,  
    ),  
   );  
   _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(  
    CurvedAnimation(  
      parent: _animationController,  
      curve: Curves.easeInOut,  
    ),  
   );  
  }  
  
  void _initializeAnimations() {  
   _animationController.forward();  
  }  
  
  void _setupListeners() {  
   _emailController.addListener(() {  
    setState(() => _errorMessage = null);  
   });  
   _passwordController.addListener(() {  
    setState(() => _errorMessage = null);  
   });  
   _nameController.addListener(() {  
    setState(() => _errorMessage = null);  
   });  
  }  
  
  String? _validateEmail(String? email) {  
   if (email == null || email.isEmpty) {  
    return 'Please enter an email address';  
   } else if (!email.contains('@')) {  
    return 'Invalid email address';  
   }  
   return null;  
  }  
  
  String? _validatePassword(String? password) {  
   if (password == null || password.isEmpty) {  
    return 'Please enter a password';  
   } else if (password.length < 8) {  
    return 'Password must be at least 8 characters long';  
   }  
   return null;  
  }  
  
  String? _validateName(String? name) {  
   if (name == null || name.isEmpty) {  
    return 'Please enter your name';  
   }  
   return null;  
  }  
  
  void _toggleAuthMode() {  
   setState(() {  
    _formState.toggleMode();  
    _errorMessage = null;  
   });  
  }  
  
  Future<void> _handleBiometricAuth() async {  
    try {  
      final result = await _biometricService.authenticate();  
      if (result) {  
        final authProvider = Provider.of<AuthProvider>(context, listen: false);  
        final userCredential = await authProvider.signInWithBiometric();  
        if (userCredential != null && mounted) {  
          await _handleSuccessfulAuthentication(userCredential, null);  
        }  
      } else {  
        setState(() => _errorMessage = 'Biometric authentication failed');  
      }  
    } catch (e) {  
      setState(() => _errorMessage = 'Biometric error: ${e.toString()}');  
    }  
  }  
  
  @override  
  Widget build(BuildContext context) {  
   return Scaffold(  
    body: Stack(  
      children: [  
       SafeArea(  
        child: SingleChildScrollView(  
          child: Padding(  
           padding: const EdgeInsets.all(24.0),  
           child: FadeTransition(  
            opacity: _fadeAnimation,  
            child: SlideTransition(  
              position: _slideAnimation,  
              child: AuthForm(  
               formKey: _formKey,  
               formState: _formState,  
               errorMessage: _errorMessage,  
               controllers: {  
                'email': _emailController,  
                'password': _passwordController,  
                'name': _nameController,  
               },  
               onSubmit: () => _handleAuthentication(),  
               onToggleMode: _toggleAuthMode,  
               onSocialAuth: (provider) => _handleAuthentication(  
                isSocialAuth: true,  
                provider: provider,  
               ),  
               biometricsAvailable: _biometricsAvailable,  
               onBiometricAuth: _handleBiometricAuth,  
              ),  
            ),  
           ),  
          ),  
        ),  
       ),  
       if (_isLoading) LoadingOverlay(  
        message: _formState.isLogin ? 'Signing in...' : 'Creating account...',  
       ),  
      ],  
    ),  
   );  
  }  
  
  @override  
  void dispose() {  
   _emailController.dispose();  
   _passwordController.dispose();  
   _nameController.dispose();  
   _emailFocus.dispose();  
   _passwordFocus.dispose();  
   _animationController.dispose();  
   super.dispose();  
  }  
}  
  
// New Widget Components  
class AuthForm extends StatelessWidget {  
  final GlobalKey<FormState> formKey;  
  final AuthFormState formState;  
  final String? errorMessage;  
  final Map<String, TextEditingController> controllers;  
  final VoidCallback onSubmit;  
  final VoidCallback onToggleMode;  
  final Function(String) onSocialAuth;  
  final bool biometricsAvailable;  
  final VoidCallback onBiometricAuth;  
  
  const AuthForm({  
   Key? key,  
   required this.formKey,  
   required this.formState,  
   required this.errorMessage,  
   required this.controllers,  
   required this.onSubmit,  
   required this.onToggleMode,  
   required this.onSocialAuth,  
   required this.biometricsAvailable,  
   required this.onBiometricAuth,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return Form(  
    key: formKey,  
    child: Column(  
      crossAxisAlignment: CrossAxisAlignment.stretch,  
      children: [  
       AuthHeader(  
        isLogin: formState.isLogin,  
        errorMessage: errorMessage,  
       ),  
       if (!formState.isLogin)  
        NameField(controller: controllers['name']!),  
       EmailField(  
         controller: controllers['email']!,  
         validator: _validateEmail,  
         keyboardType: TextInputType.emailAddress,  
         focusNode: _emailFocus,  
         onEditingComplete: () => FocusScope.of(context).nextFocus(),  
       ),  
       PasswordField(  
         controller: controllers['password']!,  
         validator: _validatePassword,  
         focusNode: _passwordFocus,  
       ),  
       SubmitButton(  
        isLogin: formState.isLogin,  
        onPressed: onSubmit,  
       ),  
       AuthToggleButton(  
        isLogin: formState.isLogin,  
        onPressed: onToggleMode,  
       ),  
       SocialAuthSection(  
        onSocialAuth: onSocialAuth,  
        biometricsAvailable: biometricsAvailable,  
        onBiometricAuth: onBiometricAuth,  
       ),  
      ],  
    ),  
   );  
  }  
}  
  
class AuthHeader extends StatelessWidget {  
  final bool isLogin;  
  final String? errorMessage;  
  
  const AuthHeader({  
   Key? key,  
   required this.isLogin,  
   required this.errorMessage,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return Column(  
    children: [  
      Text(  
       isLogin ? 'Sign In' : 'Create Account',  
       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),  
      ),  
      if (errorMessage != null)  
       Text(  
        errorMessage!,  
        style: TextStyle(color: Colors.red),  
       ),  
    ],  
   );  
  }  
}  
  
class NameField extends StatelessWidget {  
  final TextEditingController controller;  
  
  const NameField({  
   Key? key,  
   required this.controller,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return AuthTextField(  
    label: 'Name',  
    hint: 'Enter your name',  
    prefixIcon: Icons.person,  
    controller: controller,  
    validator: (value) {  
      if (value == null || value.isEmpty) {  
       return 'Please enter your name';  
      }  
      return null;  
    },  
   );  
  }  
}  
  
class EmailField extends StatelessWidget {  
  final TextEditingController controller;  
  
  const EmailField({  
   Key? key,  
   required this.controller,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return AuthTextField(  
    label: 'Email',  
    hint: 'Enter your email address',  
    prefixIcon: Icons.email,  
    controller: controller,  
    validator: (value) {  
      if (value == null || value.isEmpty) {  
       return 'Please enter an email address';  
      } else if (!value.contains('@')) {  
       return 'Invalid email address';  
      }  
      return null;  
    },  
   );  
  }  
}  
  
class PasswordField extends StatelessWidget {  
  final TextEditingController controller;  
  
  const PasswordField({  
   Key? key,  
   required this.controller,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return AuthTextField(  
    label: 'Password',  
    hint: 'Enter your password',  
    prefixIcon: Icons.lock,  
    controller: controller,  
    isPassword: true,  
    validator: (value) {  
      if (value == null || value.isEmpty) {  
       return 'Please enter a password';  
      } else if (value.length < 8) {  
       return 'Password must be at least 8 characters long';  
      }  
      return null;  
    },  
   );  
  }  
}  
  
class SubmitButton extends StatelessWidget {  
  final bool isLogin;  
  final VoidCallback onPressed;  
  
  const SubmitButton({  
   Key? key,  
   required this.isLogin,  
   required this.onPressed,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return ElevatedButton(  
    onPressed: onPressed,  
    child: Text(isLogin ? 'Sign In' : 'Create Account'),  
   );  
  }  
}  
  
class AuthToggleButton extends StatelessWidget {  
  final bool isLogin;  
  final VoidCallback onPressed;  
  
  const AuthToggleButton({  
   Key? key,  
   required this.isLogin,  
   required this.onPressed,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return TextButton(  
    onPressed: onPressed,  
    child: Text(isLogin ? 'Create Account' : 'Sign In'),  
   );  
  }  
}  
  
class SocialAuthSection extends StatelessWidget {  
  final Function(String) onSocialAuth;  
  final bool biometricsAvailable;  
  final VoidCallback onBiometricAuth;  
  
  const SocialAuthSection({  
   Key? key,  
   required this.onSocialAuth,  
   required this.biometricsAvailable,  
   required this.onBiometricAuth,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return Column(  
    children: [  
      Text('Or sign in with:'),  
      Row(  
       mainAxisAlignment: MainAxisAlignment.spaceEvenly,  
       children: [  
        SocialAuthButton(  
          icon: Icons.g_mobiledata,  
          onPressed: () => onSocialAuth('google'),  
        ),  
        SocialAuthButton(  
          icon: Icons.apple,  
          onPressed: () => onSocialAuth('apple'),  
        ),  
        if (biometricsAvailable)  
          SocialAuthButton(  
           icon: Icons.fingerprint,  
           onPressed: onBiometricAuth,  
          ),  
       ],  
      ),  
    ],  
   );  
  }  
}  
  
class SocialAuthButton extends StatelessWidget {  
  final IconData icon;  
  final VoidCallback onPressed;  
  
  const SocialAuthButton({  
   Key? key,  
   required this.icon,  
   required this.onPressed,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return IconButton(  
    icon: Icon(icon),  
    onPressed: onPressed,  
   );  
  }  
}  
  
class LoadingOverlay extends StatelessWidget {  
  final String message;  
  
  const LoadingOverlay({  
   Key? key,  
   required this.message,  
  }) : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
   return Container(  
    width: double.infinity,  
    height: double.infinity,  
    color: Colors.white.withOpacity(0.5),  
    child: Center(  
      child: Column(  
       mainAxisAlignment: MainAxisAlignment.center,  
       children: [  
        CircularProgressIndicator(),  
        Text(message),  
       ],  
      ),  
    ),  
   );  
  }  
}
