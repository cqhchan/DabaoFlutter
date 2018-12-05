import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Identifiable.dart';
import 'package:flutterdabao/ExtraProperties/Mappable.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseCollectionReactiveOnce<T extends FirebaseType>{

  Future<List<T>> future;

  FirebaseCollectionReactiveOnce(Query ref){

      future = ref.getDocuments().then((snapshot) {


        return snapshot.documents.map((doc) => Mappable.mapping<T>(doc)).toList();


      });

  }


}
