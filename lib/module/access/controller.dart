import 'package:flutter/foundation.dart';

import '../../entity/entity.dart';
import '../../entity/parking_fee_rule.dart';
import '../../entity/parking_session.dart';
import '../../entity/plate.dart';
import '../../entity/shopper.dart';
import '../../entity/gate.dart';
import '../../service/ocr.dart';
import '../../entity/parking_session_info.dart';

export '../../service/ocr.dart';

class AccessController{
  final Gate gate;
  Plate? plateNo;

  AccessController({required this.gate});

  Future<String?> logEntry(CameraImage image) async {
    return await _checkForPlate(image,true).then((Plate? plate)async{
      if(plate==null) return null;
      debugPrint('👤 Creating session for plate: $plate');
      await ParkingSession.put(plate:plate,gate:gate);
      return plate.toString();
    });
  }

  Future<SessionInfo?> logExit(CameraImage image) async {
    DateTime exitTime=DateTime.now();
    Plate? plate = await  _checkForPlate(image,false);
    if(plate==null) return null;
    debugPrint('🚪 EXIT GATE: Processing plate: $plate');
    Shopper? owner;bool ownerLoaded=false;
    plate.getShopper().then((shopper){owner=shopper;ownerLoaded=true;});
    final ParkingSession? session = await plate.getActiveSession();
    if (session == null) throw Exception('No active parking session found for $plate');
    debugPrint('✅ Found active session: ${session.id}');
    debugPrint('   userId: ${session.userId}, plate: ${session.vehiclePlateNumber}');
    await Future.doWhile(()=>!ownerLoaded);
    if (await session.isCompleted()) return SessionInfo.fromSession(session,owner);
    session.exitTimestamp=exitTime;
    session.markPending();
    session.update();
    if (owner==null) throw Exception('Parking fee cannot be automatically paid as its owner is not member.');
    try{await _feeProcessSequence(session,owner!);}
    catch (e) {debugPrint('❌ Parking fee cannot be automatically paid. Owner should pay parking fees at kiosk or counter.');rethrow;}
    session.markCompleted();
    session.update();
    return SessionInfo.fromSession(session,owner);
  }

  final OCRService _ocr=OCRService.get();

  Future<Plate?> _checkForPlate(CameraImage image,bool blockSame) async {
    try {
    Plate plate = Plate.parseText(await _ocr.extract(image));
    if (plate.toString().isEmpty) return null;
    if (blockSame&&plate.toString()==plateNo.toString()) return null;
    plateNo=plate;
    return plate;
    } catch (e) {switch (e) {
      case (NoTextFound _||UnknownFormat _): return null;
      default:rethrow;
  }}}

  Future<void> _feeProcessSequence(ParkingSession session,Shopper shopper) async {
    debugPrint('Handling parking fee collection...');
    ParkingFeeRuleEvaluator feeRuleEvaluator = MockParkingFeeRuleEvaluator();
    debugPrint('Calculating parking fee...');
    final decimal baseFee=await feeRuleEvaluator.apply(session,0);
    debugPrint('Base fee is $baseFee. Attempting payment...');
    final decimal finalFee=baseFee-session.totalDiscountAmount;
    if (finalFee<=0) {
      session.baseFee=baseFee;
      session.finalFee=finalFee;
      debugPrint('Fee is free. Handling complete.');
      return;
    }
    debugPrint('Payable fee is $finalFee. Attempting payment...');
    await (await shopper.getPaymentMethods()).settlePayment(finalFee);
    debugPrint('Payment of RM$finalFee successful. Handling complete.');
  }
}

