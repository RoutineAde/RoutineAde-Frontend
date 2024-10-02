import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../routine_home/MyRoutinePage.dart';
import 'package:routine_ade/routine_user/token.dart'; // 토큰 가져오는 곳

class ProfileSetting extends StatefulWidget {
  const ProfileSetting({super.key});

  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isNicknameValid = true;
  String _nicknameErrorMessage = '';

  void _validateNickname(String value) {
    setState(() {
      if (value.length > 10) {
        _isNicknameValid = false;
        _nicknameErrorMessage = '10글자 이내로 입력해주세요.';
      } else {
        _isNicknameValid = true;
        _nicknameErrorMessage = '';
      }
    });
  }

  Future<void> _registerUserInfo() async {
    const url = 'http://15.164.88.94/users/infos'; // API URL

    // POST 요청 준비
    final request = http.MultipartRequest('POST', Uri.parse(url));

    // 토큰 확인 및 추가
    if (token == null || token.isEmpty) {
      print('Token is missing.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('토큰이 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    print('Current token: $token');
    request.headers['Authorization'] = 'Bearer $token'; // 헤더에 토큰 추가

    // 닉네임과 한 줄 소개 추가
    request.fields['nickname'] = _nicknameController.text;
    request.fields['intro'] = _bioController.text;

    // 선택한 이미지가 있으면 파일로 추가
    if (_imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    }

    try {
      // 서버에 요청 전송
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      // 상태 코드가 200 또는 201인 경우에 성공 처리
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = utf8.decode(responseData.bodyBytes);
        print('User info registered successfully: $responseBody');

        // MyRoutinePage로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyRoutinePage(),
          ),
        );
      } else {
        // 실패 시 서버에서 보낸 오류 메시지 출력
        final errorBody = utf8.decode(responseData.bodyBytes);
        print('Failed to register user info. Status code: ${response.statusCode}');
        print('Response body: $errorBody');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정보 등록 실패: $errorBody')),
        );
      }
    } catch (e) {
      print('Error during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정보 등록 중 오류가 발생했습니다.')),
      );
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : const AssetImage('assets/images/default_profile.png')
                        as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
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
                const SizedBox(height: 50),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("닉네임"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nicknameController,
                  onChanged: _validateNickname,
                  decoration: InputDecoration(
                    hintText: '닉네임',
                    errorText: !_isNicknameValid ? _nicknameErrorMessage : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: _isNicknameValid ? Colors.grey : Colors.red,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: _isNicknameValid ? Colors.blue : Colors.red,
                      ),
                    ),
                  ),
                  maxLength: 10,
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("한 줄 소개"),
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
                onPressed: () {
                  if (_isNicknameValid) {
                    _registerUserInfo();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('닉네임이 유효하지 않습니다.')),
                    );
                  }
                },
                child: const Text(
                  '완료',
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
