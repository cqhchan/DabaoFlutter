import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';

abstract class Enableable {

  MutableProperty<bool> isEnabled = new MutableProperty(true);


  disable(){
    isEnabled.value = true;
  }

  enable(){
    isEnabled.value = false;
  }


  static disableAll(List<Enableable> list){
    list.forEach((element) => element.disable());
  }


}