abstract class Component {
  String wssURL;
  String httpURL;
  String location;
  bool wsAsMainStream = true; // false if want to use http

  void setWebSocketStream(String url) {
    this.wssURL = url;
  }

  void setHTTPStream(String url) {
    this.httpURL = url;
  }

  void setLocation(String location) {
    this.location = location;
  }

  void setWSAsMainStream() {
    this.wsAsMainStream = true;
  }

  void setHTTPAsMainStream() {
    this.wsAsMainStream = false;
  }

  void getWebSocketStream();

  void getHTTPStream();

  void getLocation();

/*Component(this.wssURL, this.httpURL) {

  }*/

// Named constructor that forwards to the default one.
//  Component.unlaunched(String name) : this(name, null);

}
