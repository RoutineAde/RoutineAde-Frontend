import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({Key? key}) : super(key: key);

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
          title: Text(
            '모집인원 선택',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
          ),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 20),
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
          title: Text(
            '그룹 만들기',
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _groupNameController,
                      maxLength: 10,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: '그룹명을 입력해주세요',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15), // 세로 여백 조정
                        counterText: "", // 글자 수 표시 없애기
                      ),
                    ),
                    SizedBox(height: 10),
                    // Divider(),
                    TextField(
                      controller: _passwordController,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: '비밀번호(선택사항)',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical:15), // 세로 여백 조정
                      ),
                    ),
                    // SizedBox(height: 10),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(left:10, right: 10, top: 10 ),
                margin: const EdgeInsets.only(top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
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
                    SizedBox(height: 10),
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
                            margin: EdgeInsets.only(
                              bottom: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selectedCategoryIndex == index
                                  ? Color(0xffE6E288)
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
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      margin: EdgeInsets.only(top: 20),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "모집인원",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: _selectMemberCount,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '$_selectedMemberCount명',
                          
                                style: TextStyle(
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
                padding: EdgeInsets.only(top: 20, bottom: 15, left: 10, right: 10),
                child: TextField(
                  controller: _groupDescriptionController,
                  maxLines: 6,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  decoration: InputDecoration(
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
                padding: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xffE6E288)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Text(
                    "루틴 추가하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), //버튼 아래 여백
            ],
          ),
        ),
      ),
    );
  }
}
