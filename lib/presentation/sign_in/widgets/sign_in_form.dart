import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/auth/sign_in_form/sign_in_form_bloc.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) {
        state.authFailureOrSuccessOption.fold(
            () {},
            (either) => either.fold((failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      content: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            failure.map(
                                cancelledByUser: (_) => 'Cancelled',
                                serverError: (_) => 'Server error',
                                emailAlreadyInUse: (_) =>
                                    'Email already in use',
                                invalidEmailPasswordCombination: (_) =>
                                    'Invalid email and password combination'),
                          ),
                        ],
                      ),
                    ),
                  );
                }, (_) {
                  //TODO: Navigate to page
                }));
      },
      builder: (context, state) {
        return Form(
            autovalidateMode: state.showErrorMessages
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Padding(
              padding: const EdgeInsets.all(8.0), //TODO: Get from a class
              child: ListView(
                children: [
                  const Text(
                    '📝',
                    style: TextStyle(fontSize: 130),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    onChanged: (value) =>
                        BlocProvider.of<SignInFormBloc>(context)
                            .add(SignInFormEvent.emailChanged(value)),
                    validator: (_) => BlocProvider.of<SignInFormBloc>(context)
                        .state
                        .emailAddress
                        .value
                        .fold(
                          (f) => f.maybeMap(
                            invalidEmail: (_) => 'Invalid Email',
                            orElse: () => null,
                          ),
                          (_) => null,
                        ),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    autocorrect: false,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      BlocProvider.of<SignInFormBloc>(context)
                          .add(SignInFormEvent.passwordChanged(value));
                    },
                    validator: (_) => BlocProvider.of<SignInFormBloc>(context)
                        .state
                        .password
                        .value
                        .fold(
                          (f) => f.maybeMap(
                            shortPassword: (_) => 'Short Password',
                            orElse: () => null,
                          ),
                          (_) => null,
                        ),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Password',
                    ),
                    autocorrect: false,
                    obscureText: true,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TextButton(
                              onPressed: () {
                                BlocProvider.of<SignInFormBloc>(context).add(
                                    const SignInFormEvent
                                        .signInWithEmailAndPasswordPressed());
                              },
                              child: const Text('SIGN IN'))),
                      Expanded(
                          child: TextButton(
                              onPressed: () {
                                BlocProvider.of<SignInFormBloc>(context).add(
                                    const SignInFormEvent
                                        .registerWithEmailAndPasswordPressed());
                              },
                              child: const Text('REGISTER')))
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<SignInFormBloc>(context)
                          .add(const SignInFormEvent.signInWithGooglePressed());
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue),
                    child: const Text(
                      'SIGN IN WITH GOOGLE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (state.isSubmitting) ...[
                    const SizedBox(
                      height: 8,
                    ),
                    const LinearProgressIndicator(),
                  ]
                ],
              ),
            ));
      },
    );
  }
}
