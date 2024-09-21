
import 'anual_individual_bar.dart';

class BarData {
  final double jan;
  final double feb;
  final double march;
  final double april;
  final double may;
  final double june;
  final double jully;
  final double agust;
  final double sep;
  final double oct;
  final double nov;
  final double dec;

  BarData({
    required this.jan,
    required this.feb,
    required this.march,
    required this.april,
    required this.may,
    required this.june,
    required this.jully,
    required this.agust,
    required this.sep,
    required this.oct,
    required this.nov,
    required this.dec
  });

  List<AnnualIndividualBar> barData = [];

  void initializeBarData(){
   barData = [
     AnnualIndividualBar(0, jan),
     AnnualIndividualBar(1, feb),
     AnnualIndividualBar(2, march),
     AnnualIndividualBar(3, april),
     AnnualIndividualBar(4, may),
     AnnualIndividualBar(5, june),
     AnnualIndividualBar(6, jully),
     AnnualIndividualBar(7, agust),
     AnnualIndividualBar(8, sep),
     AnnualIndividualBar(9, oct),
     AnnualIndividualBar(10, nov),
     AnnualIndividualBar(11, dec),
   ];
  }
}