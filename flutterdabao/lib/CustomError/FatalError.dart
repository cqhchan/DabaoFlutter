class FatalError extends Error {

    String error = "";

    FatalError(this.error){
      print(toString());

    }

    String toString() => "Fatal Error: " + error;


}