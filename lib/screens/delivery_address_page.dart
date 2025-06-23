import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_edit_address_page.dart';

class DeliveryAddressPage extends StatefulWidget {
  const DeliveryAddressPage({super.key});

  @override
  State<DeliveryAddressPage> createState() => _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _addressesStream;

  @override
  void initState() {
    super.initState();
    _loadAddressesStream();
  }

  void _loadAddressesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      _addressesStream = Stream.empty();
      return;
    }

    final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');
    final String userId = user.uid;

    _addressesStream = _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .snapshots();
  }

  void _navigateToAddEditAddress({Map<String, dynamic>? addressData, String? addressId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressPage(
          addressData: addressData,
          addressId: addressId,
        ),
      ),
    );
  }

  void _deleteAddress(String addressId) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인된 사용자 정보가 없어 배송지를 삭제할 수 없습니다.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('배송지 삭제'),
        content: const Text('정말 이 배송지를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니요'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');
    final String userId = user.uid;

    try {
      await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 배송지가 삭제되었습니다.')),
      );
    } catch (e) {
      print("배송지 삭제 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('배송지 삭제 실패: $e')),
      );
    }
  }

  // ✅ 연락처 하이픈 포맷팅 헬퍼 함수
  String _formatPhoneNumber(String number) {
    String cleanedNumber = number.replaceAll(RegExp(r'[^0-9]'), ''); // 숫자만 남김
    if (cleanedNumber.length == 10) {
      return '${cleanedNumber.substring(0, 3)}-${cleanedNumber.substring(3, 6)}-${cleanedNumber.substring(6)}';
    } else if (cleanedNumber.length == 11) {
      return '${cleanedNumber.substring(0, 3)}-${cleanedNumber.substring(3, 7)}-${cleanedNumber.substring(7)}';
    }
    return number; // 다른 길이는 그대로 반환 (원래 입력값 유지)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '배송지 관리',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _navigateToAddEditAddress(),
            tooltip: '새 배송지 추가',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _addressesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }

          final addresses = snapshot.data?.docs ?? [];

          if (addresses.isEmpty) {
            return const Center(child: Text('등록된 배송지가 없습니다.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addressDoc = addresses[index];
              final addressData = addressDoc.data() as Map<String, dynamic>;
              final addressId = addressDoc.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!, width: 1.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addressData['recipientName'] ?? '이름 없음',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPhoneNumber(addressData['phoneNumber'] ?? '연락처 없음'), // ✅ 포맷팅 적용
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${addressData['zipCode'] ?? ''} ${addressData['address1'] ?? ''} ${addressData['address2'] ?? ''}',
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _navigateToAddEditAddress(addressData: addressData, addressId: addressId),
                              child: const Text('수정'),
                            ),
                            TextButton(
                              onPressed: () => _deleteAddress(addressId),
                              child: const Text('삭제', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
