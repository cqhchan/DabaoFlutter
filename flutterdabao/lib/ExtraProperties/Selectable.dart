import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';


// adds a selectable property to classes
// for use in lists etc to determine which was selected.
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