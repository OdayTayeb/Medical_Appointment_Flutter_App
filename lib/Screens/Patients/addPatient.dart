import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/classes/PatientInfoClass.dart';
import '../../MyColors.dart';
import 'package:medical_app/globalWidgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class addPatient1 extends StatefulWidget {
  const addPatient1({Key? key}) : super(key: key);

  @override
  _addPatient1State createState() => _addPatient1State();
}

class _addPatient1State extends State<addPatient1> {

  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");

  String message="";

  bool valuesIsInit = false;
  late PatientInfo info;

  @override
  Widget build(BuildContext context) {

    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    if (arguments['isEdit'] != null && !valuesIsInit) {
      info = arguments['info'];
      nameController = TextEditingController(text: info.name);
      phoneController = TextEditingController(text: info.phone);
      addressController = TextEditingController(text: info.address);
      valuesIsInit = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addNewPatient,style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 70,),
                fillInformationText(),
                SizedBox(height: 30,),
                Name(),
                PhoneNumber(),
                Address(),
                messageText(),
                NextButton(),
              ],
            ),
        ),
      ),
    );
  }

  Widget fillInformationText(){
    return Text(
      AppLocalizations.of(context)!.fillTheInformation,
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget Name(){
    return MyContainer(
      Text(AppLocalizations.of(context)!.name,style: TextStyle(fontSize: 20,color: MyGreyColorDarker),),
      SizedBox(
          width: 250,
          child: TextField(
            controller: nameController,
            cursorColor: Colors.black,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enterYour+AppLocalizations.of(context)!.name,
              hintStyle: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: nameController.text ==""? BorderSide(color: Colors.blueAccent,): BorderSide.none,
              ),
              focusedBorder:UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
              ),
            ),
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          )
      )
    );

  }

  Widget PhoneNumber(){
    return MyContainer(
        Text(AppLocalizations.of(context)!.phoneNumber,style: TextStyle(fontSize: 20,color: MyGreyColorDarker),),
        SizedBox(
            width: 250,
            child: TextField(
              controller: phoneController,
              cursorColor: Colors.black,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterYour+AppLocalizations.of(context)!.phoneNumber,
                hintStyle: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: phoneController.text==""? BorderSide(color: Colors.blueAccent,): BorderSide.none,
                ),
                focusedBorder:UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                ),
              ),
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )
        )
    );
  }

  Widget Address(){
    return MyContainer(
        Text(AppLocalizations.of(context)!.address,style: TextStyle(fontSize: 20,color: MyGreyColorDarker),),
        SizedBox(
            width: 250,
            child: TextField(
              controller: addressController,
              cursorColor: Colors.black,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterYour+AppLocalizations.of(context)!.address,
                hintStyle: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: addressController.text==""? BorderSide(color: Colors.blueAccent,): BorderSide.none,
                ),
                focusedBorder:UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                ),
              ),
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )
        )
    );
  }

  Widget messageText(){
    return Text(message,style: TextStyle(color: Colors.red),);
  }

  Widget NextButton(){
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
          onPressed: (){
            // Front End Validation
            RegExp regExp = RegExp(r'^[0-9]{10}$');
            if (!regExp.hasMatch(phoneController.text)) {
              setState(() {
                message = AppLocalizations.of(context)!.invalidPhoneNumber;
              });
            }
            else {
              setState(() {
                message = "";
              });
              if (valuesIsInit) {
                Navigator.pushNamed(context, '/addpatient2', arguments: {
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'address': addressController.text,
                  'info': info,
                  'isEdit':true,
                });
              }
              else{
                Navigator.pushNamed(context, '/addpatient2', arguments: {
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'address': addressController.text,
                });
              }
            }
          },
          child: Text(AppLocalizations.of(context)!.next)
      ),
    );
  }
}
