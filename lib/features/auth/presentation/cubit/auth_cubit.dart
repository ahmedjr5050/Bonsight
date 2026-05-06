import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Very basic validation mock for the UI test
    if (email.isNotEmpty && password.isNotEmpty) {
      emit(AuthSuccess());
    } else {
      emit(const AuthFailure("Please enter both email and password"));
    }
  }
}
