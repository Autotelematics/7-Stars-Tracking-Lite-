part of 'singin_cubit.dart';

abstract class SinginState {
  const SinginState();
}

class SinginInitial extends SinginState {}

class SigninLoadingState extends SinginState {}

class SignInSuccessState extends SinginState {
  UserLoginData userLoginData;
  SignInSuccessState(this.userLoginData);
}

class SigninErrorState extends SinginState {
  String message;
  SigninErrorState(this.message);
}
