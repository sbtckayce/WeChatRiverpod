import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_char/features/auth/repository/login_repository.dart';

final loginControllerProvider = Provider<LoginController>((ref) {
  return LoginController(loginRepository: ref.watch(loginRepositoryProvider));
});

class LoginController {
  final LoginRepository _loginRepository;

  LoginController({required LoginRepository loginRepository})
      : _loginRepository = loginRepository;

  Stream<User?> get getAuthStateChange => _loginRepository.getAuthStateChange;

  User get user=> _loginRepository.user;

  Future<UserCredential?> signInWithGoogle() {
    return _loginRepository.signInWithGoogle();
  }

 
  signOut() {
    return _loginRepository.signOut();
  }

  Future<bool> userExists() {
    return _loginRepository.userExists();
  }

  Future<void> createUser() {
    return _loginRepository.createUser();
  }
}
