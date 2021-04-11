import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nautica/Configuration.dart';
import 'package:nautica/models/BaseModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nautica/network/SignalKClient.dart';

class SplashScreen extends StatefulWidget {
  /// creates the home page layout
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  BaseModel model = BaseModel.instance;
  String viewStatus = "splashscreen";
  Widget currentView;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<int> _counter;
  bool isConnecting = false;
  bool connectionDone = false;
  bool couldNotConnect = false;
  bool splashScreenLoaded = false;
  bool firstSetupDone = false;
  String signalKUser;
  String signalKPassword;
  String signalKServerAddress;
  int signalKServerPort;
  int widgetRefreshRate;
  int mapRefreshRate;
  bool keepLoggedIn = false;
  TextEditingController addressTextController = TextEditingController();
  TextEditingController portTextController = TextEditingController();
  TextEditingController usernameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  Authentication loginData;

  SignalKClient signalK = null;

  @override
  void initState() {
    super.initState();

    //display splashscreen

    Future.delayed(Duration(seconds: 1), () {
      // 5s over, navigate to a new page

      _prefs.then((SharedPreferences prefs) {
        // return (prefs.getInt('counter') ?? 0);

        //  signalKUser = prefs.getString('signalKUser') ?? "";
        //  signalKPassword = prefs.getString('signalKPassword') ?? "";
        //  widgetRefreshRate = prefs.getInt('widgetRefreshRate') ?? 350;
        //  mapRefreshRate = prefs.getInt('mapRefreshRate') ?? 2;
        signalKServerAddress =
            prefs.getString('signalKServerAddress') ?? NAUTICA['signalK']['connection']['address'];
        signalKServerPort = prefs.getInt('signalKServerPort') ?? NAUTICA['signalK']['connection']['port'];
        firstSetupDone = prefs.getBool('firstSetupDone') ?? false;
        keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;

        if (!firstSetupDone) {
          initializeTextInputs();
          //need to ask login data
          _setViewStatus("ask_for_credentials");
        } else {
          if (keepLoggedIn) {
            //go to dashboard
            goToDashBoard();
          } else {
            initializeTextInputs();
            _setViewStatus("ask_for_credentials");

          }
        }
      });
    });

    //look for preferences
    //

    //if no preference show login form and store values

    //go to dashboard
  }

  void goToDashBoard() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/dashboard');
  }

  void initializeTextInputs() {
    addressTextController.text = signalKServerAddress;
    portTextController.text = signalKServerPort.toString();
  }

  Future<void> updatePreferences() async {
    final SharedPreferences prefs = await _prefs;

    return prefs.setString("signalKServerAddress", addressTextController.text).then((bool success) {
     return  prefs.setInt("signalKServerPort", int.parse(portTextController.text)).then((bool success) {
       return  prefs.setBool("keepLoggedIn", keepLoggedIn).then((bool success) {
         return  prefs.setBool("firstSetupDone", true).then((bool success) {
           signalKServerAddress =
               prefs.getString('signalKServerAddress') ?? "192.168.1.171";
           signalKServerPort = prefs.getInt('signalKServerPort') ?? 3004;
           firstSetupDone = prefs.getBool('firstSetupDone') ?? false;
           keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;

           print("read " + signalKServerAddress);
           print("read " + signalKServerPort.toString());
           print("read " + firstSetupDone.toString());
           print("read " + keepLoggedIn.toString());


         return Future.value(true);
         });
       });
      });
    });


  }

  void _setViewStatus(String status) {
    setState(() {
      viewStatus = status;
    });
  }

  void tryConnection() async {
    setState(() {
      isConnecting = true;
      connectionDone = false;
    });
    String address = addressTextController.text;
    String port = portTextController.text;

    //todo - implement username/password access

    //String username = usernameTextController.text;
    //String password = passwordTextController.text;
    //_setViewStatus("dashboard");

    //

    signalK = SignalKClient(address, int.parse(port), loginData);

    signalK.loadSignalKData().then((x) {
      //connectionn status OK

       updatePreferences().then((res) {
         setState(() {
           signalK.disconnect();
           isConnecting = false;
           connectionDone = true;
           couldNotConnect = false;
           print("connected");

           //save credentials

           goToDashBoard();
         });
       });


    }).catchError((Object onError) {
      print('[main] Unable to connect -- on error : $onError');

      setState(() {
        isConnecting = false;
        couldNotConnect = true;

        print("not connected");
        //go to dashboard
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD SPLASH");

    switch (viewStatus) {
      case 'ask_for_credentials':
        currentView = Container(
            child: Center(
          child: Container(
            decoration: BoxDecoration(color: model.splashScreenBackground),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 3, // 20%
                  child: Container(color: model.splashScreenBackground),
                ),
                Expanded(
                  flex: 4, // 60%
                  child: Container(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2, // 20%
                          child: Container(color: model.splashScreenBackground),
                        ),
                        Expanded(
                          flex: 6, // 20%
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(12.0),
                                  bottomLeft: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0)),
                            ),
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(children: [
                                  Text('Nautica ',
                                      style: TextStyle(
                                          color: model.paletteColor,
                                          fontSize: 48,
                                          letterSpacing: 0.53,
                                          fontFamily: 'Roboto-Bold')),
                                  Padding(padding: EdgeInsets.only(top: 5)),
                                  Text('welcome!',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 19,
                                          letterSpacing: 0.53,
                                          fontFamily: 'Roboto')),
                                  Padding(padding: EdgeInsets.only(top: 15)),
                                ]),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: model.splashScreenBackground)),
                                  padding: EdgeInsets.only(
                                      top: 15, left: 5, right: 5, bottom: 15),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: CupertinoTextField(
                                              enabled:
                                                  (isConnecting) ? false : true,
                                              controller: addressTextController,
                                              placeholder: "Server address",
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding:
                                                  EdgeInsets.only(left: 15),
                                              child: CupertinoTextField(
                                                placeholder: "Port",
                                                enabled: (isConnecting)
                                                    ? false
                                                    : true,
                                                controller: portTextController,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(top: 15)),
                                      Container(
                                        child: CheckboxListTile(
                                          title: const Text('Keep logged in'),
                                          value: keepLoggedIn,
                                          activeColor: model.paletteColor,
                                          checkColor: Colors.white,
                                          onChanged: (bool value) {
                                            setState(() {
                                              keepLoggedIn = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(top: 15)),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: CupertinoButton(
                                        color: model.paletteColor,
                                        onPressed: () {
                                          // Navigate back to first screen when tapped.
                                          if (isConnecting) return null;
                                          tryConnection();
                                        },
                                        child: isConnecting
                                            ? CupertinoActivityIndicator()
                                            : Text('Connect'),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(padding: EdgeInsets.only(top: 35)),
                                    isConnecting
                                        ? Text(
                                            'connecting to ' +
                                                addressTextController.text
                                                    .toString() +
                                                ":" +
                                                portTextController.text
                                                    .toString(),
                                            style: TextStyle(
                                                color: model.paletteColor,
                                                fontSize: 15,
                                                letterSpacing: 0.53,
                                                fontWeight: FontWeight.normal,
                                                fontFamily: 'Roboto'))
                                        : Text(
                                            couldNotConnect
                                                ? 'unable to connect'
                                                : connectionDone
                                                    ? 'connection estabilished'
                                                    : 'please provide your server authentication data',
                                            style: TextStyle(
                                                color: couldNotConnect
                                                    ? Colors.redAccent
                                                    : connectionDone
                                                        ? Colors.green
                                                        : Colors.black54,
                                                fontSize: 15,
                                                letterSpacing: 0.53,
                                                fontWeight: FontWeight.normal,
                                                fontFamily: 'Roboto')),
                                    Padding(padding: EdgeInsets.only(top: 15)),
                                    Padding(padding: EdgeInsets.only(top: 35)),
                                    Text('Go to GitHub Project',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 15,
                                            letterSpacing: 0.53,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto-Bold')),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2, // 20%
                          child: Container(color: model.splashScreenBackground),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3, // 20%
                  child: Container(color: model.splashScreenBackground),
                )
              ],
            ),
          ),
        ));

        break;

      case 'splashscreen':
      default:
        currentView = Container(
          child: Center(child: Text("splashscreen...")),
        );

        break;
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: FutureBuilder(builder: (context, snapshot) {
            return Container(child: Center(key: UniqueKey(), child: currentView));
          }),
        ),
      ),
    );
  }
}
