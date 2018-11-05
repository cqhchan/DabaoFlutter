abstract class Equatable {

  
  
  @override
  bool operator ==(o) => isEqual(o);
  
  @override
  int get hashCode => generateHashCode();


  bool isEqual(Object o);

  int generateHashCode();


}