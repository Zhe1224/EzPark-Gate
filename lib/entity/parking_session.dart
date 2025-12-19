import 'package:cloud_firestore/cloud_firestore.dart';
import 'entity.dart';
import 'gate.dart';
import 'location.dart';
import 'plate.dart';
import 'shopper.dart';

/// Parking session model
/// Shared between EzPark and GateApp via Firestore
class ParkingSession extends Model{
  final ID userId;
  final String vehiclePlateNumber;
  final DateTime entryTimestamp;
  DateTime? exitTimestamp;
  final int? durationMinutes;
  decimal? baseFee;
  final decimal membershipDiscountAmount;
  final decimal voucherDiscountAmount;
  decimal? finalFee;
  ParkingSessionStatus status;
  final String sessionType; // 'gate' or 'booking' - distinguish session source
  final ID? voucherAppliedId; // Reference to voucher document
  final ID? paymentMethodId;
  final String? transactionId;
  final ID? locationId;
  final ID? bayId;
  final String? parkingLocationName; // Display name for UI
  final DateTime createdAt;
  final DateTime? updatedAt;

  Future<ID> _put()async{
    final ItemBody item=toMap();
    return  (await Model.database.collection('parking_sessions').add(item)).id;
  }

  static Future<ParkingSession> put({required Plate plate, required Gate gate}) async {
    final DateTime time=DateTime.parse(FieldValue.serverTimestamp().toString());
    final [shopper as Shopper?,location as Location] = await Future.wait([
      plate.getShopper(),gate.getLocation()
    ]);
    final ParkingSession item=ParkingSession._(
      userId: shopper?.id??'guest'
      ,vehiclePlateNumber: plate.toString()
      ,entryTimestamp: time
      ,sessionType: 'gate'
      ,locationId: gate.location
      ,parkingLocationName: location.name
      ,createdAt: time,
    );
    await item._put().then((id){item.id=id;});
    return item;
  }

  Future<bool> isCompleted()async{
    if (status==ParkingSessionStatus.pending) await Future.doWhile(()=>status==ParkingSessionStatus.pending);
    return status==ParkingSessionStatus.completed;
  }

  bool needsCheckout(){
    return status!=ParkingSessionStatus.completed;
  }

  void markPending(){status=ParkingSessionStatus.pending;}
  void markCompleted(){status=ParkingSessionStatus.completed;}

  Future<void> update() async {
    await Model.database.collection('parking_sessions').doc(id).update(toMap());
  }

  ParkingSession._({
    super.id,
    required this.userId,
    required this.vehiclePlateNumber,
    required this.entryTimestamp,
    this.exitTimestamp,
    this.durationMinutes,
    this.baseFee,
    this.membershipDiscountAmount = 0,
    this.voucherDiscountAmount = 0,
    this.finalFee,
    this.status = ParkingSessionStatus.active,
    this.sessionType = 'gate', // Default to gate session
    this.voucherAppliedId,
    this.paymentMethodId,
    this.transactionId,
    this.locationId,
    this.bayId,
    this.parkingLocationName,
    required this.createdAt,
    this.updatedAt,
  });

  // Compatibility getters for existing code
  DateTime get startTime => entryTimestamp;
  DateTime? get endTime => exitTimestamp;
  String? get parkingLocationId => locationId;
  
  /// Get current cost (estimated or final)
  double get currentCost => finalFee ?? baseFee ?? 0.0;
  
  /// Get duration in hours (decimal)
  double get durationInHours => currentDurationMinutes / 60.0;

  /// Check if session is active (user is currently parked)
  bool get isActive => status == ParkingSessionStatus.active && exitTimestamp == null;

  /// Get current duration in minutes
  int get currentDurationMinutes {
    if (exitTimestamp != null) {
      return exitTimestamp!.difference(entryTimestamp).inMinutes;
    }
    return DateTime.now().difference(entryTimestamp).inMinutes;
  }

  /// Get duration in hours and minutes format
  String get durationFormatted {
    final mins = currentDurationMinutes;
    final hours = mins ~/ 60;
    final minutes = mins % 60;
    return '${hours}h ${minutes}m';
  }

  /// Get total discount amount
  double get totalDiscountAmount => membershipDiscountAmount + voucherDiscountAmount;

  /// Create from Firestore document
  factory ParkingSession.fromMap(Map<String, dynamic> map, String id) {
    // Helper to safely convert to DateTime
    DateTime? toDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return ParkingSession._(
      id: id,
      userId: (map['userId'] as String?) ?? 'guest',
      vehiclePlateNumber: (map['vehiclePlateNumber'] as String?) ?? 'UNKNOWN',
      entryTimestamp: toDateTime(map['entryTimestamp']) ?? DateTime.now(),
      exitTimestamp: toDateTime(map['exitTimestamp']),
      durationMinutes: map['durationMinutes'] as int?,
      baseFee: (map['baseFee'] as num?)?.toDouble(),
      membershipDiscountAmount: (map['membershipDiscountAmount'] as num?)?.toDouble() ?? 0,
      voucherDiscountAmount: (map['voucherDiscountAmount'] as num?)?.toDouble() ?? 0,
      finalFee: (map['finalFee'] as num?)?.toDouble(),
      status: ParkingSessionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ParkingSessionStatus.active,
      ),
      sessionType: (map['sessionType'] as String?) ?? 'gate', // Default to gate for old records
      voucherAppliedId: map['voucherAppliedId'] as String?,
      paymentMethodId: map['paymentMethodId'] as String?,
      transactionId: map['transactionId'] as String?,
      locationId: map['locationId'] as String?,
      bayId: map['bayId'] as String?,
      parkingLocationName: map['parkingLocationName'] as String?,
      createdAt: toDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: toDateTime(map['updatedAt']),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vehiclePlateNumber': vehiclePlateNumber,
      'entryTimestamp': Timestamp.fromDate(entryTimestamp),
      'exitTimestamp': exitTimestamp != null ? Timestamp.fromDate(exitTimestamp!) : null,
      'durationMinutes': durationMinutes,
      'baseFee': baseFee,
      'membershipDiscountAmount': membershipDiscountAmount,
      'voucherDiscountAmount': voucherDiscountAmount,
      'finalFee': finalFee,
      'status': status.name,
      'sessionType': sessionType,
      'voucherAppliedId': voucherAppliedId,
      'paymentMethodId': paymentMethodId,
      'transactionId': transactionId,
      'locationId': locationId,
      'bayId': bayId,
      'parkingLocationName': parkingLocationName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create a copy with updated fields
  ParkingSession copyWith({
    String? id,
    String? userId,
    String? vehiclePlateNumber,
    DateTime? entryTimestamp,
    DateTime? exitTimestamp,
    int? durationMinutes,
    double? baseFee,
    double? membershipDiscountAmount,
    double? voucherDiscountAmount,
    double? finalFee,
    ParkingSessionStatus? status,
    String? sessionType,
    String? voucherAppliedId,
    String? paymentMethodId,
    String? transactionId,
    String? locationId,
    String? bayId,
    String? parkingLocationName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParkingSession._(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      entryTimestamp: entryTimestamp ?? this.entryTimestamp,
      exitTimestamp: exitTimestamp ?? this.exitTimestamp,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      baseFee: baseFee ?? this.baseFee,
      membershipDiscountAmount: membershipDiscountAmount ?? this.membershipDiscountAmount,
      voucherDiscountAmount: voucherDiscountAmount ?? this.voucherDiscountAmount,
      finalFee: finalFee ?? this.finalFee,
      status: status ?? this.status,
      sessionType: sessionType ?? this.sessionType,
      voucherAppliedId: voucherAppliedId ?? this.voucherAppliedId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      transactionId: transactionId ?? this.transactionId,
      locationId: locationId ?? this.locationId,
      bayId: bayId ?? this.bayId,
      parkingLocationName: parkingLocationName ?? this.parkingLocationName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Parking session status enum
enum ParkingSessionStatus {
  active,    // Currently parked
  completed, // Exited and paid
  pending,   // Exited, payment pending
  failed,    // Payment failed
  cancelled, // Cancelled by admin
}

/// Booking cancellation reason enum
enum CancelBookingReason {
  changeOfPlans,
  foundAnotherParking,
  emergency,
  wrongLocation,
  technicalIssue,
  other,
}

// Legacy alias for backward compatibility
typedef ParkingStatus = ParkingSessionStatus;
