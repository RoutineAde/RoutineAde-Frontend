import 'package:flutter/material.dart';
import 'package:routine_ade/RoutineAdeIntro/ProfileSetting.dart';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';

class RoutineAde1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // Set the background color
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),  // Pushes content towards the center
            Image.asset(
              'assets/images/new-icons/RoutineAde.png',
              width: 100,  // Adjust width as needed
              height: 100,  // Adjust height as needed
            ),
            SizedBox(height: 20),  // Spacing between image and text
            Text(
              '더 나은 하루, 루틴 에이드',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '루틴으로 더 나은 일상을\n함께 관리해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Spacer(),  // Pushes content towards the center
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 150,  // Increased the size here
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSetting(),
                      ),
                    );
                  },
                  child: Image.asset(
                    "assets/images/new-icons/kakaoTalk.png",
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,  // Ensures the image fits properly within the constraints
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
