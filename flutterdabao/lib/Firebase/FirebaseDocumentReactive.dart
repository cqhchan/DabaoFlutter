import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Mappable.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseDocumentReactive<T extends Mappable>{

  Observable<T> observable;
  
  FirebaseDocumentReactive(DocumentReference ref){
  observable = Observable<T>(ref.snapshots().map((snap) => Mappable.mapping<T>(snap)));

  }

}



class FirebaseDocumentReactiveOnce<T extends Mappable>{

  Future<T> future;
  
  FirebaseDocumentReactiveOnce(DocumentReference ref){


      future = ref.get().then((snapshot) {

        return Mappable.mapping<T>(snapshot);

      });



  }

}



