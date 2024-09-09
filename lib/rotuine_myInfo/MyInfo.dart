import 'package:flutter/material.dart';
import 'package:routine_ade/rotuine_myInfo/ProfileChange.dart';

import '../routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_statisrics/StaticsCalendar.dart';

class MyInfo extends StatelessWidget {
  const MyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8DCCFF),
        centerTitle: true,
        title: const Text(
          '내 정보',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // 뒤로가기 제거
        actions: <Widget>[
          IconButton(
            icon: Stack(
              children: [
                IconButton(
                  icon: Image.asset("assets/images/settings-cog.png"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileChange()),
                    );
                  },
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 70,
            ),
            // Profile Image
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://example.com/profile_image.jpg', // Add actual image URL or use AssetImage for local images
              ),
            ),
            const SizedBox(height: 80),

            // Nickname Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const ListTile(
                  title: Text('닉네임'),
                  trailing: Text('얄루'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Introduction Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const ListTile(
                  title: Text('한 줄 소개'),
                  subtitle: Text('다양한 루틴을 수행하는 루틴이입니다'),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  // Bottom AppBar widget
  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomAppBarItem(
              context, "assets/images/tap-bar/routine01.png"),
          _buildBottomAppBarItem(context, "assets/images/tap-bar/group01.png",
              const GroupMainPage()),
          _buildBottomAppBarItem(
              context,
              "assets/images/tap-bar/statistics01.png",
              const StaticsCalendar()),
          _buildBottomAppBarItem(context, "assets/images/tap-bar/more02.png",
              const MyInfo()), // Current page
        ],
      ),
    );
  }

  // Helper function to create a Bottom App Bar Item
  Widget _buildBottomAppBarItem(BuildContext context, String asset,
      [Widget? page]) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        }
      },
      child: SizedBox(
        width: 60,
        height: 60,
        child: Image.asset(asset),
      ),
    );
  }
}
