import 'location.dart';
import 'entity.dart';

class Gate extends Model{
  String name="";
  ID? location;
  Future<Location> getLocation() async=>Location.get(id:location);
  Gate._({required super.id,required this.name,this.location});
  factory Gate.fromItem(Item item)=>Gate._(id:item.key,name: item.value['name'],location:item.value['locationId']);
  static Future<Gate> login(String name,String password) async{
    try{
    final item = (await Model.database.collection('cameras').where('name',isEqualTo:name).where('passwordHash',isEqualTo:password).limit(1).get()).docs.single;
    final currentUser=Gate.fromItem({item.id:item.data()}.entries.single);
    return currentUser;
    }catch(e) {throw Exception( 'Login failed');}
  }
}
