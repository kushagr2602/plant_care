import '../models/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser> signIn(String email, String password);
  Future<AppUser> signUp(String email, String password, String displayName);
  Future<void> signOut();
  AppUser? get currentUser;
}
