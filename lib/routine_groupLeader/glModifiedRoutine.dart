import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class glModifiedRoutine extends StatefulWidget {
  const glModifiedRoutine({super.key});

  @override
  State<glModifiedRoutine> createState() => _glModifiedRoutineState();
}

class _glModifiedRoutineState extends State<glModifiedRoutine> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true; //텍스트를 가리는 초기 상태
  IconData _icon = Icons.visibility_off; // 초기 아이콘
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  int _selectedMemberCount = 0;

  //카테고리 선택 (한번에 하나만)
  int selectedCategoryIndex = -1;
  List<String> isCategory = ["일상", "건강", "자기개발", "자기관리", "기타"];

  @override
  void dispose() {
    _groupNameController.dispose();
    _passwordController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectMemberCount() async {
    final int? selectedCount = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '모집인원 선택',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: 29,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('${index + 2}명'),
                  onTap: () {
                    Navigator.of(context).pop(index + 2);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedCount != null) {
      setState(() {
        _selectedMemberCount = selectedCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: const Text(
            '그룹 수정',
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _groupNameController,
                      maxLength: 10,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: '그룹명을 입력해주세요',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15), // 세로 여백 조정
                        counterText: "", // 글자 수 표시 없애기
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Divider(),
                    TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      obscureText: _isObscured, // 텍스트가 가려지는지 여부 제어
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: '비밀번호(선택사항)',
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15), // 세로 여백 조정
                        suffixIcon: IconButton(
                          icon: Icon(
                              _icon), // Icon changes based on _isObscured state
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                              _icon = _isObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility;
                            });
                          },
                        ),
                      ),
                    ),
                    // SizedBox(height: 10),
                    Container(
                      color: Colors.white,
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      margin: const EdgeInsets.only(top: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Row(
                            children: [
                              Text(
                                "대표 카테고리",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              5,
                              (index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategoryIndex = index;
                                  });
                                },
                                child: Container(
                                  width: 70,
                                  height: 35,
                                  margin: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedCategoryIndex == index
                                        ? const Color(0xffE6E288)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isCategory[index],
                                    style: TextStyle(
                                      color: selectedCategoryIndex == index
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      margin: const EdgeInsets.only(top: 20),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "모집인원",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: _selectMemberCount,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '$_selectedMemberCount명',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //그룹 소개
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.only(
                    top: 20, bottom: 15, left: 10, right: 10),
                child: TextField(
                  controller: _groupDescriptionController,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: '그룹 소개를 입력해주세요',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              //루틴 추가 버튼
              Container(
                width: 400,
                height: 80,
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(const Color(0xffE6E288)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: const Text(
                    "수정 완료",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), //버튼 아래 여백
            ],
          ),
        ),
      ),
    );
  }
}
