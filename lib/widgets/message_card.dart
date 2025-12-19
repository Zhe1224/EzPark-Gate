import 'package:flutter/material.dart';
import '../styles.dart';

import 'custom.dart';
import 'justified_text_pair.dart';

class MessageCard extends StatelessWidget {
  final Color color;
  final Widget symbol;
  final String line1Text;
  final String line2Text;

  const MessageCard({super.key, 
    required this.color,
    required this.symbol,
    required this.line1Text,
    required this.line2Text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: AppStyles.defaultPadding,
      child: Padding(
        padding: AppStyles.defaultPadding,
        child: Row(
          spacing:8,
          children: [
            CircleAvatar(
              backgroundColor: AppStyles.appBarColor,
              child: symbol,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(line1Text),
                CustomText(line2Text),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessCard extends StatelessWidget {
  final String plateNumber;
  final String hour;
  final String minute;
  final String second;
  final String gateName;

  const SuccessCard({super.key, 
    required this.plateNumber,
    required this.hour,
    required this.minute,
    required this.second,
    required this.gateName,
  });

  static String force2Digs(int num){return num>9?num.toString():"0${num.toString()}";}
  
  factory SuccessCard.make(String plateNumber,String gateName, int hour,int minute,int second){
    return SuccessCard(plateNumber: plateNumber, hour: force2Digs(hour), minute: force2Digs(minute), second: force2Digs(second), gateName: gateName);
  }

  @override
  Widget build(BuildContext context) {
    return MessageCard(
      color: AppStyles.confirmButtonColor, // Replace with your confirm color
      symbol: Icon(Icons.check, color: Colors.white), // Checkmark icon
      line1Text: plateNumber,
      line2Text: "$gateName at $hour:$minute:$second",
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String exceptionName;

  const ErrorCard({super.key, required this.exceptionName});

  @override
  Widget build(BuildContext context) {
    return MessageCard(
      color: AppStyles.seriousButtonColor, // Replace with your serious color
      symbol: Icon(Icons.close, color: Colors.white), // Cross icon
      line1Text: "Error!",
      line2Text: exceptionName,
    );
  }
}

class DetailsCard extends StatelessWidget {
  final int durationHour;
  final int durationMinute;
  final double baseFee;
  final double payable;
  final String shopper;

  const DetailsCard({super.key, 
    required this.durationHour,
    required this.durationMinute,
    required this.baseFee,
    required this.payable,
    required this.shopper,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppStyles.cardColor, // Card color
      margin: AppStyles.defaultPadding,
      child: Padding(
        padding: AppStyles.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JustifiedTextPair(left: "Duration:", right: "$durationHour hours $durationMinute minutes"),
            JustifiedTextPair(left: "Base fee:", right: "RM $baseFee"),
            JustifiedTextPair(left: "Payable:", right: "RM $payable"),
            JustifiedTextPair(left: "Member:", right: shopper),
          ],
        ),
      ),
    );
  }
}


