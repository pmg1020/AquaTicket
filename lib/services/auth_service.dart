import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUp(String email, String password, String nickname) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    if (user != null) {
      // Canvas 환경의 appId를 가져옵니다.
      final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

      // ✅ Firestore에 사용자 정보 저장 경로 변경: artifacts/{appId}/users/{user.uid}
      await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('users') // users 서브컬렉션
          .doc(user.uid)
          .set({
        'email': user.email,
        'uid': user.uid,
        'nickname': nickname,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
