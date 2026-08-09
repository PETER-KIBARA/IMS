import '../../../core/common/result.dart';
import '../../models/user_model.dart';

abstract class AuthDataSource {
  Future<Result<UserModel>> signInWithGoogle();

  Future<Result<UserModel>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<Result<UserModel>> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();

  Future<Result<UserModel?>> getCurrentUser();
}
