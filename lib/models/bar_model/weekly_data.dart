import 'individual_bar.dart';

class WeeklyData {
  final double mon;
  final double tue;
  final double wed;
  final double thr;
  final double fri;
  final double sat;
  final double sun;

  final double mon2;
  final double tue2;
  final double wed2;
  final double thr2;
  final double fri2;
  final double sat2;
  final double sun2;

  WeeklyData({
    required this.mon,
    required this.tue,
    required this.wed,
    required this.thr,
    required this.fri,
    required this.sat,
    required this.sun,
    required this.mon2,
    required this.tue2,
    required this.wed2,
    required this.thr2,
    required this.fri2,
    required this.sat2,
    required this.sun2,
  });

  List<IndividualBar> weeklyData = [];

  void initializeBarData(){
    weeklyData = [
      IndividualBar(0, mon, mon2),
      IndividualBar(1, tue, tue2),
      IndividualBar(2, wed, wed2),
      IndividualBar(3, thr, thr2),
      IndividualBar(4, fri, fri2),
      IndividualBar(5, sat, sat2),
      IndividualBar(6, sun, sun2),
    ];
  }
}