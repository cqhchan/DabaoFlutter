

// adds a selectable property to classes
// for use in lists etc to determine which was selected.
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';

abstract class Selectable {

  
  MutableProperty<bool> isSelectedProperty = new MutableProperty(false);

  bool get isSelected =>  isSelectedProperty.value;

  select(){
    isSelectedProperty.value = true;
  }

  deSelect(){
    isSelectedProperty.value = false;
  }

  toggle(){
    isSelectedProperty.value = !isSelectedProperty.value;
  }


  static deselectAll(List<Selectable> list){
    list.forEach((element) => element.deSelect());
  }


}