class UserA {
  UserA({
     this.name,
     this.username,
    required this.email,
    required this.password,
  });
 String? name;
 String? username;
  late final String email;
  late final String password;

  UserA.fromJson(Map<String, dynamic> json){
    name = json['name'];
    username = json['username'];
    email = json['email'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['username'] = username;
    _data['email'] = email;
    _data['password'] = password;
    return _data;
  }
}