import 'dart:async';
import '../models/app_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current;

  MockAuthRepository() {
    _current = AppUser(
      uid: 'mock-uid-123',
      email: 'demo@plantcare.app',
      displayName: 'Plant Lover',
      createdAt: DateTime.now(),
    );
    Future.microtask(() => _controller.add(_current));
  }

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> signIn(String email, String password) async {
    _current = AppUser(
      uid: 'mock-uid-123',
      email: email,
      displayName: 'Plant Lover',
      createdAt: DateTime.now(),
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<AppUser> signUp(String email, String password, String displayName) async {
    _current = AppUser(
      uid: 'mock-uid-123',
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }
}
