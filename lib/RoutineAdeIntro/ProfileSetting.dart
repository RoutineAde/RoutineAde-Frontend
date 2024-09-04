import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../routine_home/MyRoutinePage.dart';


class ProfileSetting extends StatefulWidget {
  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    var status = await Permission.photos.status;

    // Check if permission is granted
    if (status.isGranted) {
      try {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _imageFile = image;
          });
        }
      } catch (e) {
        print("Error picking image: $e");
      }
    }
    // Request permission if it is denied or restricted
    else if (status.isDenied || status.isRestricted) {
      status = await Permission.photos.request();
      if (status.isGranted) {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _imageFile = image;
          });
        }
      } else {
        print("갤러리 접근 권한이 거부되었습니다.");
      }
    }
    // Handle case where permission is permanently denied
    else if (status.isPermanentlyDenied) {
      openAppSettings();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color(0xFF8DCCFF),
        centerTitle: true,
        title: Text(
          '프로필 설정',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(File(_imageFile!.path))
                            : AssetImage('assets/images/default_profile.png')
                        as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(Icons.camera_alt, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("닉네임"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nicknameController,
                  onChanged: _validateNickname,
                  decoration: InputDecoration(
                    hintText: '닉네임',
                    errorText: !_isNicknameValid
                        ? _nicknameErrorMessage
                        : '10글자 이내로 입력해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: _isNicknameValid ? Colors.red : Colors.grey,
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
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("한 줄 소개"),
                ),
                SizedBox(height: 10),
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
                  backgroundColor: Color(0xFF8DCCFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyRoutinePage(),
                    ),
                  );
                },
                child: Text(
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
