import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart'; // MIME 타입 가져오기
import 'package:http_parser/http_parser.dart';
import 'package:routine_ade/routine_user/token.dart';

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
    final message = ChatMessage(
      text: chatData['content'] ?? '',
      isMine: chatData['isMine'] ?? false,
      nickname: chatData['nickname'] ?? _nickname,
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

        print('Message sent successfully');

        await _loadChatMessages(); // Load new messages

        setState(() {
          _isComposing = false;
          _imageFile = null;
          _textController.clear();
        });
      } else {
        print(
            'Failed to create chat message. Status code: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print('Failed to send message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message.')),
      );
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
      await createChatMessage(widget.groupId, text, _imageFile);
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
      data: const IconThemeData(color: Color.fromARGB(255, 190, 226, 255)),
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
                    _isComposing = text.isNotEmpty || _imageFile != null;
                  });
                },
                decoration: const InputDecoration.collapsed(
                  hintText: "Send a message",
                ),
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
                crossAxisAlignment:
                    isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                        createdDate,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  if (isMine)
                    Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        createdDate,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
