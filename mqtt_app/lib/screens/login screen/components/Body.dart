import 'package:flutter/material.dart';
import 'package:tung_mqtt_monitor_app/components/rounded_button.dart';
import 'package:tung_mqtt_monitor_app/components/rounded_input_field.dart';
import 'package:tung_mqtt_monitor_app/screens/login%20screen/components/background.dart';

class Body extends StatefulWidget {
  const Body({Key key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  TextEditingController brokerController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController identifierController = TextEditingController();
  TextEditingController topicController = TextEditingController();

  String broker = 'm14.cloudmqtt.com';
  int port = 12321;
  String username = 'bxpalvco';
  String passwd = 'UUILhS73phGV';
  String clientIdentifier = 'tung';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /*Text(
                "Login",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),*/
              /*SizedBox(height: size.height * 0.03,),
              SvgPicture.asset(
                  "images/Logo.png",
              height: size.height * 0.5,),*/
              SizedBox(height: size.height * 0.03,),
              RoundedInputField(
                controller: brokerController,
                hintText: "Your Broker",
                onChanged: (value) => broker = value,
              ),
              SizedBox(height: size.height * 0.03,),
              RoundedInputField(
                controller: portController,
                hintText: "Your Port",
                onChanged: (value) => port = int.tryParse(value),
              ),
              SizedBox(height: size.height * 0.03,),
              RoundedInputField(
                controller: usernameController,
                hintText: "Your User name",
                onChanged: (value) => username = value,
              ),
              SizedBox(height: size.height * 0.03,),
              RoundedInputField(
                controller: passwdController,
                hintText: "Your Password",
                onChanged: (value) => passwd = value,
              ),
              SizedBox(height: size.height * 0.03,),
              RoundedInputField(
                controller: identifierController,
                hintText: "Your Client Identifier",
                onChanged: (value) => clientIdentifier = value,
              ),
              SizedBox(height: size.height * 0.03,),
              RoundedButton(
                text: "Login",
                press: () {},
              ),


            ],
          ),
        ));
  }
}
