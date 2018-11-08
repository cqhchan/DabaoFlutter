

//TODO fix bug where by app continues to run after fatal Error
class FatalError extends Error {

    String error = "";

    FatalError(this.error){
      print(toString());

    }

    String toString() => "Fatal Error: " + error;


}