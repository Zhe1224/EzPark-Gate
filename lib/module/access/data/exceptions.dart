

class TraceableException implements Exception {
  String name() => "Traceable Exception"; 
  Object? reason; 
  TraceableException({this.reason});
  
  @override
  String toString() {
    return "$name because $reason";
  }
}

class NoActiveSession extends TraceableException {
  NoActiveSession({super.reason});
  
  @override
  String name() => "No Active Session";
}

class FetchParkingRatesFail extends TraceableException {
  FetchParkingRatesFail({super.reason});
  
  @override
  String name() => "Fetch Parking Rates Failed";
}

class NoPayerRegistered extends TraceableException {
  NoPayerRegistered({super.reason});
  
  @override
  String name() => "No Payer Registered";
}

class AutoPayNotEnabled extends TraceableException {
  AutoPayNotEnabled({super.reason});
  
  @override
  String name() => "AutoPay Not Enabled";
}

class FetchDiscountsFail extends TraceableException {
  FetchDiscountsFail({super.reason});
  
  @override
  String name() => "Fetch Discounts Failed";
}

class MarkSessionPaidFail extends TraceableException {
  MarkSessionPaidFail({super.reason});
  
  @override
  String name() => "Mark Session Paid Failed";
}

class AutomaticPaymentFail extends TraceableException {
  AutomaticPaymentFail({super.reason});
  
  @override
  String name() => "Automatic Payment Failed";
}

class OngoingSession extends TraceableException {
  OngoingSession({super.reason});
  
  @override
  String name() => "Ongoing Session";
}

class FetchOwnerFail extends TraceableException {
  FetchOwnerFail({super.reason});
  
  @override
  String name() => "Fetch Owner Failed";
}

class FetchSessionFail extends TraceableException {
  FetchSessionFail({super.reason});
  
  @override
  String name() => "Fetch Session Failed";
}

class FetchDiscountEventsFail extends TraceableException {
  FetchDiscountEventsFail({super.reason});
  
  @override
  String name() => "Fetch Discount Events Failed";
}

class LogEntryFail extends TraceableException {
  LogEntryFail({super.reason});
  @override
  String name() => "Log Entry Failed";
}

class LogExitFail extends TraceableException {
  LogExitFail({super.reason});
  @override
  String name() => "Log Exit Failed";
}