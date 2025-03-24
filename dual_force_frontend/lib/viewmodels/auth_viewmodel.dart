import 'dart:developer';

import 'package:dual_force/data/response/api_response.dart';
import 'package:dual_force/models/expert_system.dart';
import 'package:dual_force/utils/toast_message.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repository/auth_repository.dart';

class AuthViewmodel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _error;
  String? get error => _error;

  void setisLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Login with email and password
  Future<bool> login() async {
    try {
      setisLoading(true);

      // Validate input
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ToastUtils.showErrorToast('Please fill in all fields');
        return false;
      }

      if (!emailController.text.contains('@')) {
        ToastUtils.showErrorToast('Please enter a valid email');
        return false;
      }

      final response = await _authRepository.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.status == Status.ERROR) {
        ToastUtils.showErrorToast(response.message);
        return false;
      }
      log(response.data.toString());
      final User user = User.fromMap(response.data);

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      if (e.toString().contains('Invalid email or password')) {
        ToastUtils.showErrorToast('Invalid email or password');
      } else {
        ToastUtils.showErrorToast('An error occurred. Please try again.');
      }
      return false;
    } finally {
      setisLoading(false);
    }
  }

  // Sign up with email and password
  Future<bool> signup() async {
    try {
      setisLoading(true);

      // Validate input
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ToastUtils.showErrorToast('Please fill in all fields');
        return false;
      }

      if (!emailController.text.contains('@')) {
        ToastUtils.showErrorToast('Please enter a valid email');
        return false;
      }

      if (passwordController.text.length < 6) {
        ToastUtils.showErrorToast('Password must be at least 6 characters');
        return false;
      }

      final response = await _authRepository.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.status == Status.ERROR) {
        ToastUtils.showErrorToast(response.message);
        return false;
      }
      final User user = User.fromMap(response.data);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      log(e.toString());

      ToastUtils.showErrorToast('An error occurred. Please try again.');
      return false;
    } finally {
      setisLoading(false);
    }
  }

  // Add a new expert system to the user
  void addExpertSystem(ExpertSystem expertSystem) {
  if (_currentUser != null) {
    // Add directly to the existing list
    _currentUser!.expertSystems.add(expertSystem);
    
    // Force notification
    notifyListeners();
  }
}

  

  // Logout
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}