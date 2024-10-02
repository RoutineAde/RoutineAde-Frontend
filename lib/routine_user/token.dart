import 'package:shared_preferences/shared_preferences.dart';

String token =
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3Mjc2NzcxMDgsImV4cCI6MTc0MzIyOTEwOCwidXNlcklkIjoxfQ.zp_T75qssNeY9wIVTdOqDeyZiDq735SN7ApJxe8bQmM';

//테스트계정1
// eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3Mjc2NzcxMDgsImV4cCI6MTc0MzIyOTEwOCwidXNlcklkIjoxfQ.zp_T75qssNeY9wIVTdOqDeyZiDq735SN7ApJxe8bQmM
// 2
// eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw
class TokenManager {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance(); //토큰 저장
    await prefs.setString('authToken', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance(); //토큰 불러오기
    return prefs.getString('authToken');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance(); //토큰 삭제
    await prefs.remove('authToken');
  }
}
