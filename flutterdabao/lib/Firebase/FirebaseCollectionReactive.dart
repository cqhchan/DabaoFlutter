import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Identifiable.dart';
import 'package:flutterdabao/ExtraProperties/Mappable.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseCollectionReactive<T extends FirebaseType> {
  Observable<List<T>> observable;

  FirebaseCollectionReactive(Query ref) {
    observable = Observable(ref.snapshots()).scan(
        (List<T> list, QuerySnapshot snapshot, b) {
      snapshot.documentChanges.forEach((change) {
        switch (change.type) {
          case DocumentChangeType.added:
            list.removeWhere(
                (element) => element.uid == change.document.documentID);
            list.add(Mappable.mapping<T>(change.document));

            break;

          case DocumentChangeType.removed:
            list.removeWhere(
                (element) => element.uid == change.document.documentID);

            break;

          case DocumentChangeType.modified:
            list
                .where((element) => element.uid == change.document.documentID)
                .forEach((element) => element.mapFrom(change.document.data));

            break;
        }
      });

      return list;
    }, List<T>());
  }
}

class FirebaseCollectionReactiveOnce<T extends FirebaseType> {
  Future<List<T>> future;

  FirebaseCollectionReactiveOnce(Query ref) {
    future = ref.getDocuments().then((snapshot) {
      return snapshot.documents.map((doc) => Mappable.mapping<T>(doc)).toList();
    });
  }
}
