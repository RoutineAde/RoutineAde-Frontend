class Group { //그룹
  final String name;
  final DateTime creationDate;
  final String category;
  final int membersCount;
  final String leader;
  final String groupCode;

  Group({
    required this.name,
    required this.creationDate,
    required this.category,
    required this.membersCount,
    required this.leader,
    required this.groupCode,
  });
}
