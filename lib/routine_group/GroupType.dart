class Group {
  final int groupId;
  final String groupTitle;
  final String groupCategory;
  final String createdUserNickname;
  final int maxMemberCount;
  final int joinMemberCount;
  final int joinDate;
  final bool isPublic;

  Group({
    required this.groupId,
    required this.groupTitle,
    required this.groupCategory,
    required this.createdUserNickname,
    required this.maxMemberCount,
    required this.joinMemberCount,
    required this.joinDate,
    required this.isPublic,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['groupId'],
      groupTitle: json['groupTitle'],
      groupCategory: json['groupCategory'],
      createdUserNickname: json['createdUserNickname'],
      maxMemberCount: json['maxMemberCount'],
      joinMemberCount: json['joinMemberCount'],
      joinDate: json['joinDate'],
      isPublic: json['isPublic'],
    );
  }
}
