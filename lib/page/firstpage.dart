import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:flutter/widgets.dart' hide Image;

import '../model/model.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  TextEditingController _textFieldController = TextEditingController();
  List<String> _codeArray = [];
  List<String> _dropDown = [];
  List<InfoPerson> _infoList = [];
  ScrollController _scrollController = ScrollController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  void _Showdata() async {
    Timer(const Duration(seconds: 1), () {
      _btnController.success();
    });
    Timer(const Duration(seconds: 2), () {
      _btnController.reset();
      fetchData();
    });
  }

  String _getImagePath(String position, int index) {
    if (position == "Staff" || position == "Supervisor") {
      if (_dropDown[index] == "${_codeArray[index]}มากกว่า3ปี") {
        return "assets/images/3_year_up_CM.jpg";
      } else {
        return "assets/images/3_year_down_CM.jpg";
      }
    } else if (position == "Deputy Manager" ||
        position == "Manager" ||
        position == "Senior Manager") {
      if (_dropDown[index] == "${_codeArray[index]}มากกว่า3ปี") {
        return "assets/images/3_year_up_blue_CM.jpg";
      } else {
        return "assets/images/3_year_down_blue_CM.jpg";
      }
    } else if (position == "Deputy Director" || position == "Director") {
      if (_dropDown[index] == "${_codeArray[index]}มากกว่า3ปี") {
        return "assets/images/3_year_up_Green_CM.jpg";
      } else {
        return "assets/images/3_year_down_Green_CM.jpg";
      }
    } else if (position == "กรรมการผู้จัดการใหญ่" ||
        position == "Vice President" ||
        position == "President & Chief Executive Officer" ||
        position == "Chairman of Executive Board" ||
        position == "กรรมการรองผู้จัดการใหญ่") {
      if (_dropDown[index] == "${_codeArray[index]}มากกว่า3ปี") {
        return "assets/images/3_year_up_Orange_CM.jpg";
      } else {
        return "assets/images/3_year_down_Orange_CM.jpg";
      }
    } else {
      return "assets/images/default_image.jpg";
    }
  }

  String _getImagePathPrint(String position, int index) {
    if (position == "Staff" || position == "Supervisor") {
      if (_dropDown[index] == "${_codeArray[index]}มากกว่า3ปี") {
        return "assets/imgPrint/3_year_up_CM.jpg";
      } else {
        return "assets/imgPrint/3_year_down_CM.jpg";
      }
    } else if (position == "Deputy Manager" ||
        position == "Manager" ||
        position == "Senior Manager") {
      if (_dropDown[index] == "${_codeArray[index]}มากกว่า3ปี") {
        return "assets/imgPrint/3_year_up_blue_CM.jpg";
      } else {
        return "assets/imgPrint/3_year_down_blue_CM.jpg";
      }
    } else if (position == "Deputy Director" || position == "Director") {
      if (_dropDown[index] == "${_codeArray[index]}มากกว่า3ปี") {
        return "assets/imgPrint/3_year_up_Green_CM.jpg";
      } else {
        return "assets/imgPrint/3_year_down_Green_CM.jpg";
      }
    } else if (position == "กรรมการผู้จัดการใหญ่" ||
        position == "Vice President" ||
        position == "President & Chief Executive Officer" ||
        position == "Chairman of Executive Board" ||
        position == "กรรมการรองผู้จัดการใหญ่") {
      if (_dropDown[index] == "${_codeArray[index]}มากกว่า3ปี") {
        return "assets/imgPrint/3_year_up_Orange_CM.jpg";
      } else {
        return "assets/imgPrint/3_year_down_Orange_CM.jpg";
      }
    } else {
      return "assets/imgPrint/default_image.jpg";
    }
  }

  String _getBackImagePathPrint(String position, int index) {
    return "assets/imgPrint/backCM.jpg";
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  void addToCodeArray(String code) {
    if (code.isEmpty) {
      QuickAlert.show(
        width: 140,
        context: context,
        type: QuickAlertType.warning,
        title: 'เกิดข้อผิดพลาด',
        text: 'กรุณากรอกรหัสพนักงาน',
        confirmBtnText: 'ตกลง',
      );
      return;
    }

    if (_codeArray.length < 2 && _dropDown.length < 2) {
      if (!_codeArray.contains(code)) {
        setState(() {
          _codeArray.add(code);
          _dropDown.add("$codeน้อยกว่า3ปี");
        });
      } else {
        QuickAlert.show(
          width: 140,
          context: context,
          type: QuickAlertType.error,
          title: 'เกิดข้อผิดพลาด',
          text: 'รหัสพนักงานนี้มีอยู่ในรายการแล้ว',
          confirmBtnText: 'ตกลง',
        );
      }
    } else {
      QuickAlert.show(
        width: 140,
        context: context,
        type: QuickAlertType.error,
        title: 'เกิดข้อผิดพลาด',
        text: 'รายการเต็มแล้ว',
        confirmBtnText: 'ตกลง',
      );
    }
  }

  Future<void> fetchData() async {
    setState(() {
      _infoList.clear();
    });
    for (String code in _codeArray) {
      final url = Uri.parse(
          "http://172.2.200.14/application/personal_card_rfid/get_sql.php");
      final response = await http.post(
        url,
        body: {
          "mode": "staff_show",
          "code": code,
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        if (jsonData != null && jsonData is List) {
          List<InfoPerson> infoList = jsonData.map((item) {
            // Check and convert Service_Name and Position from null to empty string
            String service =
                item["Service_Name"] ?? ""; // If null, assign empty string ""
            String position =
                item["Position"] ?? ""; // If null, assign empty string ""

            return InfoPerson(
              codeP: item["code_p"],
              nameT: item["Name_T"],
              lNameT: item["LName_T"],
              nicknameE: item["Nickname_E"],
              serviceName: service, // Use the converted value
              position: position, // Use the converted value
            );
          }).toList();
          setState(() {
            _infoList.addAll(infoList);
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          });
        } else {
          QuickAlert.show(
            width: 140,
            context: context,
            type: QuickAlertType.error,
            title: 'เกิดข้อผิดพลาด',
            text: 'ไม่มีข้อมูลสำหรับรหัส $code ในระบบ',
            confirmBtnText: 'ตกลง',
          );
        }
      } else {
        throw Exception('Failed to fetch data from API');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/BGPC2.jpg"), // ใส่ตำแหน่งของรูปภาพพื้นหลังที่คุณต้องการใช้งาน
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 30, top: 20),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Personal ID Card",
                  style: TextStyle(
                    fontFamily: 'pf',
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(164, 245, 168, 213),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    margin: const EdgeInsets.only(top: 20, left: 15),
                    width: 280,
                    height: 150,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller: _textFieldController,
                            onSubmitted: (value) {
                              addToCodeArray(value);
                            },
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'ใส่รหัสพนักงาน',
                              hintStyle: TextStyle(
                                fontFamily: 'pf',
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            inputFormatters: [
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                return newValue.copyWith(
                                    text: newValue.text.toUpperCase());
                              })
                            ],
                            style: const TextStyle(
                              fontFamily:
                                  'pf', // กำหนดแบบอักษรของข้อความที่ป้อน
                              fontSize: 22, // กำหนดขนาดข้อความที่ป้อน
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // กำหนดสีข้อความที่ป้อน
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 40,
                            width: 90,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 237, 0, 140),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ), // ค่าของเลขในนี้จะเป็นความโค้งของวงกลม
                                ),
                              ),
                              onPressed: () {
                                addToCodeArray(_textFieldController.text);
                              },
                              child: const Text(
                                'เพิ่มข้อมูล',
                                style: TextStyle(
                                  fontFamily:
                                      'pf', // กำหนดแบบอักษรของข้อความที่ป้อน
                                  fontSize: 20, // กำหนดขนาดข้อความที่ป้อน
                                  color: Color.fromARGB(255, 255, 255,
                                      255), // กำหนดสีข้อความที่ป้อน
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 120),
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        height: 200,
                        width: 310,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(164, 245, 168, 213),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              for (int i = 0; i < _codeArray.length; i++)
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            const SizedBox(height: 5),
                                            Text(
                                              _codeArray[i],
                                              style: const TextStyle(
                                                fontFamily: 'pf',
                                                fontSize: 24,
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        DropdownButton<String>(
                                          value: _dropDown[i],
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _dropDown[i] = newValue!;
                                            });
                                          },
                                          items: [
                                            DropdownMenuItem<String>(
                                              value:
                                                  "${_codeArray[i]}น้อยกว่า3ปี",
                                              child: const Text(
                                                "น้อยกว่า3ปี",
                                                style: TextStyle(
                                                  fontFamily: 'pf',
                                                  fontSize: 20,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem<String>(
                                              value:
                                                  "${_codeArray[i]}มากกว่า3ปี",
                                              child: const Text(
                                                "มากกว่า3ปี",
                                                style: TextStyle(
                                                  fontFamily: 'pf',
                                                  fontSize: 20,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          children: [
                                            const SizedBox(height: 5),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 237, 0, 140),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: const Text(
                                                'ลบข้อมูล',
                                                style: TextStyle(
                                                  fontFamily: 'pf',
                                                  fontSize: 20,
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (i < _codeArray.length) {
                                                    _codeArray.removeAt(i);
                                                    _dropDown.removeAt(i);
                                                    if (i < _infoList.length) {
                                                      _infoList.removeAt(i);
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (i == 1) // เส้นสีขาวแสดงเมื่อ i เป็น 2
                                      Container(
                                        margin: const EdgeInsets.only(top: 25),
                                        width: 250,
                                        height: 1.5,
                                        color: const Color.fromARGB(
                                            255, 237, 0, 140),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 310,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(164, 245, 168, 213),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            RoundedLoadingButton(
                              color: const Color.fromARGB(255, 237, 0, 140),
                              width: 110,
                              controller: _btnController,
                              onPressed: _Showdata,
                              child: const Text(
                                'เตรียมข้อมูล',
                                style: TextStyle(
                                  fontFamily: 'pf',
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 100),
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        width: 775,
                        height: 420,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(164, 245, 168, 213),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: (_infoList.length / 2).ceil(),
                          itemBuilder: (context, index) {
                            final int firstIndex = index * 2;
                            final int secondIndex = firstIndex + 1;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 120),
                                  Row(
                                    children: [
                                      const SizedBox(width: 50),
                                      Expanded(
                                        child: _buildItem(firstIndex),
                                      ),
                                      const SizedBox(width: 50),
                                      Expanded(
                                        child: secondIndex < _infoList.length
                                            ? _buildItem(secondIndex)
                                            : Container(),
                                      ),
                                      const SizedBox(width: 50),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        width: 775,
                        height: 420,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(164, 245, 168, 213),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: (_infoList.length / 2).ceil(),
                          itemBuilder: (context, index) {
                            final int firstIndex = index * 2;
                            final int secondIndex = firstIndex + 1;
                            return Column(
                              children: [
                                const SizedBox(height: 120),
                                Row(
                                  children: [
                                    const SizedBox(width: 50),
                                    Expanded(
                                      child: _buildBackItem(firstIndex),
                                    ),
                                    const SizedBox(width: 50),
                                    Expanded(
                                      child: secondIndex < _infoList.length
                                          ? _buildBackItem(secondIndex)
                                          : Container(),
                                    ),
                                    const SizedBox(width: 50),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 60,
                        width: 120,
                        margin: const EdgeInsets.only(top: 200, left: 40),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 237, 0, 140),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // ค่าของเลขในนี้จะเป็นความโค้งของวงกลม
                            ),
                          ),
                          onPressed: () {
                            _print();
                          },
                          child: const Text(
                            'พิมพ์ด้านหน้า',
                            style: TextStyle(
                              fontFamily:
                                  'pf', // กำหนดแบบอักษรของข้อความที่ป้อน
                              fontSize: 22, // กำหนดขนาดข้อความที่ป้อน
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // กำหนดสีข้อความที่ป้อน
                            ),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 200)),
                      Container(
                        height: 60,
                        width: 120,
                        margin: const EdgeInsets.only(top: 200, left: 40),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 237, 0, 140),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // ค่าของเลขในนี้จะเป็นความโค้งของวงกลม
                            ),
                          ),
                          onPressed: () {
                            _printBack();
                          },
                          child: const Text(
                            'พิมพ์ด้านหลัง',
                            style: TextStyle(
                              fontFamily:
                                  'pf', // กำหนดแบบอักษรของข้อความที่ป้อน
                              fontSize: 22, // กำหนดขนาดข้อความที่ป้อน
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // กำหนดสีข้อความที่ป้อน
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _infoData = [];
  List<Uint8List> _imageBytes = [];
  List<Uint8List> _imageProfileBytes = [];
  pw.Font? DBSharp;

  Future<void> _fetchData() async {
    _infoData.clear();
    _imageBytes.clear();
    _imageProfileBytes.clear();
    DBSharp = pw.Font.ttf(await rootBundle.load("fonts/DBSharpX.ttf"));
    for (int i = 0; i < _infoList.length; i++) {
      final String position = _infoList[i].position;
      final String codeP = _infoList[i].codeP;
      try {
        final Uint8List imageByte = await _fetchImage(
          _getImagePathPrint(position, i),
        );
        final Uint8List? imageProfileByte = await _fetchImageBytes(
            "http://172.2.200.15/fos3/personpic/$codeP.jpg");

        if (imageByte.isNotEmpty && imageProfileByte!.isNotEmpty) {
          _imageBytes.add(imageByte);
          _imageProfileBytes.add(imageProfileByte);
          _infoData.add({
            "imageBytes": imageByte,
            "imageProfileBytes": imageProfileByte,
          });
        } else {
          // Show an error dialog if data is not found
          _showErrorDialog(context,
              "Data not found for position: $position and codeP: $codeP");
        }
      } catch (e) {
        // Show an error dialog if there's an error during image fetching
        _showErrorDialog(context,
            "Error fetching data for position: $position and codeP: $codeP");
        continue; // Skip this iteration and move to the next one
      }
    }
  }

  Future<void> _fetchBackData() async {
    _infoData.clear();
    _imageBytes.clear();
    _imageProfileBytes.clear();
    DBSharp = pw.Font.ttf(await rootBundle.load("fonts/DBSharpX.ttf"));
    for (int i = 0; i < _infoList.length; i++) {
      final String position = _infoList[i].position;
      final String codeP = _infoList[i].codeP;
      try {
        final Uint8List imageByte = await _fetchImage(
          _getBackImagePathPrint(position, i),
        );
        final Uint8List? imageProfileByte = await _fetchBackImageBytes(
            "http://172.2.200.15/fos3/personpic/$codeP.jpg");

        if (imageByte.isNotEmpty && imageProfileByte!.isNotEmpty) {
          _imageBytes.add(imageByte);
          _imageProfileBytes.add(imageProfileByte);
          _infoData.add({
            "imageBytes": imageByte,
            "imageProfileBytes": imageProfileByte,
          });
        } else {
          // Show an error dialog if data is not found
          _showErrorDialog(context,
              "Data not found for position: $position and codeP: $codeP");
        }
      } catch (e) {
        // Show an error dialog if there's an error during image fetching
        _showErrorDialog(context,
            "Error fetching data for position: $position and codeP: $codeP");
        continue; // Skip this iteration and move to the next one
      }
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  pw.Widget _buildWidget(int index) {
    return pw.Transform.rotate(
      angle: -90 * 3.14 / 180,
      child: pw.Stack(
        children: [
          pw.Container(
            width: 241,
            height: 156,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(5),
              image: pw.DecorationImage(
                image: pw.MemoryImage(_infoData[index]["imageBytes"], dpi: 800),
                fit: pw.BoxFit.cover,
              ),
              border: pw.Border.all(
                color: const PdfColor.fromInt(0xFF808080),
                width: 0.1,
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 100, //color: PdfColor.fromInt(0xFF808080),
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    margin: const pw.EdgeInsets.only(top: 120, right: 0),
                    child: pw.Text(
                      _infoList[index].codeP,
                      style: pw.TextStyle(font: DBSharp, fontSize: 24),
                    ),
                  ),
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 102, right: 15),
                      alignment: pw.Alignment.center,
                      //color: PdfColor.fromInt(0xFF808080),
                      width: 140,
                      child: pw.Text(
                        _infoList[index].position,
                        style: pw.TextStyle(font: DBSharp, fontSize: 14),
                      ),
                    ),
                    pw.Container(
                      margin: const pw.EdgeInsets.only(right: 15),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            alignment: pw.Alignment.centerRight,
                            //color: PdfColor.fromInt(0xFF808080),
                            width: 50,
                            child: pw.Text(
                              _infoList[index].nicknameE,
                              style: pw.TextStyle(font: DBSharp, fontSize: 15),
                            ),
                          ),
                          pw.SizedBox(
                            width: 5,
                          ),
                          pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            //color: PdfColor.fromInt(0xFF808080),
                            width: 80,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  _infoList[index].nameT,
                                  style: pw.TextStyle(
                                    font: DBSharp,
                                    fontSize: 14,
                                  ),
                                ),
                                pw.Text(
                                  _infoList[index].lNameT,
                                  style: pw.TextStyle(
                                    font: DBSharp,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Text(""),
                  ],
                ),
              ],
            ),
          ),
          pw.Positioned(
            child: pw.Row(
              children: [
                pw.Container(
                  width: 100,
                  height: 119,
                  decoration: pw.BoxDecoration(
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(5),
                    ),
                    image: pw.DecorationImage(
                      image: pw.MemoryImage(
                        _infoData[index]["imageProfileBytes"],
                      ),
                      fit: pw.BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBackWidget(int index) {
    return pw.Transform.rotate(
      angle: -90 * 3.14 / 180,
      child: pw.Stack(
        children: [
          pw.Container(
            width: 241,
            height: 156,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(5),
              image: pw.DecorationImage(
                image: pw.MemoryImage(_infoData[index]["imageBytes"]),
                fit: pw.BoxFit.cover,
              ),
              border: pw.Border.all(
                color: const PdfColor.fromInt(0xFF808080),
                width: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _print() async {
    await _fetchData();
    final doc = pw.Document();
    print("_infoData.length = ${_infoData.length}");
    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          21.1 * PdfPageFormat.cm,
          29.6 * PdfPageFormat.cm,
          marginTop: 0 * PdfPageFormat.cm,
          marginBottom: 0 * PdfPageFormat.cm,
          marginRight: 0 * PdfPageFormat.cm,
          marginLeft: 0 * PdfPageFormat.cm,
        ),
        build: (pw.Context context) {
          return pw.Container(
            child: pw.ListView.builder(
              itemCount: (_infoData.length / 2).ceil(),
              itemBuilder: (context, index) {
                final int firstIndex = index * 2;
                final int secondIndex = firstIndex + 1;
                return pw.Container(
                  child: pw.Column(
                    children: [
                      pw.SizedBox(height: 155),
                      pw.Row(
                        children: [
                          pw.SizedBox(width: 0),
                          if (firstIndex < _infoData.length)
                            pw.Row(
                              children: [
                                pw.Stack(
                                  overflow: pw.Overflow.visible,
                                  children: [
                                    pw.Container(
                                      child: pw.Text(
                                        'aaa',
                                        style: const pw.TextStyle(
                                          color: PdfColors.white,
                                        ),
                                      ),
                                    ),
                                    pw.Positioned(
                                      left: -12,
                                      top: 0,
                                      child: _buildWidget(firstIndex),
                                    ),
                                    if (secondIndex < _infoData.length)
                                      pw.Positioned(
                                        left: 200,
                                        top: 0,
                                        child: _buildWidget(secondIndex),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );

    // Print the document
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) => doc.save());
  }

  Future<void> _printBack() async {
    await _fetchBackData();
    final doc = pw.Document();
    print("_infoData.length = ${_infoData.length}");
    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          21.1 * PdfPageFormat.cm,
          29.6 * PdfPageFormat.cm,
          marginTop: 0 * PdfPageFormat.cm,
          marginBottom: 0 * PdfPageFormat.cm,
          marginRight: 0 * PdfPageFormat.cm,
          marginLeft: 0 * PdfPageFormat.cm,
        ),
        build: (pw.Context context) {
          return pw.Container(
            child: pw.ListView.builder(
              itemCount: (_infoData.length / 2).ceil(),
              itemBuilder: (context, index) {
                final int firstIndex = index * 2;
                final int secondIndex = firstIndex + 1;
                return pw.Container(
                  child: pw.Column(
                    children: [
                      pw.SizedBox(height: 155),
                      pw.Row(
                        children: [
                          pw.SizedBox(width: 0),
                          if (firstIndex < _infoData.length)
                            pw.Row(
                              children: [
                                pw.Stack(
                                  overflow: pw.Overflow.visible,
                                  children: [
                                    pw.Container(
                                      child: pw.Text(
                                        'aaa',
                                        style: const pw.TextStyle(
                                          color: PdfColors.white,
                                        ),
                                      ),
                                    ),
                                    pw.Positioned(
                                      left: -12,
                                      top: 0,
                                      child: _buildBackWidget(firstIndex),
                                    ),
                                    if (secondIndex < _infoData.length)
                                      pw.Positioned(
                                        left: 200,
                                        top: 0,
                                        child: _buildBackWidget(secondIndex),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );

    // Print the document
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) => doc.save());
  }

  Future<Uint8List?> _fetchImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return Uint8List(0);
    }
  }

  Future<Uint8List?> _fetchBackImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return Uint8List(0);
    }
  }

  Future<Uint8List> _fetchImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return Uint8List(0);
    }
  }

  Future<Uint8List> _fetchBackImage(String imageUrl) async {
    print('rrr $imageUrl');
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return Uint8List(0);
    }
  }

  Widget _buildItem(int index) {
    return Transform.rotate(
      angle: 90 * 3.14 / 180,
      child: Container(
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(
            image: AssetImage(_getImagePath(_infoList[index].position, index)),
            fit: BoxFit.fill,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  width: 130,
                  height: 137,
                  margin: const EdgeInsets.only(bottom: 0, right: 0.5),
                  child: CachedNetworkImage(
                    imageUrl:
                        'http://172.2.200.15/fos3/personpic/${_infoList[index].codeP}.jpg',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    imageBuilder: (context, imageProvider) => Container(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Image(
                            width: 130,
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: 126,
                  margin: const EdgeInsets.only(top: 5),
                  //color: Colors.amber,
                  child: Text(
                    _infoList[index].codeP,
                    style: const TextStyle(
                      fontFamily: 'pf',
                      fontSize: 30,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(),
            Container(
              margin: const EdgeInsets.only(top: 72),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 177,
                    //color: Colors.amber,
                    margin: const EdgeInsets.only(top: 45),
                    child: Text(
                      _infoList[index].position,
                      style: const TextStyle(
                        fontFamily: 'pf',
                        fontSize: 16,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          width: 66,
                          //color: Colors.amber,
                          child: Text(
                            _infoList[index].nicknameE,
                            style: const TextStyle(
                              fontFamily: 'pf',
                              fontSize: 19,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          alignment: Alignment.centerLeft,
                          width: 106,
                          //color: Colors.amber,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _infoList[index].nameT,
                                style: const TextStyle(
                                  fontFamily: 'pf',
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              Text(
                                _infoList[index].lNameT,
                                style: const TextStyle(
                                  fontFamily: 'pf',
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackItem(int index) {
    return Transform.rotate(
      angle: 90 * 3.14 / 180,
      child: Container(
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: const DecorationImage(
            image: AssetImage('assets/images/backCM.jpg'),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
