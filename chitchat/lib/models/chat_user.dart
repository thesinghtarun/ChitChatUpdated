class ChatUser {
  ChatUser({
    required this.id,
    required this.lastActive,
    required this.image,
    required this.name,
    required this.email,
    required this.pushToken,
    required this.createdAt,
    required this.isOnline,
    required this.about,
  });
  late  String id;
  late  String lastActive;
  late  String image;
  late  String name;
  late  String email;
  late  String pushToken;
  late  String createdAt;
  late  bool isOnline;
  late  String about;

  ChatUser.fromJson(Map<String, dynamic> json){
    id = json['id']??'';
    lastActive = json['last_active']??'';
    image = json['image']??'';
    name = json['name']??'';
    email = json['email']??'';
    pushToken = json['push_token']??'';
    createdAt = json['created_at']??'';
    isOnline = json['is_online']??'';
    about = json['about']??'';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['last_active'] = lastActive;
    data['image'] = image;
    data['name'] = name;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['about'] = about;
    return data;
  }
}