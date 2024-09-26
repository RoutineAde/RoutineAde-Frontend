import 'dart:convert'; // jsonDecode와 utf-8 사용
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // http_parser 패키지 추가
import 'package:mime/mime.dart';
import 'package:routine_ade/routine_user/token.dart';

class ProfileChange extends StatefulWidget {
  const ProfileChange({super.key});

  @override
  _ProfileChangeState createState() => _ProfileChangeState();
}

class _ProfileChangeState extends State<ProfileChange> {
  File? _imageFile;
  String? _imageUrl; // Google Photos URL을 저장할 변수
  String _nickname = '';
  String _intro = '';
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isNicknameValid = true;
  String _nicknameErrorMessage = '';
  // String token =
  //     'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw'; // 실제 토큰으로 교체

  // Initialize with data from MyInfo
  @override
  void initState() {
    super.initState();
    _fetchInitialProfileData(); // Fetch data at startup
  }

  // UTF-8 변환을 적용하여 프로필 정보를 가져오는 함수
  Future<void> _fetchInitialProfileData() async {
    try {
      // API 호출
      final response = await http.get(
        Uri.parse('http://15.164.88.94/users/infos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8', // UTF-8 설정
        },
      );

      if (response.statusCode == 200) {
        // UTF-8로 디코딩된 응답을 처리
        final profileData = jsonDecode(utf8.decode(response.bodyBytes));

        // 상태 업데이트
        setState(() {
          _nickname = profileData['nickname'];
          _intro = profileData['intro'];
          _imageUrl = profileData['profileImage']; // 프로필 이미지 URL
        });

        // 컨트롤러에 데이터 설정
        _nicknameController.text = _nickname;
        _bioController.text = _intro;
      } else {
        print(
            'Failed to fetch profile info. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile info: $e');
    }
  }

  Future<void> _pickImageFromGooglePhotos(String googlePhotosUrl) async {
    setState(() {
      _imageFile = null; // 로컬 이미지 파일을 비우고
      _imageUrl = googlePhotosUrl; // Google Photos URL을 설정
    });
  }

  Future<void> _pickImageFromLocal() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // 로컬 이미지 파일 경로 설정
        _imageUrl = null; // URL 초기화
      });
    } else {
      print('No image selected.');
    }
  }

  void _validateNickname(String value) {
    setState(() {
      if (value.length > 10) {
        _isNicknameValid = false;
        _nicknameErrorMessage = 'Please enter less than 10 characters.';
      } else {
        _isNicknameValid = true;
        _nicknameErrorMessage = '';
      }
    });
  }

  Future<void> _updateProfile() async {
    final url = Uri.parse('http://15.164.88.94/users/profile');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8', // UTF-8 설정
    };

    try {
      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll(headers);

      // 닉네임과 한 줄 소개를 추가
      request.fields['nickname'] =
          utf8.decode(utf8.encode(_nicknameController.text));
      request.fields['intro'] = utf8.decode(utf8.encode(_bioController.text));

      // Google Photos 이미지 URL이 제공된 경우 추가
      if (_imageUrl != null && _imageUrl!.isNotEmpty) {
        request.fields['profileImageUrl'] = _imageUrl!;
      }
      // 로컬 이미지 파일이 선택된 경우 추가
      else if (_imageFile != null) {
        final mimeTypeData = lookupMimeType(_imageFile!.path)?.split('/');
        if (mimeTypeData != null && mimeTypeData.length == 2) {
          var multipartFile = await http.MultipartFile.fromPath(
            'image',
            _imageFile!.path,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          );
          request.files.add(multipartFile);
        } else {
          print("Could not determine MIME type.");
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Profile updated successfully.");

        if (responseBody.isNotEmpty) {
          try {
            final responseData =
                jsonDecode(utf8.decode(responseBody.codeUnits)); // UTF-8 디코딩

            if (responseData.containsKey('profileImage')) {
              final newProfileImageUrl = responseData['profileImage'];
              print('Updated profile image URL: $newProfileImageUrl');

              setState(() {
                _imageFile = null; // 로컬 이미지를 초기화
                _imageUrl = newProfileImageUrl; // 새로운 이미지 URL로 갱신
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로필이 성공적으로 업데이트되었습니다.')),
              );
            } else {
              print('Response does not contain profileImage URL.');
            }
          } catch (e) {
            print('Failed to parse response body: $e');
          }
        } else {
          print('Response body is empty.');
        }
      } else {
        print("Failed to update profile. Status code: ${response.statusCode}");
        print("Response: $responseBody");
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8DCCFF),
        centerTitle: true,
        title: const Text(
          '프로필 설정',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImageFromLocal, // 로컬 이미지 선택 기능
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : _imageUrl != null
                                ? NetworkImage(
                                    _imageUrl!) // Google Photos 이미지 사용
                                : const AssetImage(
                                        'assets/images/default_profile.png')
                                    as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImageFromLocal,
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: Icon(Icons.camera_alt, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  child: const Text("프로필 사진 삭제"),
                  onPressed: () {
                    setState(() {
                      _imageFile = null; // 프로필 사진 삭제
                      _imageUrl = null; // Google Photos URL 삭제
                    });
                  },
                ),
                const SizedBox(height: 50),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("닉네임 (필수)"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nicknameController,
                  onChanged: _validateNickname,
                  decoration: InputDecoration(
                    hintText: '닉네임',
                    errorText: !_isNicknameValid
                        ? _nicknameErrorMessage
                        : null, // 에러 메시지 표시
                    counterText: '', // 글자수 카운터 삭제
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.black, // 기본 테두리 검은색
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.black, // 포커스 시 테두리 검은색
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.red, // 에러 상태 테두리 빨간색
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.red, // 에러 상태에서 포커스 시 테두리 빨간색
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("한 줄 소개 (선택)"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    hintText: '한 줄 소개',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8DCCFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _updateProfile,
                child: const Text(
                  '변경 완료',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
