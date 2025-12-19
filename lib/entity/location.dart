import 'package:parking_gate/entity/entity.dart';

class Location extends Model{
  String name="";
  static Future<Location> get({ID? id})async
  =>id==null?Location._(name: 'Main Parking') 
  :Location.fromItem({id:(await Model.database.collection('users').doc(id).get()).data()!}.entries.single);

  factory Location.fromItem(Item item) => Location._(
    id:item.key,
    name:item.value['name']
  );
  
  Location._({
    super.id,
    required this.name
  });
}