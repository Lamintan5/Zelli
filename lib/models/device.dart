class DeviceModel {
  String? id;
  String? onesignalId;
  String? type;
  String? token;
  bool? enabled;
  int? notification_types;
  int? session_time;
  int? session_count;
  String? sdk;
  String? device_model;
  String? device_os;
  String? app_version;
  int? net_type;
  String? carrier;
  String? language;
  String? timezone_id;
  String? country;
  int? first_active;
  int? last_active;
  String? ip;

  DeviceModel({
     this.id, this.onesignalId, this.type, this.token,  this.enabled, this.notification_types, this.session_time,
     this.session_count, this.sdk, this.device_model, this.device_os, this.app_version, this.net_type, this.carrier,
     this.language, this.timezone_id, this.country, this.first_active, this.last_active, this.ip
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      onesignalId: json['onesignalId'] as String,
      type: json['type'] as String,
      token: json['token'] as String,
      enabled: json['enabled'] as bool,
      notification_types: json['notification_types'] as int,
      session_time: json['session_time'] as int,
      session_count: json['session_count'] as int,
      sdk: json['sdk'] as String,
      device_model: json['device_model'] as String,
      device_os: json['device_os'] as String,
      app_version: json['app_version'] as String,
      net_type: json['net_type'] as int,
      carrier: json['carrier'] as String,
      language: json['language'] as String,
      timezone_id: json['timezone_id'] as String,
      country: json['country'] as String,
      first_active: json['first_active'] as int,
      last_active: json['last_active'] as int,
      ip: json['ip'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'onesignalId': onesignalId,
      'type': type,
      'token': token,
      'enabled': enabled,
      'notification_types': notification_types,
      'session_count': session_count,
      'session_time': session_time,
      'sdk': sdk,
      'device_model': device_model,
      'device_os': device_os,
      'app_version': app_version,
      'net_type': net_type,
      'carrier': carrier,
      'language': language,
      'timezone_id': timezone_id,
      'country': country,
      'first_active': first_active,
      'last_active': last_active,
      'ip': ip,
    };
  }
}