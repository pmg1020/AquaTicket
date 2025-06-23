import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'change_password_page.dart';
import 'delivery_address_page.dart'; // ✅ DeliveryAddressPage 임포트

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('artifacts')
            .doc(appId)
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          _userData = userDoc.data() as Map<String, dynamic>;
          _nicknameController.text = _userData?['nickname'] ?? '';
          _nameController.text = _userData?['name'] ?? '';
          _contactController.text = _userData?['contact'] ?? '';
          print("사용자 데이터 로드 성공: $_userData");
        } else {
          print("Firestore에서 사용자 문서(_userData)를 찾을 수 없습니다.");
          _nicknameController.text = '';
          _nameController.text = '';
          _contactController.text = '';
        }
      } catch (e) {
        print("Firestore에서 사용자 데이터 로드 중 오류 발생: $e");
        _nicknameController.text = '불러오기 오류';
        _nameController.text = '불러오기 오류';
        _contactController.text = '불러오기 오류';
      }
    } else {
      print("현재 로그인된 사용자가 없습니다.");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인된 사용자가 없어 정보를 수정할 수 없습니다.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

    try {
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'nickname': _nicknameController.text.trim(),
        'name': _nameController.text.trim(),
        'contact': _contactController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 정보가 성공적으로 수정되었습니다!')),
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        _loadUserProfile();
      }
    } catch (e) {
      print("정보 수정 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보 수정 실패: $e')),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 연락처 하이픈 포맷팅 헬퍼 함수
  String _formatPhoneNumber(String number) {
    String cleanedNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedNumber.length == 10) {
      return '${cleanedNumber.substring(0, 3)}-${cleanedNumber.substring(3, 6)}-${cleanedNumber.substring(6)}';
    } else if (cleanedNumber.length == 11) {
      return '${cleanedNumber.substring(0, 3)}-${cleanedNumber.substring(3, 7)}-${cleanedNumber.substring(7)}';
    }
    return cleanedNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '내 정보',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          _isLoading // 로딩 중에는 버튼 비활성화
              ? const SizedBox(
              width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black,))
              : IconButton(
            icon: Icon(_isEditing ? Icons.check_circle_outline : Icons.edit, color: Colors.black),
            onPressed: () {
              if (_isEditing) {
                _updateUserProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading && !_isEditing
          ? const Center(child: CircularProgressIndicator(color: Colors.black,))
          : _currentUser == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[400]!, width: 1),
                ),
                child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 32),

            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildProfileRow('이메일', _currentUser?.email ?? '정보 없음', false),
                    const Divider(height: 1, color: Colors.grey),
                    _buildProfileRow('닉네임', _userData?['nickname'] ?? '정보 없음', _isEditing, controller: _nicknameController),
                    const Divider(height: 1, color: Colors.grey),
                    _buildProfileRow('이름 (실명)', _userData?['name'] ?? '미입력', _isEditing, controller: _nameController),
                    const Divider(height: 1, color: Colors.grey),
                    _buildProfileRow('연락처', _formatPhoneNumber(_userData?['contact'] ?? ''), _isEditing, controller: _contactController, keyboardType: TextInputType.phone),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isEditing ? null : () {
                  // ✅ 배송지 관리 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DeliveryAddressPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('배송지 관리', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isEditing ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('비밀번호 변경', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, bool isEditable, {TextEditingController? controller, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label: ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: isEditable && controller != null
                ? TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: '입력하세요',
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            )
                : Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
