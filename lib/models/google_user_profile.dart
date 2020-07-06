import 'package:google_sign_in/google_sign_in.dart';

class GoogleUserProfile {
  String displayName;
  String id;
  String email;
  String photoUrl;
  Future<Map<String, String>> authHeaders;

  GoogleUserProfile({
    this.displayName,
    this.id,
    this.email,
    this.photoUrl,
    this.authHeaders,
  });

  factory GoogleUserProfile.fromJson(GoogleSignInAccount account) {
    return GoogleUserProfile(
      displayName: account.displayName,
      id: account.id,
      email: account.email,
      photoUrl: account.photoUrl,
      authHeaders: account.authHeaders,
    );
  }
}