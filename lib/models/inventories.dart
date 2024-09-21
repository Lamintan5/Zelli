class InventModel {
  String iid;
  String? eid;
  String? pid;
  String? name;
  String? category;
  String? quantity;
  String? volume;
  String? supplier;
  String? buying;
  String? selling;
  String? ivalue;
  String? svalue;
  String? time;
  bool isChecked;

  InventModel({required this.iid, this.eid, this.pid, this.name, this.category, this.quantity, this.volume, this.supplier,this.buying,this.selling,this.ivalue,this.svalue, this.time,this.isChecked = false});

  factory InventModel.fromJson(Map<String, dynamic> json) {
    return InventModel(
      iid: json['iid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as String,
      volume: json['volume'] as String,
      supplier: json['supplier'] as String,
      buying: json['buying'] as String,
      selling: json['selling'] as String,
      ivalue: json['ivalue'] as String,
      svalue: json['svalue'] as String,
      time: json['time'] as String,
    );
  }
}