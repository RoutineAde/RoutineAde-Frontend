import 'dart:convert';

class Group {
  final int groupId;
  final String groupTitle;
  final String groupCategory;
  final String createdUserNickname;
  final int maxMemberCount;
  final int joinMemberCount;
  final int? joinDate;
  final bool isPublic;
  final String description;
  final String groupPassword;

  Group({
    required this.groupId,
    required this.groupTitle,
    required this.groupCategory,
    required this.createdUserNickname,
    required this.maxMemberCount,
    required this.joinMemberCount,
    this.joinDate,
    required this.isPublic,
    required this.description,
    required this.groupPassword,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['groupId'] ?? 0,
      groupTitle: json['groupTitle'] ?? '',
      groupCategory: json['groupCategory'] ?? '',
      createdUserNickname: json['createdUserNickname'] ?? '',
      maxMemberCount: json['maxMemberCount'] ?? 0,
      joinMemberCount: json['joinMemberCount'] ?? 0,
      joinDate: json['joinDate'],
      isPublic: json['isPublic'] ?? '',
      description: json['description'] ?? '',
      groupPassword: json['groupPassword'] ?? '',
    );
  }
}

class GroupMember {
  final String nickname;
  final String profileImage;

  GroupMember({required this.nickname, required this.profileImage});

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      nickname: json['nickname'],
      profileImage: json['profileImage'],
    );
  }
}

class GroupRoutine {
  final int routineId;
  final String routineTitle;
  final List<String> repeatDay;

  GroupRoutine({
    required this.routineId,
    required this.routineTitle,
    required this.repeatDay,
  });

  factory GroupRoutine.fromJson(Map<String, dynamic> json) {
    return GroupRoutine(
      routineId: json['routineId'] ?? 0,
      routineTitle: json['routineTitle'] ?? '',
      repeatDay: List<String>.from(json['repeatDay'] ?? []),
    );
  }
}

class RoutineCategory {
  final String routineCategory;
  final List<GroupRoutine> routines;

  RoutineCategory({
    required this.routineCategory,
    required this.routines,
  });

  factory RoutineCategory.fromJson(Map<String, dynamic> json) {
    return RoutineCategory(
      routineCategory: json['routineCategory'],
      routines: (json['routines'] as List)
          .map((routineJson) => GroupRoutine.fromJson(routineJson))
          .toList(),
    );
  }
}

class GroupResponse {
  final bool isGroupAdmin;
  final bool isGroupAlarmEnabled;
  final Group groupInfo;
  final List<GroupMember> groupMembers;
  final List<RoutineCategory> groupRoutines;

  GroupResponse({
    required this.isGroupAdmin,
    required this.isGroupAlarmEnabled,
    required this.groupInfo,
    required this.groupMembers,
    required this.groupRoutines,
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    return GroupResponse(
      isGroupAdmin: json['isGroupAdmin'],
      isGroupAlarmEnabled: json['isGroupAlarmEnabled'],
      groupInfo: Group.fromJson(json['groupInfo']),
      groupMembers: (json['groupMembers'] as List)
          .map((memberJson) => GroupMember.fromJson(memberJson))
          .toList(),
      groupRoutines: (json['groupRoutines'] as List)
          .map((routineCategoryJson) =>
              RoutineCategory.fromJson(routineCategoryJson))
          .toList(),
    );
  }
}
