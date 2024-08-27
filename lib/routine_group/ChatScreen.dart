import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:routine_ade/routine_user/token.dart'; // 토큰 경로에 맞게 수정

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

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // 사용자 정보 로드
    _loadChatMessages(); // 채팅 메시지 로드
  }

  Future<Map<String, dynamic>> fetchUserInfo(int groupId) async {
    final url = Uri.parse('http://15.164.88.94:8080/groups/$groupId/userInfo');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 토큰을 적절히 설정
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedResponse);
        return {
          'userId': data['userId'],
          'nickname': data['nickname'],
        };
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await fetchUserInfo(widget.groupId);
      setState(() {
        _userId = userInfo['userId'];
        _nickname = userInfo['nickname'];
      });
    } catch (e) {
      print("Error loading user info: $e");
    }
  }

  Future<List<dynamic>> fetchChatMessages(int groupId) async {
    final url = Uri.parse('http://15.164.88.94:8080/groups/$groupId/chatting');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 토큰을 적절히 설정
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
      throw Exception('Error fetching chat messages: $e');
    }
  }

  Future<void> _loadChatMessages() async {
    try {
      final chatMessages = await fetchChatMessages(widget.groupId);
      for (var chatData in chatMessages) {
        _addMessageFromApi(chatData);
      }
    } catch (e) {
      print("Error loading chat messages: $e");
    }
  }

  void _addMessageFromApi(dynamic chatData) {
    ChatMessage message = ChatMessage(
      text: chatData['content'] ?? '',
      isMine: chatData['isMine'] ?? false,
      nickname: chatData['nickname'],
      profileImage: chatData['profileImage'],
      image: chatData['image'],
      createdDate: chatData['createdDate'] ?? '',
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

  Future<void> createChatMessage(
      int groupId, String content, File? imageFile) async {
    final url = Uri.parse('http://15.164.88.94:8080/groups/$groupId/chatting');

    // 이미지 파일을 Base64로 인코딩
    String? base64Image;
    if (imageFile != null) {
      final imageBytes = await imageFile.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    // JSON 데이터 생성
    final jsonData = jsonEncode({
      'content': content,
      'image': base64Image,
    });

    final headers = {
      'Authorization': 'Bearer $token', // 토큰을 적절히 설정
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: jsonData);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Chat message created successfully!');
        _textController.clear();
        setState(() {
          _isComposing = false;
          _imageFile = null; // 이미지 파일 초기화
        });
      } else {
        print(
            'Failed to create chat message. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error creating chat message: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });

    if (_nickname != null) {
      await createChatMessage(widget.groupId, text, _imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: const IconThemeData(color: Colors.blue),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _pickImage,
            ),
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: (text) {
                  if (_isComposing) {
                    _handleSubmitted(text);
                  }
                },
                decoration:
                    const InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isComposing
                  ? () => _handleSubmitted(_textController.text)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
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
  final AnimationController animationController;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isMine,
    this.nickname,
    this.profileImage,
    this.image,
    required this.createdDate,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            if (!isMine)
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundImage:
                      profileImage != null && profileImage!.isNotEmpty
                          ? NetworkImage(profileImage!)
                          : null,
                  child: profileImage == null || profileImage!.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  if (nickname != null)
                    Text(
                      nickname!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // 검정색으로 변경
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
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.black, // 검정색으로 변경
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        createdDate,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isMine) const SizedBox(width: 16.0),
          ],
        ),
      ),
    );
  }
}
