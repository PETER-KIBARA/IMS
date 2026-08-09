// lib/features/auth/domain/repositories/auth_repository.dart

import '../../../../core/common/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> signInWithGoogle();

  Future<Result<UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<Result<UserEntity>> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();

  Future<Result<UserEntity?>> getCurrentUser();
}
