import 'dart:convert'; // JSON 인코딩/디코딩을 위해 추가
import 'dart:io'; // 모바일/데스크톱용 File 클래스
import 'package:flutter/foundation.dart'; // kIsWeb (웹 환경 확인용)
import 'package:http/http.dart' as http; // http 패키지 임포트
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:http_parser/http_parser.dart'; // MediaType 사용을 위해 추가 (필요시 pubspec.yaml에 명시적 추가)


class StorageService {
  final _picker = ImagePicker();

  static const String CLOUDINARY_CLOUD_NAME = 'drtzfibx0';
  static const String CLOUDINARY_UPLOAD_PRESET = 'AquaTicket';

  Future<String?> pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

    try {
      final String fileName = const Uuid().v4();
      final String uploadUrl = 'https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/image/upload';

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // 파일 데이터 추가 (filename과 contentType을 명시적으로 설정)
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // Cloudinary API에서 파일을 받는 파라미터 이름 (고정)
          await pickedFile.readAsBytes(), // XFile에서 바이트로 읽기
          filename: pickedFile.name, // 원본 파일 이름 사용
          contentType: pickedFile.mimeType != null ? MediaType.parse(pickedFile.mimeType!) : MediaType('application', 'octet-stream'), // 실제 MIME 타입 또는 기본값
        ),
      );

      // 업로드 프리셋 및 public_id와 같은 추가 파라미터는 필드로 추가
      request.fields['upload_preset'] = CLOUDINARY_UPLOAD_PRESET;
      // public_id는 선택 사항이지만, 명시적으로 보내는 것이 좋습니다.
      request.fields['public_id'] = fileName;

      print("Debug Cloudinary: Requesting upload to: $uploadUrl");
      print("Debug Cloudinary: Upload Preset: $CLOUDINARY_UPLOAD_PRESET");
      print("Debug Cloudinary: File Name: ${pickedFile.name}, MIME Type: ${pickedFile.mimeType}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String imageUrl = responseData['secure_url'];
        print('Cloudinary Image Upload Success: $imageUrl');
        return imageUrl;
      } else {
        // ✅ 400 Bad Request 시 응답 본문 전체 출력 (핵심 디버깅 정보)
        print('Cloudinary Image Upload Failed: ${response.statusCode}');
        print('Response Body: ${response.body}'); // Cloudinary는 여기에 상세 오류 메시지 제공
        throw Exception('Failed to upload image to Cloudinary: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      // 에러 발생 시 사용자에게 더 명확한 메시지 제공
      // 예: "이미지 업로드 중 네트워크 오류 또는 Cloudinary 설정 오류 발생."
      return null;
    }
  }
}
