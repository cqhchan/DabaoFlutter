

import 'package:flutterdabao/ReactiveHelpers/MutableProperty.dart';


// adds a selectable property to classes
// for use in lists etc to determine which was selected.
abstract class Selectable {

  MutableProperty<bool> isSelected = new MutableProperty(false);


  select(){
    isSelected.value = true;
  }

  deSelect(){
    isSelected.value = false;
  }


  static deselectAll(List<Selectable> list){
    list.forEach((element) => element.deSelect());
  }


}