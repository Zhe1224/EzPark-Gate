import 'entity.dart';
import 'parking_session.dart';

class ParkingFeeRuleEvaluator{
  bool loaded=false;
  Iterable<ParkingFeeRule>? rules;
  ParkingFeeRuleEvaluator(){load();}
  void load()async{
    rules=(await Model.database.collection("parking_rates").orderBy('priority',descending:true).get()).docs.map((rule){
      throw UnimplementedError('rule factory not implemented');
      //TODO
    /* return ParkingFeeRule(); */});
    loaded=true;
  }
  Future<decimal> apply(ParkingSession session,decimal amount) async {
    await Future.doWhile(()=>!loaded);
    decimal fee=amount;
    for (var rule in rules!) {
      fee=rule.apply(session,fee);
      if (rule.applied && rule.terminator) break;
    }
    return fee;
  }
}

class MockParkingFeeRuleEvaluator extends ParkingFeeRuleEvaluator{
  @override
  void load() {
    rules=[HourlyCharge()];
    loaded=true;
  }
}

abstract class ParkingFeeRule{
  Duration? minDuration;
  Duration? maxDuration;
  int priority=0;
  bool terminator=false;
  bool applied=false;
  decimal apply(ParkingSession session,decimal amount);
}

class HourlyCharge extends ParkingFeeRule{
  decimal rate=1;
  @override
  decimal apply(ParkingSession session,decimal amount) {
    if ((minDuration!=null && session.durationInHours < minDuration!.inHours)||(maxDuration!=null && session.durationInHours > maxDuration!.inHours)) return amount;
    applied=true;
    return amount + (rate*session.durationInHours);
  }
}