import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:nautica/Configuration.dart';
import 'package:nautica/models/BaseModel.dart';
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


      Hive.openBox("settings").then((settings){
        signalKServerAddress = settings.get("signalk_address") ?? NAUTICA['signalK']['connection']['address'];
        signalKServerPort = settings.get("signalk_port") ?? NAUTICA['signalK']['connection']['port'];
        firstSetupDone = settings.get("first_setup_done") ?? false;
        keepLoggedIn = settings.get("keep_logged_in") ?? false;
        //settings.close().then((e){
          if (!firstSetupDone) {
            initializeTextInputs();
            //need to ask login data
            _setViewStatus("ask_for_credentials");
          } else {
            if (keepLoggedIn) {
              //go to dashboard
              print("GOTODASHBOARDDD");
              goToDashBoard();
            } else {
              initializeTextInputs();
              _setViewStatus("ask_for_credentials");

            }
          }
        //});
        //  signalKUser = prefs.getString('signalKUser') ?? "";
        //  signalKPassword = prefs.getString('signalKPassword') ?? "";
        //  widgetRefreshRate = prefs.getInt('widgetRefreshRate') ?? 350;
        //  mapRefreshRate = prefs.getInt('mapRefreshRate') ?? 2;


      });





    });

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
    return await Hive.openBox("settings").then((settings) async {
      await settings.put("signalk_address", addressTextController.text);
      await settings.put("signalk_port", int.parse(portTextController.text));
      await settings.put("first_setup_done", true);
      await settings.put("keep_logged_in", keepLoggedIn);
      //await settings.close();
    });

  }

  void _setViewStatus(String status) {
    setState(() {
      viewStatus = status;
    });
  }

  void tryConnection() async {

    String address = addressTextController.text;
    String port = portTextController.text;

    if(address.isEmpty || port.isEmpty) return null;

    setState(() {
      isConnecting = true;
      connectionDone = false;
    });

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

         });
         goToDashBoard();

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

  final kHintTextStyle = TextStyle(
    color: Colors.white54,
    fontFamily: 'OpenSans',
  );

  final kLabelStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );

  final kBoxDecorationStyle = BoxDecoration(
    color: Color(0xFF6CA8F1),
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );







  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'SignalK Server',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: TextField(
                  enabled:
                  (isConnecting) ? false : true,
                  controller: addressTextController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(
                      Icons.wifi,
                      color: Colors.white,
                    ),
                    hintText: 'Server address',
                    hintStyle: kHintTextStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                  EdgeInsets.only(left: 15),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 14.0),
                      prefixIcon: Icon(
                        Icons.workspaces_outline,
                        color: Colors.white,
                      ),
                      hintText: 'Port',
                      hintStyle: kHintTextStyle,
                    ),
                    enabled: (isConnecting)
                        ? false
                        : true,
                    controller: portTextController,
                  ),
                ),
              ),
            ],
          ),



         // TextField(
         //   keyboardType: TextInputType.emailAddress,
         //   style: TextStyle(
         //     color: Colors.white,
         //     fontFamily: 'OpenSans',
         //   ),
         //   decoration: InputDecoration(
         //     border: InputBorder.none,
         //     contentPadding: EdgeInsets.only(top: 14.0),
         //     prefixIcon: Icon(
         //       Icons.email,
         //       color: Colors.white,
         //     ),
         //     hintText: 'Enter your Email',
         //     hintStyle: kHintTextStyle,
         //   ),
         // ),




        ),
      ],
    );
  }



  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: keepLoggedIn,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  keepLoggedIn = value;
                });
              },
            ),
              
          ),
          Text(
            'Keep logged in',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        onPressed: () {
          // Navigate back to first screen when tapped.
          if (isConnecting) return null;
          tryConnection();
        },
        child: isConnecting
            ? CupertinoActivityIndicator()
            : Text(
          'Connect',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),




      ),
    );
  }

  Widget _buildSignInWithText() {
    return Column(
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
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
                () => print('Login with Facebook'),
            AssetImage(
              'assets/logos/facebook.jpg',
            ),
          ),
          _buildSocialBtn(
                () => print('Login with Google'),
            AssetImage(
              'assets/logos/google.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => print('Sign Up Button Pressed'),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Welcome to Nautica',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      _buildEmailTF(),
                      SizedBox(
                        height: 30.0,
                      ),
                      _buildRememberMeCheckbox(),
                      _buildLoginBtn(),
                      _buildSignInWithText(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }




  @override
  Widget build2(BuildContext context) {
    print("BUILD SPLASH");

    switch (viewStatus) {
      case 'ask_for_credentials':
      // tryConnection();
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
                  flex: 1, // 60%
                  child: Container(
                    child: Column(
                      children: [

                        Expanded(
                          flex: 1, // 20%
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
                            margin: EdgeInsets.all( 150),
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
                                            child: Container(
                                              padding:
                                              EdgeInsets.only(right: 15),
                                              child: CupertinoTextField(
                                                enabled:
                                                    (isConnecting) ? false : true,
                                                controller: addressTextController,
                                                placeholder: "Server address",
                                              ),
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

                      ],
                    ),
                  ),
                ),

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
