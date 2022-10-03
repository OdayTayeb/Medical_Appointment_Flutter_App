import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medical_app/globalWidgets.dart';
import 'package:flutter/cupertino.dart';
import '../../SecureStorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../DeviceName.dart';
import '../../BackEndURL.dart';



class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  // This is The content of the Text fields
  String emailInput="";
  String passwordInput="";

  // This is the message shown after failing to sign In
  String message="";

  // This is true when signIn button is clicked
  bool signInClicked = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    SizedBox(height: 50,),
                    logoImage(),
                    SizedBox(height: 50,),
                    LoginToYourAccountText(),
                    SizedBox(height: 30,),
                    Email(),
                    Password(),
                    SizedBox(height: 40,),
                    signInButton(),
                    messageText(),
                    forgetPasswordButton(),
                    SizedBox(height: 60,),
                    dontHaveAnAccountText(),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              )
        )
    );
  }

  Widget logoImage(){
    return ConstrainedBox(constraints: BoxConstraints.tight(Size(140,140)),child: Image.asset('images/logo.png'));
  }

  Widget LoginToYourAccountText(){
    return Text(
      AppLocalizations.of(context)!.loginToYourAccount,
      style: TextStyle(
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget Email(){
    return MyTextField(
        AppLocalizations.of(context)!.email,
        Icon(CupertinoIcons.envelope,color: Colors.grey),
        false,
            (newVal)=>{  setState((){ emailInput = newVal;}) }
    );
  }

  Widget Password(){
    return MyTextField(
        AppLocalizations.of(context)!.password,
        Icon(CupertinoIcons.lock,color: Colors.grey),
        true,
        (newVal)=>{  setState((){ passwordInput = newVal;}) }
    );
  }

  Widget signInButton(){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        onPressed: signInClicked ? null : () async {

          setState(() {
            signInClicked = true;

            // Front End Validation

            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailInput))
              message = AppLocalizations.of(context)!.invalidEmail;
            else if (passwordInput.length < 8)
              message = AppLocalizations.of(context)!.shortPassword;
            else
              message = "";

          });

          if (message=="") {
            try {
              String deviceName = await DeviceName();
              http.Response response = await http.post(
                Uri.parse(URL+'/api/auth/login'),
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  'Accept': '*/*',
                  'Connection': 'keep-alive',
                  'Accept-Encoding': 'gzip, deflate, br',
                  'Accept': 'application/json',

                },
                body: jsonEncode(<String, String>{
                  "email": emailInput,
                  "password": passwordInput,
                  "device_name": deviceName,
                }),
              );
              Map JsonResponse = jsonDecode(response.body);
              if (response.statusCode == 200) {
                await storage.write(key: 'token', value: JsonResponse['token']);
                Navigator.pushNamed(context, '/patients');
              }
              else {
                Map<String, dynamic> errors = JsonResponse['errors'];
                setState(() {
                  message = errors[ errors.keys.toList()[0] ].toString();
                });
              }
            }
            catch(e){
              setState(() {
                message = "Error connecting to server";
              });
            }
          }
          setState(() {
            signInClicked = false;
          });
        },
        child: signInClicked? CircularProgressIndicator(color: Colors.white,): Text(AppLocalizations.of(context)!.signIn),
      ),
    );
  }

  Widget messageText(){
    return Text(message,style: TextStyle(color: Colors.red),);
  }

  Widget forgetPasswordButton(){
    return TextButton(
        onPressed: ()=>{},
        child: Text(AppLocalizations.of(context)!.forgotPassword,
        ));
  }

  Widget dontHaveAnAccountText(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.dontHaveAccount,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15.0,
          ),
        ),
        TextButton(onPressed: ()=>{Navigator.pop(context)}, child: Text(AppLocalizations.of(context)!.signUp,style: TextStyle(fontSize: 16),)),
      ],
    );
  }
}


