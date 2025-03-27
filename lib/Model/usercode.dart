import 'dart:convert';

List<UserCode> userFromJson(String str) => List<UserCode>.from(json.decode(str).map((x) => UserCode.fromJson(x)));

String userToJson(List<UserCode> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserCode {
  UserCode({
    this.user_code,

   // this.password,


  });

  String? user_code;

  //String? password;


  factory UserCode.fromJson(Map<String, dynamic> json) => UserCode(
    user_code: json["compcode"],
       // name: json["full_name"],
   // mobile: json["mobile"],
   // password: json["password"],
    //  country:json["country"]
      );

  Map<String, dynamic> toJson() => {
        "compcode": user_code,

       // "password": password,



  };
}


