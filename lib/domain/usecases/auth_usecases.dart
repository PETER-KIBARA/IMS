import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'params/auth_params.dart';
import 'params/no_param.dart';

class SignInWithGoogleUsecase extends Usecase<Result, NoParam> {
  SignInWithGoogleUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(NoParam params) async => _authRepository.signInWithGoogle();
}

class SignInWithEmailAndPasswordUsecase extends Usecase<Result, EmailPasswordParams> {
  SignInWithEmailAndPasswordUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(EmailPasswordParams params) async =>
      _authRepository.signInWithEmailAndPassword(params.email, params.password);
}

class SignUpWithEmailAndPasswordUsecase extends Usecase<Result, EmailPasswordParams> {
  SignUpWithEmailAndPasswordUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(EmailPasswordParams params) async =>
      _authRepository.signUpWithEmailAndPassword(params.email, params.password);
}

class SendPasswordResetEmailUsecase extends Usecase<Result, EmailParams> {
  SendPasswordResetEmailUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<void>> call(EmailParams params) async =>
      _authRepository.sendPasswordResetEmail(params.email);
}

class SignOutUsecase extends Usecase<Result, NoParam> {
  SignOutUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<void>> call(NoParam params) async => _authRepository.signOut();
}

class GetCurrentUserUsecase extends Usecase<Result, NoParam> {
  GetCurrentUserUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(NoParam params) async => _authRepository.getCurrentUser();
}
