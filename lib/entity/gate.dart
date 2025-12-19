import 'package:firebase_auth/firebase_auth.dart';

import 'location.dart';
import 'entity.dart';

class Gate extends Model{
  static FirebaseAuth auth = FirebaseAuth.instance;
  String name="";
  ID? location;
  Future<Location> getLocation() async=>Location.get(id:location);
  Gate({required super.id,required this.name,this.location});
  factory Gate.fromItem(Item item)=>Gate(id:item.key,name: item.value['name'],location:item.value['locationId']);
  static Future<Gate> login(String name,String password) async{
    try{
      await auth.signInWithEmailAndPassword(email: name, password: password);
      final item = (await Model.database.collection('cameras').where('name',isEqualTo:name).limit(1).get()).docs.single;
      final currentUser=Gate.fromItem({item.id:item.data()}.entries.single);
      return currentUser;
    }catch(e) {throw Exception( 'Login failed');}
  }
}
