class ChatsModel{
  String cid;
  String? title;
  String? type;
  String? time;

  ChatsModel({required this.cid, this.title, this.time, this.type});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatsModel && runtimeType == other.runtimeType && cid == other.cid;

  @override
  int get hashCode => cid.hashCode;

  factory ChatsModel.fromJson(Map<String, dynamic> json) {
    return ChatsModel(
      cid: json['cid'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      time: json['time'] as String,
    );
  }
  Map<String, dynamic> toJsonAdd() {
    return {
      'cid': cid,
      'title': title,
      'type': type,
      'time': time,
    };
  }
}