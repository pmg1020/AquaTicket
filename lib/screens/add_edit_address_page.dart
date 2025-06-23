import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditAddressPage extends StatefulWidget {
  final Map<String, dynamic>? addressData; // 수정할 주소 데이터 (null이면 추가 모드)
  final String? addressId; // 수정할 주소 ID

  const AddEditAddressPage({
    super.key,
    this.addressData,
    this.addressId,
  });

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();

  bool _isLoading = false;
  User? _currentUser; // ✅ 현재 로그인된 사용자 정보
  Map<String, dynamic>? _currentProfileData; // ✅ 현재 사용자의 Firestore 프로필 데이터

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadCurrentProfileDataAndInitForm(); // ✅ 현재 사용자 프로필 로드 및 폼 초기화
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _phoneNumberController.dispose();
    _zipCodeController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    super.dispose();
  }

  // ✅ 현재 사용자 프로필 데이터 로드 및 폼 필드 초기화
  Future<void> _loadCurrentProfileDataAndInitForm() async {
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
          _currentProfileData = userDoc.data() as Map<String, dynamic>;
        }
      } catch (e) {
        print("사용자 프로필 로드 오류 (AddEditAddressPage): $e");
      }
    }

    // 수정 모드일 경우 기존 주소 데이터 채우기
    if (widget.addressData != null) {
      _recipientNameController.text = widget.addressData!['recipientName'] ?? '';
      _phoneNumberController.text = widget.addressData!['phoneNumber'] ?? '';
      _zipCodeController.text = widget.addressData!['zipCode'] ?? '';
      _address1Controller.text = widget.addressData!['address1'] ?? '';
      _address2Controller.text = widget.addressData!['address2'] ?? '';
    } else {
      // 추가 모드이고, 현재 사용자 프로필 데이터가 있다면 기본값으로 채우기
      if (_currentProfileData != null) {
        _recipientNameController.text = _currentProfileData!['name'] ?? _currentProfileData!['nickname'] ?? ''; // 실명 없으면 닉네임
        _phoneNumberController.text = _currentProfileData!['contact'] ?? '';
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false; // 폼 로딩 완료 (네트워크 작업 완료)
      });
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('로그인된 사용자가 없습니다.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');
    final String userId = user.uid;

    final addressData = {
      'recipientName': _recipientNameController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'zipCode': _zipCodeController.text.trim(),
      'address1': _address1Controller.text.trim(),
      'address2': _address2Controller.text.trim(),
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.addressId == null) {
        await FirebaseFirestore.instance
            .collection('artifacts')
            .doc(appId)
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .add(addressData);
        _showSnackBar('✅ 배송지가 추가되었습니다!');
      } else {
        await FirebaseFirestore.instance
            .collection('artifacts')
            .doc(appId)
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(widget.addressId)
            .update(addressData);
        _showSnackBar('✅ 배송지가 수정되었습니다!');
      }
      Navigator.pop(context, true); // 성공 시 true 반환
    } catch (e) {
      print("배송지 저장 오류: $e");
      _showSnackBar('배송지 저장 실패: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ✅ 연락처 하이픈 포맷팅 헬퍼 함수 (표시용)
  String _formatPhoneNumberForDisplay(String number) {
    String cleanedNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedNumber.length == 10) {
      return '${cleanedNumber.substring(0, 3)}-${cleanedNumber.substring(3, 6)}-${cleanedNumber.substring(6)}';
    } else if (cleanedNumber.length == 11) {
      return '${cleanedNumber.substring(0, 3)}-${cleanedNumber.substring(3, 7)}-${cleanedNumber.substring(7)}';
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.addressData == null ? '새 배송지 추가' : '배송지 수정',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading && widget.addressData == null // 추가 모드 초기 로딩 또는 저장 중일 때만 로딩 표시
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  _recipientNameController,
                  '받는 사람 이름',
                  '홍길동',
                  validator: (value) => value!.isEmpty ? '이름을 입력해주세요' : null,
                ),
                _buildTextField(
                  _phoneNumberController,
                  '연락처',
                  '010-1234-5678',
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? '연락처를 입력해주세요' : null,
                ),
                _buildTextField(
                  _zipCodeController,
                  '우편번호',
                  '00000',
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? '우편번호를 입력해주세요' : null,
                ),
                _buildTextField(
                  _address1Controller,
                  '기본 주소',
                  '서울시 강남구',
                  validator: (value) => value!.isEmpty ? '기본 주소를 입력해주세요' : null,
                ),
                _buildTextField(
                  _address2Controller,
                  '상세 주소 (선택)',
                  '아파트 101동 101호',
                  isOptional: true,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    widget.addressData == null ? '배송지 추가' : '배송지 수정',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, String hintText, {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText + (isOptional ? ' (선택 사항)' : ''),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
          ),
        ),
        validator: isOptional ? null : validator,
      ),
    );
  }
}
