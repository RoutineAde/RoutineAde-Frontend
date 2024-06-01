import 'dart:convert';
import 'package:routine_ade/models/api_response.dart';
import 'package:routine_ade/models/routines_for_listing.dart';
import 'package:http/http.dart' as http;

class RoutinesService {
  static const API = 'http://15.164.88.94:8080';

  Future<APIResponse<List<RoutinesForListing>>> getRoutinesList() async {
    final response = await http.get(Uri.parse('$API/routines'));

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body) as List;
        final routines = jsonData
            .map((item) => RoutinesForListing(
                  routineId: item['routineId'],
                  routineTitle: item['routineTitle'],
                  routineCategory: item['routineCategory'],
                  isAlarmEnabled: item['isAlarmEnabled'],
                ))
            .toList();
        return APIResponse<List<RoutinesForListing>>(data: routines);
      } catch (e) {
        return APIResponse<List<RoutinesForListing>>(
          error: true,
          errorMessage: '응답을 파싱하는 동안 오류가 발생했습니다',
        );
      }
    } else {
      return APIResponse<List<RoutinesForListing>>(
        error: true,
        errorMessage: '오류가 발생했습니다: ${response.statusCode}',
      );
    }
  }
}
