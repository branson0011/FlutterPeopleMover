class BiometricException implements Exception {  
  final String message;  
  final String? details;  
  
  BiometricException(this.message, {this.details});  
  
  @override  
  String toString() {  
   if (details != null) {  
    return 'BiometricException: $message\nDetails: $details';  
   }  
   return 'BiometricException: $message';  
  }  
}