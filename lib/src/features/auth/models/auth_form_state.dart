class AuthFormState {
  String email;
  String password;
  String name;
  bool isLogin;
  Map<String, String?> errors;

  AuthFormState({
    this.email = '',
    this.password = '',
    this.name = '',
    this.isLogin = true,
    Map<String, String?>? errors,
  }) : errors = errors ?? {};

  bool get isValid {
    return errors.isEmpty && 
           email.isNotEmpty && 
           password.isNotEmpty && 
           (!isLogin ? name.isNotEmpty : true);
  }

  AuthFormState copyWith({
    String? email,
    String? password,
    String? name,
    bool? isLogin,
    Map<String, String?>? errors,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      isLogin: isLogin ?? this.isLogin,
      errors: errors ?? Map.from(this.errors),
    );
  }

  void updateField(String field, String value, String? Function(String?) validator) {
    switch (field) {
      case 'email':
        email = value;
        break;
      case 'password':
        password = value;
        break;
      case 'name':
        name = value;
        break;
    }
    
    final error = validator(value);
    if (error != null) {
      errors[field] = error;
    } else {
      errors.remove(field);
    }
  }

  void reset() {
    email = '';
    password = '';
    name = '';
    errors.clear();
  }
}