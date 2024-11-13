import 'package:flutter/foundation.dart';

abstract class BaseState<T> extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  T? _data;

  bool get isLoading => _isLoading;
  String? get error => _error;
  T? get data => _data;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setData(T? data) {
    _data = data;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _data = null;
    notifyListeners();
  }
}
