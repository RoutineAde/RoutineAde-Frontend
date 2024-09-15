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
  Timer? _timer;
  String? _createDate;
  // String? _createdTime;
  DateTime? _lastDateDisplayed;
  DateTime parseDate(String dateString) {
    // 날짜 형식: "2024년 09월 16일 (월)"
    final datePattern = RegExp(r'(\d{4})년 (\d{2})월 (\d{2})일');
    final match = datePattern.firstMatch(dateString);

    if (match != null) {
      final year = match.group(1);
      final month = match.group(2);
      final day = match.group(3);
      final formattedDate = '$year-$month-$day'; // YYYY-MM-DD 형식으로 변환
      return DateTime.parse(formattedDate);
    } else {
      throw const FormatException('Invalid date format');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // 사용자 정보 로드
    _loadChatMessages(); // 채팅 메시지 로드

    // _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
    //   _loadChatMessages(); // 주기적으로 채팅 메시지를 불러옴
    // });
  }

  // @override
  // void dispose() {
  //   _timer?.cancel(); // 타이머 해제
  //   for (ChatMessage message in _messages) {
  //     message.animationController.dispose();
  //   }
  //   super.dispose();
  // }

  Future<void> fetchUserInfo(int groupId) async {
    final url = Uri.parse('http://15.164.88.94:8080/groups/$groupId');
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
          _userId = data['groupMembers'][0]
              ['userId']; // Assuming the user is the first group member
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

  Future<List<dynamic>> fetchChatMessages(int groupId) async {
    final url = Uri.parse('http://15.164.88.94:8080/groups/$groupId/chatting');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedResponse);
        print('Fetched chat messages: $data'); // 추가된 로그

        return data['groupChatting'];
      } else {
        throw Exception('Failed to load chat messages');
      }
    } catch (e) {
      print('Error fetching chat messages: $e');
      return [];
    }
  }

  Future<void> _loadChatMessages() async {
    try {
      final chatMessages = await fetchChatMessages(widget.groupId);
      setState(() {
        _messages.clear(); // Clear the old messages
        for (var chatData in chatMessages) {
          _addMessageFromApi(chatData);
        }
      });
    } catch (e) {
      print("Error loading chat messages: $e");
    }
  }

  void _addMessageFromApi(dynamic chatData) {
    final createdTime = chatData['createdTime'] ?? '시간을 로드하지 못하였습니다.';
    final createdDate = chatData['createdDate'] ?? '날짜를 로드하지 못하였습니다.';

    final now = DateTime.now();
    DateTime messageDate;
    try {
      messageDate = parseDate(createdDate); // 커스텀 파서 사용
    } catch (e) {
      print('Date parsing error: $e');
      messageDate = now; // 파싱 오류 발생 시 현재 날짜로 설정
    }

    // 하루에 한 번만 표시하기 위해 날짜 비교
    if (_lastDateDisplayed == null || !isSameDay(now, messageDate)) {
      _lastDateDisplayed = messageDate;
    } else {
      _lastDateDisplayed = null;
    }

    final message = ChatMessage(
      text: chatData['content'] ?? '',
      isMine: chatData['isMine'] ?? false,
      nickname: chatData['nickname'] ?? _nickname,
      profileImage: chatData['profileImage'],
      image: chatData['image'],
      createdDate: _lastDateDisplayed != null ? createdDate : '',
      createdTime: createdTime,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
      ),
    );

    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<Map<String, dynamic>> createChatMessage(
      int groupId, String content, File? imageFile) async {
    final url = Uri.parse('http://15.164.88.94:8080/groups/$groupId/chatting');

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

      // API 응답에서 createdDate와 createdTime을 추출합니다.
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
