

import 'package:parking_gate/entity/parking_session.dart';

import 'entity.dart';
import 'shopper.dart';

/*
class ParkingSession extends Data{
  ID vehicle;
  DateTime entryTimestamp;
  DateTime? exitTimestamp;
  decimal? baseFee;
  decimal? discountAmount;
  decimal? finalFee;
  bool paid;

  ParkingSession({
    super.id,
    required this.vehicle,
    required this.entryTimestamp,
    this.exitTimestamp,
    this.baseFee,
    this.discountAmount,
    this.finalFee,
    this.paid = false,
  });

  factory ParkingSession.fromJson(Item json) => ParkingSession(
    id:json.key,
    vehicle: json.value['vehicleID'],
    entryTimestamp: DateTime.parse(json.value['entryTimestamp']),
    exitTimestamp: DateTime.parse(json.value['exitTimestamp']),
    baseFee: json.value['baseFee'],
    discountAmount: json.value['discountAmount'],
    finalFee: json.value['finalFee'],
    paid: json.value['paymentStatus'] == 'paid',
  );
}*/

class SessionInfo {
  int durationHour;
  int durationMinute;
  decimal baseFee;
  decimal payable;
  String? user;
  String? plateNo;

  SessionInfo({
    this.plateNo,
    required this.durationHour,
    required this.durationMinute,
    required this.baseFee,
    required this.payable,
    this.user,
  });

  factory SessionInfo.fromSession(ParkingSession session,Shopper? shopper){
    return SessionInfo(
      plateNo: session.vehiclePlateNumber
    , durationHour: session.durationInHours.floor()
    , durationMinute: (session.durationMinutes??0)%60
    , baseFee: session.baseFee??0
    , payable: session.finalFee??0
    , user: shopper?.name ?? "-"
    );
  }
}