/// A demo login that works without the Calley test server (which answers
/// 404 on every path). Signing in with it switches the app to the bundled
/// sample data, and the sample-data banner says so on every screen: nothing
/// pretends to come from the server.
abstract final class DemoAccount {
  static const email = 'demo@getcalley.com';
  static const password = 'Demo@1234';

  static bool isDemoEmail(String email) =>
      email.trim().toLowerCase() == DemoAccount.email;
}
