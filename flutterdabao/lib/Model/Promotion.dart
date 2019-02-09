
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/subjects.dart';

class Promotion extends FirebaseType {
  static String titleKey = "T";
  static String imageUrlKey = "I";
  static String promoUrlKey = "P";
  static String viewableKey = "V";

  BehaviorSubject<String> title;
  BehaviorSubject<String> imageURL;
  BehaviorSubject<String> promoURL;

  Promotion.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey(titleKey)) {
      title.add(data[titleKey]);
    } else {
      title.add(null);
    }

    if (data.containsKey(imageUrlKey)) {
      imageURL.add(data[imageUrlKey]);
    } else {
      imageURL.add(null);
    }

    if (data.containsKey(promoUrlKey)) {
      promoURL.add(data[promoUrlKey]);
    } else {
      promoURL.add(null);
    }
  }

  @override
  void setUpVariables() {
    title = BehaviorSubject();
    imageURL = BehaviorSubject();
    promoURL = BehaviorSubject();
  }
}
