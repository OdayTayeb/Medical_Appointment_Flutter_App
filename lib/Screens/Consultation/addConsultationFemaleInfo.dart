import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medical_app/classes/PatientInfoClass.dart';
import 'package:medical_app/globalWidgets.dart';
import '../../MyColors.dart';

class addConsultationFemaleInfo extends StatefulWidget {
  const addConsultationFemaleInfo({Key? key}) : super(key: key);

  @override
  _addConsultationFemaleInfoState createState() =>
      _addConsultationFemaleInfoState();
}

class _addConsultationFemaleInfoState extends State<addConsultationFemaleInfo> {

  late PatientInfo myPatient;
  bool valuesIsInit = false;
  List<bool> _isOpen = [false, false];

  double PregnancyMonth = 3;
  TextEditingController BreastFeedMonth = TextEditingController(text: "6");

  @override
  Widget build(BuildContext context) {

    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    if (arguments['info'] != null && !valuesIsInit) {
      myPatient = arguments['info'];
      valuesIsInit = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!.add +
                " " +
                AppLocalizations.of(context)!.newConsultation,
            style: TextStyle(color: Colors.black)),
      ),
      body: Column(
              children: [
                Pregnant(),
                BreastFeeding(),
                NextButton(),
              ]
        ),
      );
  }

  Widget Pregnant(){
    return ExpansionTile(
      title: Text(
        AppLocalizations.of(context)!.pregnant,
        style: TextStyle(color: _isOpen[0] ? Colors.green : Colors.red),
      ),
      trailing: _isOpen[0]
          ? Icon(
        CupertinoIcons.check_mark_circled_solid,
        color: Colors.green,
      )
          : Icon(
        CupertinoIcons.clear_circled_solid,
        color: Colors.red,
      ),
      onExpansionChanged: (expanded) {
        setState(() {
          _isOpen[0] = expanded;
        });
      },
      leading: Icon(
        Icons.label,
        color: Colors.black,
      ),
      children: [
        MyContainer(
          Text(AppLocalizations.of(context)!.pregnancyMonth,style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold),),
          Slider(
              min: 1,
              max: 9,
              value: PregnancyMonth,
              divisions: 8,
              label: PregnancyMonth.round().toString(),
              onChanged: (newVal) {
                setState(() {
                  PregnancyMonth = newVal;
                });
              }),
        ),
      ],
    );
  }

  Widget BreastFeeding(){
    return ExpansionTile(
      title: Text(
        AppLocalizations.of(context)!.breastFeeding,
        style: TextStyle(color: _isOpen[1] ? Colors.green : Colors.red),
      ),
      trailing: _isOpen[1]
          ? Icon(
        CupertinoIcons.check_mark_circled_solid,
        color: Colors.green,
      )
          : Icon(
        CupertinoIcons.clear_circled_solid,
        color: Colors.red,
      ),
      onExpansionChanged: (expanded) {
        setState(() {
          _isOpen[1] = expanded;
        });
      },
      leading: Icon(
        Icons.label,
        color: Colors.black,
      ),
      children: [
        MyContainer(
            Text(AppLocalizations.of(context)!.breastFeedingMonth,style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold),),
            SizedBox(
                width: 100,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: BreastFeedMonth,
                  cursorColor: Colors.black,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BreastFeedMonth.text ==""? BorderSide(color: Colors.blueAccent,): BorderSide.none,
                    ),
                    focusedBorder:OutlineInputBorder(
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
        )
      ],
    );
  }

  Widget NextButton(){
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: (){
              Navigator.pushNamed(context, '/addconsultationmain',arguments: {
                'info': myPatient,
                'pregnant': _isOpen[0] ? "1": "0",
                'pregnancy_month': PregnancyMonth.toString(),
                'breast_feeding': _isOpen[1] ? "1" : "0",
                'breast_feeding_month': BreastFeedMonth.text,
              });
            },
            child: Text(AppLocalizations.of(context)!.next),
          ),
        ),
      ),
    );
  }
}
