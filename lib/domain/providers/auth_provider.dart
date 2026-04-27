import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository());

final authStateProvider = StreamProvider<AppUser?>((ref) =>
    ref.watch(authRepositoryProvider).authStateChanges);
