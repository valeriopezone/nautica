import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:SKDashboard/Configuration.dart';
import 'package:SKDashboard/models/BaseModel.dart';
import 'package:SKDashboard/network/SignalKClient.dart';

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
    Future.delayed(Duration(seconds: 3), () {
      Hive.openBox("settings").then((settings) {
        signalKServerAddress = settings.get("signalk_address") ?? CONF['signalK']['connection']['address'];
        signalKServerPort = settings.get("signalk_port") ?? CONF['signalK']['connection']['port'];
        firstSetupDone = settings.get("first_setup_done") ?? false;
        keepLoggedIn = settings.get("keep_logged_in") ?? false;
        if (!firstSetupDone) {
          initializeTextInputs();
          _setViewStatus("ask_for_credentials");
        } else {
          if (keepLoggedIn) {
            goToDashBoard();
          } else {
            initializeTextInputs();
            _setViewStatus("ask_for_credentials");
          }
        }

      });
    });
  }

  void goToDashBoard() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/monitoring_environment');
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
    if (mounted)
      setState(() {
        viewStatus = status;
      });
  }

  void tryConnection() async {
    String address = addressTextController.text;
    String port = portTextController.text;

    if (address.isEmpty || port.isEmpty) return null;

    if (mounted)
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
        if (mounted)
          setState(() {
            signalK.disconnect();
            isConnecting = false;
            connectionDone = true;
            couldNotConnect = false;
          });
        goToDashBoard();
      });
    }).catchError((Object onError) {
      print('[main] Unable to connect -- on error : $onError');

      if (mounted)
        setState(() {
          isConnecting = false;
          couldNotConnect = true;
          //go to dashboard
        });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final kHintTextStyle = TextStyle(
    color: Colors.black,
    fontFamily: 'OpenSans',
  );

  final kLabelStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );

  final kBoxDecorationStyle = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  Widget _buildSignalKInputs() {

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
                  enabled: (isConnecting) ? false : true,
                  controller: addressTextController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(
                      Icons.wifi,
                      color: Color(0xFF005B4F),
                    ),
                    hintText: 'Server address',
                    hintStyle: kHintTextStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.only(left: 15),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 14.0),
                      prefixIcon: Icon(
                        Icons.workspaces_outline,
                        color: Color(0xFF005B4F),
                      ),
                      hintText: 'Port',
                      hintStyle: kHintTextStyle,
                    ),
                    enabled: (isConnecting) ? false : true,
                    controller: portTextController,
                  ),
                ),
              ),
            ],
          ),
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
                if (mounted)
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

  Widget _buildConnectBtn() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.symmetric(vertical: 5.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        padding: EdgeInsets.all(25.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
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
                  color: Color(0xFF005B4F),
                  letterSpacing: 1.5,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
              ),
      ),
    );
  }

  Widget _buildFormFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(padding: EdgeInsets.only(top: 35)),
        isConnecting
            ? Text('connecting to ' + addressTextController.text.toString() + ":" + portTextController.text.toString(),
                style: TextStyle(color: model.paletteColor, fontSize: 15, letterSpacing: 0.53, fontWeight: FontWeight.normal, fontFamily: 'Roboto'))
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
        Text('Go to GitHub Project', style: TextStyle(color: Colors.black54, fontSize: 15, letterSpacing: 0.53, fontWeight: FontWeight.bold, fontFamily: 'Roboto-Bold')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    switch (viewStatus) {
      case 'ask_for_credentials':
        currentView = Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF03AA99),
                    Color(0xFF018677),
                    Color(0xFF006C5F),
                    Color(0xFF005B4F),
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
                      'Welcome to SKDashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'OpenSans',
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30.0),
                    _buildSignalKInputs(),
                    SizedBox(
                      height: 30.0,
                    ),
                    _buildRememberMeCheckbox(),
                    _buildConnectBtn(),
                    _buildFormFooter(),
                  ],
                ),
              ),
            )
          ],
        );

        break;

    case 'splashscreen':
    default:
    currentView = Stack(
      children: [Container(
      child: Center(child:

      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
        child:
        Text('SKDashboard ', style: TextStyle(color: Color.fromRGBO(2, 137, 123, 1.0), fontSize: 50, letterSpacing: 0.53, fontFamily: 'Roboto-Bold'))),


          Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
              child: Text('Open Source Marine Electronics',
                  style: TextStyle(
                      color: Colors.black, fontSize: 14, fontFamily: 'Roboto-Regular', letterSpacing: 0.26, fontWeight: FontWeight.normal))),



          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CupertinoActivityIndicator(),
          ),


        ],
      )

      ),
      ),

      Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Università degli studi di Napoli \"Parthenope\" - Corso di Laurea in Informatica - Valerio Pezone"),
                ),
              ],
            ),
          ),

      )

      ],
    );

    break;
  }


    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: currentView
        ),
      ),
    );
  }
}
