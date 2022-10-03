import 'package:flutter/material.dart';
import 'package:medical_app/classes/PatientInfoClass.dart';
import 'package:medical_app/globalWidgets.dart';
import '../../MyColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../SecureStorage.dart';
import '../../BackEndURL.dart';


class addPatient2 extends StatefulWidget {
  const addPatient2({Key? key}) : super(key: key);

  @override
  _addPatient2State createState() => _addPatient2State();
}

class _addPatient2State extends State<addPatient2> {


  String nameInput="";
  String phoneNumberInput="";
  String addressInput="";

  TextEditingController workController = TextEditingController(text: "");
  DateTime birthdateInput = DateTime.now();

  Map genderMap = {
    "Male" : 0,
    "Female" : 1,
  };

  Map martialMap = {
    "single" : 0,
    "married" : 1,
    "divorced": 2
  };

  String genderInput="Male";
  String marriedInput="married";

  var genderBorderWidths = [4.0,0.0];
  var maritalBorderWidths = [0.5,4.0,0.5];

  late PatientInfo info;

  bool doneButtonClicked = false;

  bool valuesIsInit = false;

  @override
  Widget build(BuildContext context) {

    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    nameInput = arguments['name'];
    phoneNumberInput = arguments['phone'];
    addressInput = arguments['address'];

    if (arguments['isEdit'] != null && !valuesIsInit) {
      info = arguments['info'];
      workController = TextEditingController(text:info.work);
      birthdateInput = DateTime.parse(info.birthDate);
      genderInput = info.gender;
      marriedInput = info.martial;

      for (int i=0;i<2;i++)
        genderBorderWidths[i] = 0.5;
      genderBorderWidths[genderMap[genderInput]] = 4;

      for (int i=0;i<3;i++)
        maritalBorderWidths[i] = 0.5;
      maritalBorderWidths[martialMap[marriedInput]] = 4;

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
              Work(),
              Birthdate(),
              Gender(),
              MartialStatus(),
              DoneButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget Work(){
    return MyContainer(
        Text(AppLocalizations.of(context)!.work,style: TextStyle(fontSize: 20,color: MyGreyColorDarker),),
        SizedBox(
            width: 250,
            child: TextField(
              controller: workController,
              cursorColor: Colors.black,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterYour+AppLocalizations.of(context)!.work,
                hintStyle: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: workController.text==""? BorderSide(color: Colors.blueAccent,): BorderSide.none,
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


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: birthdateInput,
        firstDate: DateTime(1900, 8),
        lastDate: DateTime(2100));
    if (picked != null && picked != birthdateInput) {
      setState(() {
        birthdateInput = picked;
      });
    }
  }

  String dateFormater(DateTime d){
    final DateFormat formatter = DateFormat('yyyy/MM/dd');
    final String formatted = formatter.format(d);
    return formatted;
  }

  Widget Birthdate(){
    return MyContainer(
        Text(AppLocalizations.of(context)!.dateOfBirth,style: TextStyle(fontSize: 20,color: MyGreyColorDarker),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dateFormater(birthdateInput),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 20,),
            IconButton(
              icon: Icon(Icons.calendar_today,size: 40,),
              onPressed: (){
                _selectDate(context);
              },
            ),
          ],
        )
    );
  }

  Widget Gender(){
    return MyContainer(
        Text(AppLocalizations.of(context)!.gender,style: TextStyle(fontSize: 20,color: MyGreyColorDarker),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
              child: Column(
                children: [
                  Icon(Icons.male,size: 40,color: Colors.black,),
                  Text(AppLocalizations.of(context)!.male,style: TextStyle(color: Colors.black),),
                ],
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all( EdgeInsets.all(12) ),
                side: MaterialStateProperty.all(BorderSide(color: Colors.black, width: genderBorderWidths[0])),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(color: Colors.red)
                  )
                )
              ),
              onPressed: (){
                setState(() {
                  genderBorderWidths[0] = 4.0;
                  genderBorderWidths[1] = 0.5;
                });
                genderInput = "Male";
              },
            ),
            SizedBox(width: 20,),
            TextButton(
              child: Column(
                children: [
                  Icon(Icons.female,size: 40,color: Colors.black,),
                  Text(AppLocalizations.of(context)!.female,style: TextStyle(color: Colors.black),),
                ],
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all( EdgeInsets.all(12) ),
                side: MaterialStateProperty.all(BorderSide(color: Colors.black, width: genderBorderWidths[1])),
                shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(color: Colors.red)
                        )
                )
              ),
              onPressed: (){
                setState(() {
                  genderBorderWidths[0] = 0.5;
                  genderBorderWidths[1] = 4.0;
                });
                genderInput = "Female";
              },
            ),
          ],
        )
    );
  }

  Widget MartialStatus(){
    return MyContainer(
        Text(AppLocalizations.of(context)!.maritalStatus,style: TextStyle(fontSize: 20,color: MyGreyColorDarker),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.single,style: TextStyle(color: Colors.black),),
              style: ButtonStyle(
                  padding: MaterialStateProperty.all( EdgeInsets.all(12) ),
                  side: MaterialStateProperty.all(BorderSide(color: Colors.black, width: maritalBorderWidths[0])),
                  shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.red)
                      )
                  )
              ),
              onPressed: (){
                setState(() {
                  maritalBorderWidths[0] = 4.0;
                  maritalBorderWidths[1] = 0.5;
                  maritalBorderWidths[2] = 0.5;
                });
                marriedInput = "single";
              },
            ),
            SizedBox(width: 20,),
            TextButton(
              child: Text(AppLocalizations.of(context)!.married,style: TextStyle(color: Colors.black),),
              style: ButtonStyle(
                  padding: MaterialStateProperty.all( EdgeInsets.fromLTRB(16,12,16,12) ),
                  side: MaterialStateProperty.all(BorderSide(color: Colors.black, width: maritalBorderWidths[1])),
                  shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.red)
                      )
                  )
              ),
              onPressed: (){
                setState(() {
                  maritalBorderWidths[0] = 0.5;
                  maritalBorderWidths[1] = 4.0;
                  maritalBorderWidths[2] = 0.5;
                });
                marriedInput = "married";
              },
            ),
            SizedBox(width: 20,),
            TextButton(
              child: Text(AppLocalizations.of(context)!.divorced,style: TextStyle(color: Colors.black),),
              style: ButtonStyle(
                  padding: MaterialStateProperty.all( EdgeInsets.all(12) ),
                  side: MaterialStateProperty.all(BorderSide(color: Colors.black, width: maritalBorderWidths[2])),
                  shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.red)
                      )
                  )
              ),
              onPressed: (){
                setState(() {
                  maritalBorderWidths[0] = 0.5;
                  maritalBorderWidths[1] = 0.5;
                  maritalBorderWidths[2] = 4;
                });
                marriedInput = "divorced";
              },
            ),
          ],
        )
    );
  }

  Widget DoneButton(){
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
          onPressed: doneButtonClicked? null: () async{
            setState(() {
              doneButtonClicked = true;
            });
            String? token = await storage.read(key: 'token');
            http.Response response;
            if (!valuesIsInit) {
              response = await http.post(
                Uri.parse(URL + '/api/patient'),
                headers: <String, String>{
                'Content-Type': 'application/json',
                'Accept': '*/*',
                'Connection': 'keep-alive',
                'Accept-Encoding': 'gzip, deflate, br',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                },
                body: jsonEncode(<String, String>{
                "name": nameInput,
                "phone": phoneNumberInput,
                "address": addressInput,
                "gender": genderMap[genderInput].toString(),
                "marital": martialMap[marriedInput].toString(),
                "work": workController.text,
                "birthDate": dateFormater(birthdateInput),
                }),
              );
            }
            else {
              response = await http.put(
                Uri.parse(URL + '/api/patient/'+info.id),
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  'Accept': '*/*',
                  'Connection': 'keep-alive',
                  'Accept-Encoding': 'gzip, deflate, br',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode(<String, String>{
                  "name": nameInput,
                  "phone": phoneNumberInput,
                  "address": addressInput,
                  "gender": genderMap[genderInput].toString(),
                  "marital": martialMap[marriedInput].toString(),
                  "work": workController.text,
                  "birthDate": dateFormater(birthdateInput),
                }),
              );
            }
            Map JsonResponse = jsonDecode(response.body);
            if (response.statusCode == 201 || response.statusCode == 200) {
              Navigator.pop(context);
              Navigator.pop(context);
            }
            else {
              print(JsonResponse);
            }
            setState(() {
              doneButtonClicked = false;
            });
          },
          child: doneButtonClicked? CircularProgressIndicator(color: Colors.white,) : Text(AppLocalizations.of(context)!.done)
      ),
    );
  }
}
