import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password, String nickname) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    if (user != null) {
      final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

      await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('users')
          .doc(user.uid)
          .set({
        'email': user.email,
        'uid': user.uid,
        'nickname': nickname,
        'name': '', // ✅ '이름(실명)' 필드 추가 (초기값 빈 문자열)
        'contact': '', // ✅ '연락처' 필드 추가 (초기값 빈 문자열)
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
