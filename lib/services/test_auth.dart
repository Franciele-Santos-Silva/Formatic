import 'test_auth_services.dart';

Future<void> testAuth() async {
  final auth = AuthService();

  final signUpResponse = await auth.signUp(
    'teste@email.com',
    '12345678',
  );
  print('Usuário criado: ${signUpResponse.user?.id}');

  final signInResponse = await auth.signIn(
    'teste@email.com',
    '12345678',
  );
  print('Login bem-sucedido! ${signInResponse.user?.email}');
}
