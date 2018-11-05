import 'package:flutterdabao/CustomError/FatalError.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';



// ALL MAPPABLE MUST DECLARE THEIR Mapping Method here

 abstract class Mappable {


  T factory<T extends Mappable>(Object o){

    switch (T.runtimeType.toString()){

      case (FirebaseKeyHelper.userKey):
        
      
    }


    throw FatalError("Mappable Not Declared");
  }
  
}

