import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.initial()) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    emit(state.copyWith(status: AuthStatus.loading));

    final currentUser = await StorageService.getCurrentUser();
    if (currentUser != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userEmail: currentUser,
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login(String email) async {
    if (email.trim().isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Please enter an email address',
      ));
      return;
    }

    // Basic email validation
    if (!_isValidEmail(email.trim())) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Please enter a valid email address',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await StorageService.saveCurrentUser(email.trim().toLowerCase());
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userEmail: email.trim().toLowerCase(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to login. Please try again.',
      ));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await StorageService.clearCurrentUser();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        userEmail: null,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to logout. Please try again.',
      ));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
}