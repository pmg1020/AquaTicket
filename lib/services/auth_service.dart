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
      // ✅ Firestore에 사용자 정보 저장 경로: users/{user.uid} (최상위 컬렉션)
      await _firestore
          .collection('users') // 'users' 컬렉션 (루트 레벨)
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
