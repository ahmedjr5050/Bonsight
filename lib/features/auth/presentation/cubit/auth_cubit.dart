import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bonssight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRemoteDataSource _authDataSource;

  AuthCubit({required AuthRemoteDataSource authDataSource})
    : _authDataSource = authDataSource,
      super(AuthInitial());

  void checkAuthStatus() {
    final user = _authDataSource.currentUser;
    if (user != null) {
      emit(AuthSuccess(uid: user.uid, email: user.email ?? ''));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authDataSource.signIn(email, password);
      emit(AuthSuccess(uid: user.uid, email: user.email ?? ''));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authDataSource.signUp(email, password);
      emit(AuthSuccess(uid: user.uid, email: user.email ?? ''));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> signOut() async {
    await _authDataSource.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      await _authDataSource.forgotPassword(email);
      emit(PasswordResetEmailSent());
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
