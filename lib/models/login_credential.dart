class LoginCredential {
  String username;
  String password;
  String secretKey;
  String checksum;

  LoginCredential(
      {required this.username,
      required this.password,
      required this.secretKey,
      required this.checksum});
}
