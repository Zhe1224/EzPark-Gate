import 'data.dart';

class MockDatabase implements Database {
  // Simulated in-memory data storage
  final Map<String, Items> _dataStore = {
    'discount_events': {},
    'parking_rates': {},
    'payment_methods': {
      '1':{'userID':'JohnCena','fallback':'2','type':'card','token':'69420','created':DateTime.now().toIso8601String()}
      ,'2':{'userID':'JohnCena','fallback':null,'type':'wallet','token':'114514','created':DateTime.now().toIso8601String()}
      ,'3':{'userID':'JohnCena','fallback':'1','type':'wallet','token':'1919810','created':DateTime.now().toIso8601String()}
    },
    'users': {
      'JohnCena':{'email':'john@ce.na','useAutoPay':'no'}
    },
    'vehicles': {
      'vehicle_5678':{'userID':'JohnCena','carPlate':'ABC 1234'}
    },
    'parking_session': {
      'session_1234': {
        'vehicleID': 'vehicle_5678',
        'entryTimestamp': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
        'exitTimestamp': null, // Assuming it hasn't exited yet
        'baseFee': 10.0, // Base fee in currency (e.g., dollars)
        'discountAmount': 2.0, // Amount deducted from the base fee
        'finalFee': 8.0, // Total fee after discount
        'paymentStatus': 'paid' // Change to 'paid' if payment has been made
      }
    },
    'cameras': {
      'ca@me.ra':{'name':'ca@me.ra'}
    },
    'vouchers': {},
    'apiKey': {
      'stripe': {'value': 'mock_api_key_1234'},
    },
  };

  @override
  Future<Items> getDiscountEvents() async => await _getAllItems('discount_events');

  @override
  Future<Items> getParkingRates() async => await _getAllItems('parking_rates');

  @override
  Future<Items> getPaymentMethods(ID shopper) async =>
      await _getItems('payment_methods', 'userID', shopper);

  @override
  Future<Item?> getVehicleOwner(ID vehicle) async {
    try {
      final vehicleData = await _getItem('vehicles', vehicle);
      return await _getItem('users', vehicleData['userID']);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Item> getActiveSession(String plateNo) async {
    final vehicleID = await _getVehicleID(plateNo);
    final sessions = _dataStore['parking_session']!.entries
        .where(
          (session) =>
              session.value['vehicleID'] == vehicleID &&
              session.value['exitTimestamp'] == null,
        )
        .toList();
    if (sessions.isNotEmpty) {
      return sessions.first;
    } else {
      throw ItemNotFound();
    }
  }

  @override
  Future<DateTime> logEntryTime(String plateNo) async {
    final vehicleID = await _getVehicleID(plateNo);
    final entryTimestamp = DateTime.now();
    _dataStore['parking_session']![entryTimestamp.toString()] = {
      'vehicleID': vehicleID,
      'entryTimestamp': entryTimestamp,
      'paymentStatus': 'unpaid',
      'exitTimestamp': null,
    };
    return entryTimestamp;
  }

  @override
  Future logParkingExitTime(ID session, DateTime time) async {
    _dataStore['parking_session']![session.toString()]!['exitTimestamp'] = time;
  }

  @override
  Future markPaymentSessionAsPaid(ID session) async {
    _dataStore['parking_session']![session.toString()]!['paymentStatus'] =
        'paid';
  }

  // Retrieve vehicle by plate number
  Future _getVehicleByPlateNum(String plateNo) async {
    final vehicles = _dataStore['vehicles']!.values
        .where((v) => v['carPlate'] == plateNo)
        .toList();
    if (vehicles.isNotEmpty) {
      return vehicles.first;
    }
    throw ItemNotFound();
  }

  Future _getVehicleID(String plateNo) async =>
      (await _getVehicleByPlateNum(plateNo))['id'];

  Future _getItem(String collection, ID key) async {
    final item = _dataStore[collection]![key.toString()];
    if (item == null) throw ItemNotFound();
    return item;
  }

  Future _getAllItems(String collection) async {
    return _dataStore[collection]!;
  }

  Future _getItems(String collection, ID key, Object value) async {
    final items = _dataStore[collection]!.values
        .where((item) => item[key] == value)
        .toList();
    return {for (var item in items) item['id']: item};
  }

  Future getGate(String username) async {
    final gates = await _getItems('cameras', 'name', username);
    return gates.entries.first;
  }

  Future getShopper(String email) async {
    final shoppers = await _getItems('users', 'email', email);
    return shoppers.entries.first;
  }

  @override
  Future<String> getKey() async {
    return (await _getItem('apiKey', 'stripe'))['value'];
  }

  @override
  Future disableAutoPay(ID user) async {
    _dataStore['users']![user.toString()]!['useAutoPay'] = 'no';
  }

    @override
  Future<void> enableAutoPay(ID user) async {
    _dataStore['users']![user.toString()]!['useAutoPay'] = 'yes';
  }

  @override
  Future<ID> newMethod(Item method) async {
    final newId = DateTime.now().toString(); // Generate a simple unique ID
    _dataStore['payment_methods']![newId] = method.value;
    return newId;
  }

  Future<void> updatePaymentMethod(Item method) async {
    final id = method.value['id'].toString();
    if (_dataStore['payment_methods']!.containsKey(id)) {
      _dataStore['payment_methods']![id] = method.value;
    } else {
      throw ItemNotFound();
    }
  }

  @override
  Future<void> removePaymentMethod(ID method) async {
    _dataStore['payment_methods']!.remove(method.toString());
  }

  @override
  Future<void> swapMethods(ID toBack, ID? toBackFallback, ID toFront, ID? toFrontFallback) async {
    // Perform swaps in the mock database
    final toBackData = _dataStore['payment_methods']![toBack.toString()];
    final toFrontData = _dataStore['payment_methods']![toFront.toString()];

    _dataStore['payment_methods']![toBack.toString()] = {toFront:toFrontData};
    _dataStore['payment_methods']![toFront.toString()] = {toBack:toBackData};

    if (toBackFallback != null) {
      _dataStore['payment_methods']![toBackFallback.toString()]!['fallback'] = toBack;
    }
    _dataStore['payment_methods']![toBack.toString()]!['fallback'] = toFrontFallback;
      if (toFrontFallback != null) {
      _dataStore['payment_methods']![toFrontFallback.toString()]!['fallback'] = toBack;
    }
  }

  @override
  Future<Item> getAppliedVoucher(ID session) async {
    final vouchers = await _getItems('vouchers', 'parkingSessionId', session);
    return vouchers.entries.first;
  }

  @override
  Future<void> confirmGate(String loginID) async {
    await getGate(loginID);
  }

  @override
  Future<void> confirmShopper(String loginID) async {
    await getShopper(loginID);
  }

  @override
  Future<String> getPaymentAPIKey() async {
    return (await _getItem('apiKey', 'stripe'))['value'];
  }
  
  @override
  Future<void> replaceWithFallback(ID method, ID fallback) {
    // TODO: implement replaceWithFallback
    throw UnimplementedError();
  }
  
  @override
  Future<void> setFallback(ID method, ID fallback) async{
    _dataStore['payment_methods']![method.toString()]!['fallback']= fallback.toString();
  }
}