
class UnitModel {
  String? id;
  String? pid;
  String? eid;
  String? tid;
  String? lid;
  String? tenant;
  String? price;
  String? deposit;
  String? room;
  String? floor;
  String? prepaid;
  String? accrual;
  String? status;
  String? title;
  String? time;
  String? checked;

  UnitModel({this.id,this.pid,this.eid,this.tid, this.lid,this.tenant, this.price, this.room, this.floor, this.prepaid, this.accrual, this.deposit , this.status ,this.title, this.time, this.checked = "false"});
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      pid: json['pid'] as String,
      eid: json['eid'] as String,
      tid: json['tid'] as String,
      lid: json['lid'] as String,
      status: json['status'] as String,
      price: json['price'] as String,
      deposit: json['deposit'] as String,
      room: json['room'] as String,
      floor: json['floor'] as String,
      title: json['title'] as String,
      time: json['time'] as String,
      checked: json['checked'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eid': eid,
      'pid': pid,
      'tid': tid,
      'lid': lid,
      'status': status,
      'price': price,
      'deposit': deposit,
      'room': room,
      'floor': floor,
      'title': title,
      'time': time,
      'checked': checked,
    };
  }
}