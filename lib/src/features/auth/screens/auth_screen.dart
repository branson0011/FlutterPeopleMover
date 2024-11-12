import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/error_service.dart';
import '../services/social_auth_service.dart';
import '../services/biometric/biometric_service.dart';
import '../providers/auth_provider.dart';
import '../models/auth_form_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_auth_button.dart';

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

  Future<void> _checkBiometrics() async {
    final isAvailable = await _biometricService.isBiometricsAvailable();
    if (mounted) {
      setState(() {
        _biometricsAvailable = isAvailable;
      });
    }
  }

  void _initializeControllers() {
    _emailController.text = _formState.email;
    _passwordController.text = _formState.password;
    _nameController.text = _formState.name;
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _setupListeners() {
    _emailController.addListener(() {
      _formState.updateField(
        'email',
        _emailController.text,
        _validateEmail,
      );
      setState(() {});
    });

    _passwordController.addListener(() {
      _formState.updateField(
        'password',
        _passwordController.text,
        _validatePassword,
      );
      setState(() {});
    });

    _nameController.addListener(() {
      _formState.updateField(
        'name',
        _nameController.text,
        _validateName,
      );
      setState(() {});
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(value)) {
      return 'Password must contain letters, numbers, and special characters';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  Future<void> _handleBiometricAuth() async {
    setState(() => _isLoading = true);
    try {
      final isAuthenticated = await _biometricService.authenticate();
      if (!isAuthenticated) {
        throw Exception('Biometric authentication failed');
      }

      final credentials = await _biometricService.getBiometricCredentials(
        FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      if (credentials != null && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        switch (credentials['provider']) {
          case 'google':
            await authProvider.signInWithGoogle(
              cachedCredentials: credentials['credentials'],
            );
            break;
          case 'apple':
            await authProvider.signInWithApple(
              cachedCredentials: credentials['credentials'],
            );
            break;
        }

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (_formState.isLogin) {
        final result = await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (result.isSuccess && mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (result.isError && mounted) {
          setState(() => _errorMessage = result.error);
        }
      } else {
        final result = await authProvider.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );

        if (result.isSuccess && mounted) {
          Navigator.of(context).pushReplacementNamed('/profile-setup');
        } else if (result.isError && mounted) {
          setState(() => _errorMessage = result.error);
        }
      }
    } catch (e) {
      setState(() => _errorMessage = ErrorService.handleException(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSocialAuth(String provider) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      UserCredential? userCredential;

      switch (provider) {
        case 'google':
          userCredential = await authProvider.signInWithGoogle();
          break;
        case 'apple':
          userCredential = await authProvider.signInWithApple();
          break;
      }

      if (userCredential != null && mounted) {
        if (_biometricsAvailable) {
          await _biometricService.storeBiometricCredentials(
            userId: userCredential.user!.uid,
            provider: provider,
            credentials: {
              'accessToken': userCredential.credential?.accessToken,
              'idToken': userCredential.credential?.idToken,
            },
          );
        }

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

  void _toggleAuthMode() {
    final newState = _formState.copyWith(
      isLogin: !_formState.isLogin,
    );

    setState(() {
      _formState = newState;
      _errorMessage = null;
      if (!_formState.isLogin) {
        _nameController.text = _formState.name;
      }
    });

    _animationController.reset();
    _animationController.forward();
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 48),
                          Text(
                            _formState.isLogin ? 'Welcome Back' : 'Create Account',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          if (_errorMessage != null) _buildErrorBanner(_errorMessage!),
                          if (!_formState.isLogin) ...[
                            AuthTextField(
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              prefixIcon: Icons.person_outline,
                              controller: _nameController,
                              validator: _validateName,
                              onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          AuthTextField(
                            label: 'Email',
                            hint: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            controller: _passwordController,
                            isPassword: true,
                            validator: _validatePassword,
                            onEditingComplete: _handleSubmit,
                          ),
                          const SizedBox(height: 24),
                          AuthButton(
                            text: _formState.isLogin ? 'Login' : 'Sign Up',
                            onPressed: _formState.isValid ? _handleSubmit : null,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 16),
                          _buildToggleButton(),
                          const SizedBox(height: 24),
                          _buildSocialAuth(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _formState.isLogin ? 'Signing in...' : 'Creating account...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formState.isLogin ? 'Don\'t have an account?' : 'Already have an account?'
        ),
        TextButton(
          onPressed: _toggleAuthMode,
          child: Text(_formState.isLogin ? 'Sign Up' : 'Login'),
        ),
      ],
    );
  }

  Widget _buildSocialAuth() {
    return Column(
      children: [
        if (_biometricsAvailable) ...[
          ElevatedButton.icon(
            onPressed: _handleBiometricAuth,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Sign in with Biometrics'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        const Text(
                    'or continue with',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SocialAuthButton(
                text: 'Google',
                iconPath: 'assets/icons/google.png',
                onPressed: () => _handleSocialAuth('google'),
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SocialAuthButton(
                text: 'Apple',
                iconPath: 'assets/icons/apple.png',
                onPressed: () => _handleSocialAuth('apple'),
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
        if (_biometricsAvailable) ...[
          const SizedBox(height: 24),
          Text(
            'Biometric sign-in will be enabled after your first login',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Future<void> _handleBiometricAuth() async {
    setState(() => _isLoading = true);
    try {
      final isAuthenticated = await _biometricService.authenticate();
      if (!isAuthenticated) {
        throw Exception('Biometric authentication failed');
      }

      final credentials = await _biometricService.getBiometricCredentials(
        FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      if (credentials != null && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        switch (credentials['provider']) {
          case 'google':
            await authProvider.signInWithGoogle(
              cachedCredentials: credentials['credentials'],
            );
            break;
          case 'apple':
            await authProvider.signInWithApple(
              cachedCredentials: credentials['credentials'],
            );
            break;
        }

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _storeBiometricCredentials(UserCredential credential, String provider) async {
    if (_biometricsAvailable) {
      await _biometricService.storeBiometricCredentials(
        userId: credential.user!.uid,
        provider: provider,
        credentials: {
          'accessToken': credential.credential?.accessToken,
          'idToken': credential.credential?.idToken,
        },
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
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
    _animationController.dispose();
    super.dispose();
  }
}
   