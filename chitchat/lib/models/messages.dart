class Message {
  Message({
    required this.toId,
    required this.msg,
    required this.read,
    required this.fromId,
    required this.sent,
    required this.type,
  });
  late final String fromId;
  late final String toId;
  late final String msg;
  late final String sent;
  late final String read;
  late final Type type;

  Message.fromJson(Map<String, dynamic> json){
    fromId = json['fromId'].toString();
    toId = json['toId'].toString();
    msg = json['msg'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
    read = json['read'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fromId'] = fromId;
    data['toId'] = toId;
    data['msg'] = msg;
    data['type'] = type.name;
    data['sent'] = sent;
    data['read'] = read;
    return data;
  }
}
enum Type{text,image}