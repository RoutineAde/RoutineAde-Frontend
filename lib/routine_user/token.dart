import 'package:shared_preferences/shared_preferences.dart';

// String token =
//     'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw';
// //테스트계정2

String token = '';

class TokenManager {
  // 토큰을 저장하고 전역 변수 업데이트
  static Future<void> saveToken(String newToken) async {
    final prefs =
        await SharedPreferences.getInstance(); // SharedPreferences에 저장
    await prefs.setString('authToken', newToken);

    token = newToken; // 전역 변수 업데이트
  }

  // 저장된 토큰을 불러오고 전역 변수 업데이트
  static Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance(); // SharedPreferences에서 불러오기
    String? storedToken = prefs.getString('authToken');

    if (storedToken != null) {
      token = storedToken; // 전역 변수 업데이트
    }

    return storedToken;
  }

  // 토큰을 삭제
  static Future<void> clearToken() async {
    final prefs =
        await SharedPreferences.getInstance(); // SharedPreferences에서 삭제
    await prefs.remove('authToken');
    token = ''; // 전역 변수 초기화
  }
}
