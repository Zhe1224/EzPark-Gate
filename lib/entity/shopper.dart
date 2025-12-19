import 'entity.dart';
import 'payment_methods.dart';

class Shopper extends Model{
  final String email;
  final String username;
  final String name;
  final String phone;
  final String? carPlate; // Keep for backward compatibility
  final List<String> carPlates; // New: support multiple car plates
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isAdmin;
  final String? photoUrl;
  final bool useAutoPay;

  Shopper({
    required super.id,
    required this.email,
    required this.username,
    required this.name,
    required this.phone,
    this.carPlate,
    List<String>? carPlates,
    required this.createdAt,
    this.updatedAt,
    this.isAdmin = false,
    this.photoUrl,
    required this.useAutoPay
  }) : carPlates = carPlates ?? (carPlate != null ? [carPlate] : []);

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'phone': phone,
      'carPlate': carPlate ?? (carPlates.isNotEmpty ? carPlates.first : null),
      'carPlates': carPlates,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isAdmin': isAdmin,
      'photoUrl': photoUrl,
      'useAutoPay': useAutoPay
    };
  }

  // Create from Firestore document
  factory Shopper.fromMap(Map<String, dynamic> map) {
    // Handle both old format (carPlate) and new format (carPlates)
    List<String> plates = [];
    if (map['carPlates'] != null) {
      plates = List<String>.from(map['carPlates']);
    } else if (map['carPlate'] != null) {
      plates = [map['carPlate'] as String];
    }
    
    return Shopper(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? map['name'] ?? '', // Fallback for old data
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      carPlate: map['carPlate'] ?? (plates.isNotEmpty ? plates.first : null),
      carPlates: plates,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isAdmin: map['isAdmin'] ?? false, // Default to false for existing users
      photoUrl: map['photoUrl'],
      useAutoPay: map['useAutoPay'],
    );
  }

  Shopper copyWith({
    String? id,
    String? email,
    String? username,
    String? name,
    String? phone,
    String? carPlate,
    List<String>? carPlates,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAdmin,
    String? photoUrl,
    bool? useAutoPay
  }) {
    return Shopper(
      id: id ?? super.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      carPlate: carPlate ?? this.carPlate,
      carPlates: carPlates ?? this.carPlates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAdmin: isAdmin ?? this.isAdmin,
      photoUrl: photoUrl ?? this.photoUrl,
      useAutoPay: useAutoPay ?? this.useAutoPay
    );
  }

  Future<PaymentMethods> getPaymentMethods() async {
    if (!useAutoPay) return PaymentMethods();
    final series = (await Model.database.collection('payment_methods').where('userId',isEqualTo: id).get()).docs;
    return PaymentMethods.fromItems(series.asMap().map((_,item)=>{item.id:item.data()}.entries.single));
  }
}

