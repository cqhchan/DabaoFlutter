import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:flutterdabao/Model/Rating.dart';
import 'package:flutterdabao/Model/Voucher.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class User extends FirebaseType {
  static String foodTagKey = 'FT';
  static String profileImageKey = 'PI';
  static String nameKey = "N";
  static String handPhoneKey = 'HP';
  static String emailKey = 'E';
  static String tokenKey = 'T';
  static String thumbnailImageKey = 'TI';
  static String creationTime = 'CT';
  static String lastLoginTime = 'LLT';
  static String completedDeliveriesKey = 'CD';
  static String completedOrdersKey = 'CO';
  static String ratingKey = 'R';

  BehaviorSubject<String> email;
  BehaviorSubject<String> profileImage;
  BehaviorSubject<String> name;
  BehaviorSubject<String> handPhone;
  BehaviorSubject<String> thumbnailImage;
  BehaviorSubject<List<FoodTag>> userFoodTags;
  BehaviorSubject<int> completedDeliveries;
  BehaviorSubject<int> completedOrders;
  BehaviorSubject<double> rating;

  // Only avaliable in from Auth
  MutableProperty<List<Voucher>> _listOfAvalibleVouchers;
  MutableProperty<List<Voucher>> _listOfInUsedVouchers;

  MutableProperty<List<Voucher>> get listOfAvalibleVouchers {
    if (_listOfAvalibleVouchers == null) {
      _listOfAvalibleVouchers = MutableProperty(List());
      _listOfAvalibleVouchers.bindTo(FirebaseCollectionReactive<Voucher>(
              Firestore.instance
                  .collection(this.className)
                  .document(this.uid)
                  .collection("vouchers")
                  .where(Voucher.statusKey, isEqualTo: voucher_Status_Open))
          .observable);
    }
    return _listOfAvalibleVouchers;
  }

  MutableProperty<List<Voucher>> get listOfInUsedVouchers {
    if (_listOfInUsedVouchers == null) {
      _listOfInUsedVouchers = MutableProperty(List());
      _listOfInUsedVouchers.bindTo(FirebaseCollectionReactive<Voucher>(Firestore
              .instance
              .collection(this.className)
              .document(this.uid)
              .collection("vouchers")
              .where(Voucher.statusKey, isEqualTo: voucher_Status_InUsed))
          .observable);
    }
    return _listOfInUsedVouchers;
  }

  MutableProperty<int> get currentDabaoerRewardsNumber {
    if (_currentDabaoerRewardsNumber == null) {
      _currentDabaoerRewardsNumber = MutableProperty(null);
      _currentDabaoerRewardsNumber.bindTo(ConfigHelper
          .instance.currentDabaoerRewards.producer
          .switchMap((reward) => reward == null
              ? Observable.just(0)
              : Observable<int>(Firestore.instance
                  .collection(this.className)
                  .document(this.uid)
                  .collection(reward.className)
                  .document(reward.uid)
                  .snapshots()
                  .map((doc) => !doc.exists
                      ? 0
                      : !doc.data.containsKey("QTY") ? 0 : doc.data["QTY"])).shareReplay(maxSize: 1)));
    }
    return _currentDabaoerRewardsNumber;
  }

  MutableProperty<int> _currentDabaoerRewardsNumber;

  MutableProperty<int> _currentDabaoeeRewardsNumber;

  MutableProperty<int> get currentDabaoeeRewardsNumber {
    if (_currentDabaoeeRewardsNumber == null) {
      _currentDabaoeeRewardsNumber = MutableProperty(null);
      _currentDabaoeeRewardsNumber.bindTo(ConfigHelper
          .instance.currentDabaoeeRewards.producer
          .switchMap((reward) => reward == null
              ? Observable.just(0)
              : Observable<int>(Firestore.instance
                  .collection(this.className)
                  .document(this.uid)
                  .collection(reward.className)
                  .document(reward.uid)
                  .snapshots()
                  .map((doc) => !doc.exists
                      ? 0
                      : !doc.data.containsKey("QTY") ? 0 : doc.data["QTY"])).shareReplay(maxSize: 1)));
    }
    return _currentDabaoeeRewardsNumber;
  }

  Observable<List<Rating>> listOfReviews;

  User.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);
  User.fromUID(String uid) : super.fromUID(uid);

  User.fromAuth(FirebaseUser user) : super.fromUID(user.uid) {
    if (ConfigHelper.instance.currentUserProperty.value != this)
      ConfigHelper.instance.currentUserProperty.value = this;
  }

  @override
  void setUpVariables() {

    email = BehaviorSubject();
    profileImage = BehaviorSubject();
    name = BehaviorSubject();
    thumbnailImage = BehaviorSubject();
    userFoodTags = BehaviorSubject(seedValue: List());
    handPhone = BehaviorSubject();
    completedDeliveries = BehaviorSubject();
    completedOrders = BehaviorSubject();
    rating = BehaviorSubject();

    listOfReviews = FirebaseCollectionReactive<Rating>(Firestore.instance
            .collection(className)
            .document(this.uid)
            .collection("ratings"))
        .observable;

  }

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey(foodTagKey)) {
      var mapOfFoodTag = data[foodTagKey] as Map;
      List<FoodTag> fT = List();

      mapOfFoodTag.forEach((key, rawMap) {
        var map = rawMap.cast<String, dynamic>();
        fT.add(FoodTag.fromMap(key, map));
      });

      userFoodTags.add(fT);
    } else {
      userFoodTags.add(List());
    }

    if (data.containsKey(emailKey)) {
      email.add(data[emailKey]);
    } else {
      email.add(null);
    }

    if (data.containsKey(profileImageKey)) {
      profileImage.add(data[profileImageKey]);
      //print("PI added");
    } else {
      profileImage.add(null);
      //print("PI null");
    }

    if (data.containsKey(thumbnailImageKey)) {
      thumbnailImage.add(data[thumbnailImageKey]);
    } else {
      if (data.containsKey(profileImageKey)) {
        thumbnailImage.add(data[profileImageKey]);
        //print("PI added");
      } else {
        thumbnailImage.add(null);
        //print("PI null");
      }
    }

    if (data.containsKey(nameKey)) {
      name.add(data[nameKey]);
      //print("name added");
    } else {
      name.add(null);
      //print("name null");
    }

    if (data.containsKey(handPhoneKey)) {
      handPhone.add(data[handPhoneKey]);
      //print("hp added");
    } else {
      handPhone.add(null);
      //print("hp null");
    }

    if (data.containsKey(completedDeliveriesKey)) {
      completedDeliveries.add(data[completedDeliveriesKey]);
    } else {
      completedDeliveries.add(0);
    }

    if (data.containsKey(completedOrdersKey)) {
      completedOrders.add(data[completedOrdersKey]);
    } else {
      completedOrders.add(0);
    }

    if (data.containsKey(ratingKey)) {
      rating.add(data[ratingKey] + 0.0);
    } else {
      rating.add(0.0);
    }
  }

  void setPhoneNumber(String phoneNumber) {
    if (phoneNumber != null)
      Firestore.instance
          .collection(className)
          .document(uid)
          .setData({handPhoneKey: phoneNumber}, merge: true);
  }

  void setEmail(String email) {
    if (email != null)
      Firestore.instance
          .collection(className)
          .document(uid)
          .setData({emailKey: email}, merge: true);
  }

  void setName(String name) {
    if (name != null)
      Firestore.instance
          .collection(className)
          .document(uid)
          .setData({nameKey: name}, merge: true);
  }

  void setToken(String token) {
    Firestore.instance
        .collection(className)
        .document(uid)
        .setData({tokenKey: token}, merge: true);
  }

  void removeVoucher(Voucher voucher) {
    Firestore.instance
        .collection(className)
        .document(uid)
        .collection(voucher.className)
        .document(voucher.uid)
        .delete();
  }

  //last login date
  //creation date
  void setUser(
      String pi, String name) {


    Firestore.instance.collection('/users').document(uid).setData({
      profileImageKey: pi,
      nameKey: name,
      "CT": new DateTime.now(),
      'LLT':  new DateTime.now(),
    }, merge: true);
  }

  void setProfileImage(String pi) {
    Firestore.instance.collection('/users').document(uid).setData({
      profileImageKey: pi,
    }, merge: true);
  }

  Uri _referalLink;

  Future<Uri> get referalLink async {
    if (_referalLink == null) {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        dynamicLinkParametersOptions: DynamicLinkParametersOptions(
            shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short),
        domain: 'dabaotest.page.link',
        link: Uri.parse(
            'https://www.dabaoapp.sg/?invitedby=${ConfigHelper.instance.currentUserProperty.value.uid}'),
        androidParameters: AndroidParameters(
          packageName: 'com.example.android',
          minimumVersion: 125,
        ),
        iosParameters: IosParameters(
          bundleId: 'com.example.ios',
          minimumVersion: '1.0.1',
          appStoreId: '123456789',
        ),
      );
      final ShortDynamicLink shortDynamicLink =
          await parameters.buildShortLink();
      _referalLink = shortDynamicLink.shortUrl;
    }

    return _referalLink;
  }
}
