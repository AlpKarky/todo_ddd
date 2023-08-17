class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _authFacade;

  SignInFormBloc(this._authFacade) : super(SignInFormState.initial()) {
    on<SignInFormEvent>((events, emit) async {
      events.map(
        emailChanged: (event) async => await _emailChanged(event, emit),
        passwordChanged: (event) async => await _passwordChanged(event, emit),
        registerWithEmailAndPasswordPressed: (event) async =>
            await _registerWithEmailAndPasswordPressed(event, emit),
        signInWithEmailAndPasswordPressed: (event) async =>
            await _singInWithEmailAndPasswordPressed(event, emit),
        signInWithGooglePressed: (event) async =>
            await _signInWithGooglePressed(event, emit),
      );
    });
  }

  _emailChanged(EmailChanged event, Emitter<SignInFormState> emit) async {
    emit(state.copyWith(
      emailAddress: EmailAddress(event.emailStr),
      authFailureOrSuccessOption: none(),
    ));
  }

  _passwordChanged(PasswordChanged event, Emitter<SignInFormState> emit) async {
    emit(state.copyWith(
      emailAddress: EmailAddress(event.passwordStr),
      authFailureOrSuccessOption: none(),
    ));
  }

  _registerWithEmailAndPasswordPressed(
      RegisterWithEmailAndPasswordPressed event,
      Emitter<SignInFormState> emit) async {
    await _performActionOnAuthFacadeWithEmailAndPassword(
        _authFacade.registerWithEmailAndPassword, emit);
  }

  _singInWithEmailAndPasswordPressed(SignInWithEmailAndPasswordPressed event,
      Emitter<SignInFormState> emit) async {
    await _performActionOnAuthFacadeWithEmailAndPassword(
        _authFacade.signInWithEmailAndPassword, emit);
  }

  _signInWithGooglePressed(
      SignInWithGooglePressed event, Emitter<SignInFormState> emit) async {
    emit(state.copyWith(
      isSubmitting: true,
      authFailureOrSuccessOption: none(),
    ));
    final failureOrSuccess = await _authFacade.signInWithGoogle();
    emit(state.copyWith(
      isSubmitting: false,
      authFailureOrSuccessOption: some(failureOrSuccess),
    ));
  }

  _performActionOnAuthFacadeWithEmailAndPassword(
    Future<Either<AuthFailure, Unit>> Function({
      required EmailAddress emailAddress,
      required Password password,
    }) forwardedCall,
    Emitter<SignInFormState> emit,
  ) async {
    Either<AuthFailure, Unit>? failureOrSuccess;

    final isEmailValid = state.emailAddress.isValid();
    final isPasswordValid = state.password.isValid();

    if (isEmailValid && isPasswordValid) {
      emit(state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: none(),
      ));

      failureOrSuccess = await forwardedCall(
          emailAddress: state.emailAddress, password: state.password);
    }

    emit(state.copyWith(
      isSubmitting: false,
      showErrorMessages: true,
      authFailureOrSuccessOption: optionOf(failureOrSuccess),
    ));
  }
}
