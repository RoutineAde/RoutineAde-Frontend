import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart'; // MIME 타입 가져오기
import 'package:http_parser/http_parser.dart';
import 'package:routine_ade/routine_user/token.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final int groupId;

  const ChatScreen({required this.groupId, super.key});
  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  int? _userId;
  String? _nickname;
  File? _imageFile;

  final Set<String> _shownDates = {}; // 날짜가 중복해서 나오지 않도록 관리하는 Set

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // 사용자 정보 로드
    _loadChatMessages(); // 채팅 메시지 로드
  }

  Future<void> fetchUserInfo(int groupId) async {
    final url = Uri.parse('http://15.164.88.94/groups/$groupId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedResponse);

        setState(() {
          _userId = data['groupMembers'][0]['userId'];
          _nickname = data['groupMembers'][0]['nickname'];
        });

        print('Fetched user info: $_nickname');
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      await fetchUserInfo(widget.groupId);
    } catch (e) {
      print("Error loading user info: $e");
    }
  }

  // Future<List<dynamic>> fetchChatMessages(int groupId) async {
  //   final url = Uri.parse('http://15.164.88.94:8080/groups/$groupId/chatting');
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   };

  //   try {
  //     final response = await http.get(url, headers: headers);
  //     if (response.statusCode == 200) {
  //       final decodedResponse = utf8.decode(response.bodyBytes);
  //       final data = json.decode(decodedResponse);
  //       print('Fetched chat messages: $data'); // 추가된 로그

  //       return data['groupChatting'];
  //     } else {
  //       throw Exception('Failed to load chat messages');
  //     }
  //   } catch (e) {
  //     print('Error fetching chat messages: $e');
  //     return [];
  //   }
  // }
  Future<void> _loadChatMessages() async {
    try {
      final chatMessages = await fetchChatMessages(widget.groupId);
      setState(() {
        _messages.clear(); // 이전 메시지 삭제
        _shownDates.clear(); // 날짜도 초기화
        for (var chatDay in chatMessages) {
          final createdDate = chatDay['createdDate'];
          final messages = chatDay['groupChatting'];
          // 날짜 표시가 필요할 때 추가
          if (!_shownDates.contains(createdDate)) {
            _shownDates.add(createdDate);
            _addDateLabel(createdDate);
          }
          // 각 메시지를 추가
          for (var chat in messages) {
            _addMessageFromApi(chat);
          }
        }
      });
    } catch (e) {
      print("Error loading chat messages: $e");
    }
  }

  void _addDateLabel(String createdDate) {
    // 날짜를 메시지 리스트에 추가하는 함수
    final dateLabel = ChatMessage(
      text: '', // 날짜는 텍스트가 없음
      isMine: false,
      nickname: null,
      profileImage: null,
      image: null,
      createdDate: createdDate,
      createdTime: '', // 시간도 없음
      animationController: AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, dateLabel);
    });
    dateLabel.animationController.forward();
  }

  void _addMessageFromApi(dynamic chatData) {
    final createdTime = chatData['createdTime'] ?? '시간을 로드하지 못하였습니다.';
    final message = ChatMessage(
      text: chatData['content'] ?? '',
      isMine: chatData['isMine'] ?? false,
      nickname: chatData['nickname'] ?? _nickname,
      profileImage: chatData['profileImage'],
      image: chatData['image'],
      createdDate: '', // 날짜는 별도로 관리되므로 여기서는 표시하지 않음
      createdTime: createdTime,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }

  Future<List<dynamic>> fetchChatMessages(int groupId) async {
    final url = Uri.parse('http://15.164.88.94/groups/$groupId/chatting');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedResponse);

        return data['groupChatting'];
      } else {
        throw Exception('Failed to load chat messages');
      }
    } catch (e) {
      print('Error fetching chat messages: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createChatMessage(
      int groupId, String content, File? imageFile) async {
    final url = Uri.parse('http://15.164.88.94/groups/$groupId/chatting');

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['content'] = content;

    if (imageFile != null) {
      final mimeTypeData =
      lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8])?.split('/');
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : null,
      );

      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final responseBody = json.decode(responseData.body);

        return responseBody; // API 응답을 반환
      } else {
        print(
            'Failed to create chat message. Status code: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');
        return {}; // 실패 시 빈 맵 반환
      }
    } catch (e) {
      print('Failed to send message: $e');
      return {}; // 오류 발생 시 빈 맵 반환
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isComposing = true;
      });
    } else {
      print('No image selected.');
    }
  }

  void _handleSubmitted(String text) async {
    if (text.isEmpty && _imageFile == null) return;

    setState(() {
      _isComposing = false;
    });

    if (_nickname != null) {
      final response =
      await createChatMessage(widget.groupId, text, _imageFile);

      final createdDate = response['createdDate'];
      final createdTime = response['createdTime'];

      // 메시지 전송 후 메시지를 UI에 즉시 추가
      _addMessageFromApi({
        'content': text,
        'isMine': true,
        'nickname': _nickname,
        'createdDate': createdDate,
        'createdTime': createdTime,
        'image': _imageFile?.path, // 선택된 이미지 파일이 있다면 추가
      });

      // 메시지 필드 및 이미지 초기화
      _textController.clear();
      setState(() {
        _imageFile = null;
      });
      await _loadChatMessages();
      // //서버로 메시지 전송
      // await createChatMessage(widget.groupId, text,   createdTime,  _imageFile);
    } else {
      print('Nickname is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경색을 하얀색으로 설정
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, index) => _messages[index],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white, // 텍스트 필드 배경색을 하얀색으로 설정
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: const IconThemeData(color: Colors.blueAccent),
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 8.0, vertical: 8.0), // 상하 좌우 여백 설정
        padding: const EdgeInsets.symmetric(horizontal: 12.0), // 내부 패딩 설정
        decoration: BoxDecoration(
          color: Colors.white, // 배경 흰색 (전체 배경과 일치)
          borderRadius: BorderRadius.circular(30.0), // 모서리를 둥글게 설정
          border: Border.all(
            color: Colors.grey, // 테두리 색상 설정
            width: 1.0, // 테두리 두께 설정
          ),
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.image,
                color: Colors.grey,
                size: 30.0, // 아이콘 크기 조정
              ),
              onPressed: _pickImage,
            ),
            const SizedBox(width: 8.0), // 아이콘과 텍스트필드 사이 간격
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.isNotEmpty || _imageFile != null;
                  });
                },
              ),
            ),
            const SizedBox(width: 8.0), // 텍스트필드와 전송 버튼 사이 간격
            GestureDetector(
              onTap: _isComposing
                  ? () => _handleSubmitted(_textController.text)
                  : null,
              child: Container(
                padding: const EdgeInsets.all(8.0), // 전송 버튼 크기 조정
                decoration: BoxDecoration(
                  color: Colors.amber[200], // 배경색 노란색
                  shape: BoxShape.circle, // 원형으로 설정
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white, // 아이콘 색상 흰색
                  size: 20.0, // 아이콘 크기 축소
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _timer?.cancel();

    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isMine;
  final String? nickname;
  final String? profileImage;
  final String? image;
  final String createdDate;
  final String createdTime;
  final AnimationController animationController;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isMine,
    this.nickname,
    this.profileImage,
    this.image,
    required this.createdDate,
    required this.createdTime,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (createdDate.isNotEmpty)
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  createdDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
              isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: <Widget>[
                if (!isMine)
                  Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profileImage != null && profileImage!.isNotEmpty)
                          CircleAvatar(
                            backgroundImage: NetworkImage(profileImage!),
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isMine
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      if (nickname != null && !isMine)
                        Text(
                          nickname!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      if (image != null && image!.isNotEmpty)
                        Image.network(
                          image!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      if (text.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // 회색 배경
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            text,
                            style: const TextStyle(color: Colors.black),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      if (!isMine)
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            createdTime,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      if (isMine)
                        Container(
                          margin: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            createdTime,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}