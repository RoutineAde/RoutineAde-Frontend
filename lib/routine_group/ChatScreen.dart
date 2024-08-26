import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// void main() => runApp(FriendlychatApp());
//
// class FriendlychatApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '꿈을 향해',
//       home: ChatScreen(),
//     );
//   }
// }

class ChatScreen extends StatefulWidget {
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  late final int groupId;  // 그룹 ID를 설정

  @override
  void initState() {
    super.initState();
    _fetchChatMessages(); // 초기화 시 채팅 메시지 불러오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (_, index) => _messages[index],
              ),
            ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _buildTextComposer(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Colors.blue),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.photo),
              onPressed: () {
                // 이미지 추가 기능을 넣을 곳
              },
            ),
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration:
                InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                child: Text("send"),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)
                    : null,
              )
                  : IconButton(
                icon: Icon(Icons.send),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });

    String userNickname = "사용자닉네임"; // 실제 닉네임을 여기에 설정
    String profileImage = "default.png"; // 기본 프로필 이미지

    ChatMessage message = ChatMessage(
      content: text,
      nickname: userNickname,
      profileImagePath: profileImage,
      isMine: true,  // 사용자가 보낸 메시지는 isMine이 true
      createdDate: DateTime.now().toString(), // 현재 시간
      animationController: AnimationController(
        duration: Duration(milliseconds: 700),
        vsync: this,
      ),
    );

    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();

    await _sendMessageToServer(text, null); // 이미지는 null로 처리
  }

  Future<void> _sendMessageToServer(String content, String? image) async {
    final String url = "http://15.164.88.94:8080/groups/$groupId/chatting";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "content": content,
          "image": image ?? "",  // 이미지가 없으면 빈 문자열을 보냄
        }),
      );

      if (response.statusCode == 201) {
        print('Message sent successfully');
      } else {
        print('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while sending message: $e');
    }
  }

  Future<void> _fetchChatMessages() async {
    final String url = "http://15.164.88.94:8080/groups/$groupId/chatting";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<groupChatting> messages = jsonResponse
            .map((data) => groupChatting.fromJson(data))
            .toList();

        setState(() {
          _messages.addAll(messages.map((groupChatting) => ChatMessage(
            content: groupChatting.content,
            image: groupChatting.image,  // 이미지도 추가
            nickname: groupChatting.nickname,
            profileImagePath: groupChatting.profileImage,
            createdDate: groupChatting.createdDate,
            isMine: groupChatting.isMine,
            animationController: AnimationController(
              duration: Duration(milliseconds: 700),
              vsync: this,
            )..forward(),
          )));
        });
      } else {
        print('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching messages: $e');
    }
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}

// 리스브뷰에 추가될 메시지 위젯
class ChatMessage extends StatelessWidget {
  final String content;
  final String? image;
  final String nickname;
  final String profileImagePath;
  final String createdDate;
  final bool isMine;  // isMine에 따라 레이아웃 변경
  final AnimationController animationController;

  ChatMessage({
    required this.content,
    this.image,
    required this.nickname,
    required this.profileImagePath,
    required this.createdDate,
    required this.isMine,
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
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              createdDate,
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (!isMine) _buildProfileImage(),  // 상대방 메시지는 왼쪽에 프로필 이미지
                Expanded(
                  child: Column(
                    crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(nickname),  // 닉네임 표시
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: image != null && image!.isNotEmpty
                            ? Image.network(image!)  // 이미지가 있을 경우 표시
                            : Text(content),  // 이미지가 없으면 텍스트 표시
                      ),
                    ],
                  ),
                ),
                if (isMine) _buildProfileImage(),  // 내 메시지는 오른쪽에 프로필 이미지
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      margin: const EdgeInsets.only(right: 16.0, left: 16.0),
      child: CircleAvatar(
        backgroundImage: AssetImage("assets/images/profile/$profileImagePath"),
      ),
    );
  }
}

class groupChatting {
  final bool isMine;
  final int userId;
  final String nickname;
  final String profileImage;
  final String content;
  final String image;
  final String createdDate;

  groupChatting({
    required this.isMine,
    required this.userId,
    required this.nickname,
    required this.profileImage,
    required this.content,
    required this.image,
    required this.createdDate,
  });

  factory groupChatting.fromJson(Map<String, dynamic> json) {
    return groupChatting(
      isMine: json['isMine'] ?? true,
      userId: json['userId'] ?? 0,
      nickname: json['nickname'] ?? '',
      profileImage: json['profileImage'] ?? 'default.png',
      content: json['content'] ?? '',
      image: json['image'] ?? '',
      createdDate: json['createdDate'] ?? '',
    );
  }
}
