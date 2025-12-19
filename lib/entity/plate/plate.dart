import 'package:flutter/foundation.dart';

import '../entity.dart';
import '../parking_session.dart';
import '../shopper.dart';
import 'standard.dart';

class UnknownFormat implements Exception{}

///Data class
abstract class Plate{
  @override String toString();
  Plate();

  ///Purpose: 
  ///Determine if a given text is a valid plate number.
  factory Plate.parseText(String input) {
    // Logic to determine which plate format to use
    // You'll implement specific regex patterns or conditional logic based on formats
    // For example, if different formats are based on length or certain characters

    if (_isStandardPlate(input)) {
      return StandardPlate.fromText(input);
    }

    throw UnknownFormat;
  }
  static bool _isStandardPlate(String input) {
    List<String> groups = input.trim().split(RegExp(r'\s+'));
    return groups.length >= 2 && groups.length <= 3;
  }
  // Additional methods for other formats (e.g., CustomPlate, ExportPlate, etc.)

  Future<Shopper?> getShopper()async{
    try{
      return Model.database
      .collection('users')
      .where('carPlates', arrayContains: toString())
      .limit(1)
      .get().then((query){
        final doc=query.docs.singleOrNull;
        if (doc==null) return null;
        return Shopper.fromMap(doc.data().putIfAbsent("id", ()=>doc.id));
      });
    }catch (e) {
      debugPrint('Error fetching shopper by plate: $e');
      return null;
    }
  }

  Future<ParkingSession?> getActiveSession()async{
    try {
      return Model.database
        .collection('parking_sessions')
        .where('vehiclePlateNumber', isEqualTo: toString())
        .where('status', isEqualTo: 'active')
        .orderBy('entryTimestamp', descending: true)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10)).then((query){
      final doc=query.docs.singleOrNull;
      if (doc==null) return null;
      return ParkingSession.fromMap(doc.data(), doc.id);
    });
    } catch (e) {
      debugPrint('Error fetching session by plate: $e');
      return null;
    }
  }
}