class FatalError extends Error {

    String error = "";

    FatalError(this.error);

    String toString() => "Fatal Error" + error;


}