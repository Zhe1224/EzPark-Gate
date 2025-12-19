import 'package:cloud_firestore/cloud_firestore.dart';

typedef ID=String;
typedef ItemBody = Map<String, dynamic>;
typedef Item = MapEntry<ID,ItemBody>;
typedef Items = Map<ID,ItemBody>;
typedef decimal = double;
typedef Model = Entity;

abstract class Entity{
  static final FirebaseFirestore database=FirebaseFirestore.instance;
  ID? id;
  Entity({this.id});
  
}