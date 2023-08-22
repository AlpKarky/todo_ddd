import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/auth/i_auth_facade.dart';

part 'auth_event.dart';
part 'auth_state.dart';

part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthFacade _authFacade;
  AuthBloc(this._authFacade) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
          authCheckRequested: (event) async =>
              await _authCheckRequested(event, emit),
          signedOut: (event) async => await _signedOut(event, emit));
    });
  }

  Future<void> _authCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    final optionUser = await _authFacade.getSignedInUser();
    emit(
      optionUser.fold(
        () => const AuthState.unauthenticated(),
        (_) => const AuthState.authenticated(),
      ),
    );
  }

  Future<void> _signedOut(SignedOut event, Emitter<AuthState> emit) async {
    await _authFacade.signOut();
    emit(
      const AuthState.unauthenticated(),
    );
  }
}
