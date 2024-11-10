// To parse this JSON data, do
//
//     final infoPerson = infoPersonFromJson(jsonString);

import 'dart:convert';

List<InfoPerson> infoPersonFromJson(String str) =>
    List<InfoPerson>.from(json.decode(str).map((x) => InfoPerson.fromJson(x)));
String infoPersonToJson(List<InfoPerson> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InfoPerson {
  String codeP;
  String nameT;
  String lNameT;
  String nicknameE;
  String serviceName;
  String position;

  InfoPerson({
    required this.codeP,
    required this.nameT,
    required this.lNameT,
    required this.nicknameE,
    required this.serviceName,
    required this.position,
  });

  factory InfoPerson.fromJson(Map<String, dynamic> json) => InfoPerson(
        codeP: json["code_p"],
        nameT: json["Name_T"],
        lNameT: json["LName_T"],
        nicknameE: json["Nickname_E"],
        serviceName: json["Service_Name"],
        position: json["Position"],
      );

  Map<String, dynamic> toJson() => {
        "code_p": codeP,
        "Name_T": nameT,
        "LName_T": lNameT,
        "Nickname_E": nicknameE,
        "Service_Name": serviceName,
        "Position": position,
      };
}
