import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/common/result.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utilities/platform_wrapper.dart';
import '../../../firebase_options.dart';
import '../../models/user_model.dart';
import '../interfaces/auth_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      await googleSignIn.initialize(
        clientId: PlatformWrapper().isIOS
            ? DefaultFirebaseOptions.ios.iosClientId
            : null,
        serverClientId: Constants.webClientId.isNotEmpty
            ? Constants.webClientId
            : null,
      );

      final googleSignInAccount = await googleSignIn
          .attemptLightweightAuthentication();

      // 1. Check if the user canceled the sign-in dialog
      if (googleSignInAccount == null) {
        return Result.failure(error: 'User canceled sign-in.');
      }

      final googleSignInAuthentication = googleSignInAccount.authentication;

      final googleSignInAuthorization = await googleSignInAccount
          .authorizationClient
          .authorizationForScopes(
            Constants.authScopes,
          );

      // 2. Ensure at least one token is present before creating credentials
      if (googleSignInAuthorization?.accessToken == null &&
          googleSignInAuthentication?.idToken == null) {
        return Result.failure(
          error: 'Failed to obtain Google ID or Access Token.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthorization?.accessToken,
        idToken: googleSignInAuthentication?.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        return Result.failure(error: 'User data is null after sign-in.');
      }

      return Result.success(
        data: UserModel.fromFirebaseUser(userCredential.user!),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return Result.failure(error: 'User data is null after sign-in.');
      }

      return Result.success(
        data: UserModel.fromFirebaseUser(userCredential.user!),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(error: _mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel>> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return Result.failure(error: 'User data is null after sign-up.');
      }

      return Result.success(
        data: UserModel.fromFirebaseUser(userCredential.user!),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(error: _mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return Result.success(data: null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(error: _mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  String _mapFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email is already in use by another account.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      return Result.success(
        data: firebaseUser != null
            ? UserModel.fromFirebaseUser(firebaseUser)
            : null,
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
