import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:medical_app/classes/ConsultationInfo.dart';
import 'package:medical_app/globalWidgets.dart';
import '../../SecureStorage.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../classes/PatientInfoClass.dart';
import '../../MyColors.dart';
import '../../BackEndURL.dart';
import 'package:vibration/vibration.dart';
import 'dart:ui' as ui;



class Consultations extends StatefulWidget {
  const Consultations({Key? key}) : super(key: key);

  @override
  _ConsultationsState createState() => _ConsultationsState();
}

class _ConsultationsState extends State<Consultations> {

  List<ConsultationInfo> myConsultations = List.empty(growable: true);
  late PatientInfo myPatient;
  bool dataIsFetched = false;

  Map statusColor = {
    'new' : Colors.amber,
    'paid' : Colors.green,
    'need information': Colors.red,
    'wait for doctor': Colors.yellow,
    'done': Colors.blue,
  };

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      myPatient = arguments['info'];
    });
    getMyConsultations();
  }

  Future<void> getMyConsultations() async {
    myConsultations.clear();
    String? token = await storage.read(key: 'token');
    http.Response response = await http.get(
      Uri.parse( URL+ '/api/patient/'+ myPatient.id +'/consultations'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    Map JsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200){
      List<dynamic> data = JsonResponse['data'];
      for (int i=0;i<data.length;i++){
        Map <String,dynamic> onePatient = data[i];
        String id = onePatient['id'].toString();
        String start_at = onePatient['start_at'].toString();
        String end_at = onePatient['end_at'].toString();
        String breast_feeding = onePatient['breast_feeding'].toString();
        String breast_feeding_month = onePatient['breast_feeding_month'].toString();
        String pregnant = onePatient['pregnant'].toString();
        String pregnant_month = onePatient['pregnant_month'].toString();
        String doctor_diagnosis = onePatient['doctor_diagnosis'].toString();
        String patient_complaint = onePatient['patient_complaint'].toString();
        Map <String,dynamic> status = onePatient['status'];
        String status_name = status['name'];
        myConsultations.add(new ConsultationInfo(id, start_at, end_at, breast_feeding, breast_feeding_month, pregnant, pregnant_month, doctor_diagnosis,patient_complaint,status_name));
      }
    }
    setState(() {
      dataIsFetched = true;
    });
  }

  showAlertDialog(BuildContext context,int index) {
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.no),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context)!.yes),
      onPressed:  () async {
        String? token = await storage.read(key: 'token');
        http.Response response = await http.delete(
          Uri.parse( URL+'/api/consultation/'+myConsultations[index].id),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': '*/*',
            'Connection': 'keep-alive',
            'Accept-Encoding': 'gzip, deflate, br',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 204){
          setState(() {
            myConsultations.removeAt(index);
          });
        }
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.delete),
      content: Text(AppLocalizations.of(context)!.areYouSureYouWantTo+AppLocalizations.of(context)!.delete+" "+AppLocalizations.of(context)!.thisConsultation +"?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  bool isRTL(String text) {
    return Bidi.detectRtlDirectionality(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myConsultations,style: TextStyle(color: Colors.black),),
      ),
      body: Container(
          child: dataIsFetched == false ?
          Center(
            child: CircularProgressIndicator(),
          ) :
          RefreshIndicator(
            onRefresh: ()async{
              await getMyConsultations();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: myConsultations.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, '/consultationinformation', arguments: {
                      'id': myConsultations[index].id,
                    });
                  },
                  child: Dismissible(
                    child: Card(
                        margin: EdgeInsets.all(10),
                        shadowColor: Colors.blue,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Colors.black87, Colors.blue],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          ),
                          child: Column(
                            children : [
                               Padding(
                                   padding: EdgeInsets.all(20),
                                   child: Text(AppLocalizations.of(context)!.consultation+" ("+myConsultations[index].id+")",style: TextStyle(color: Colors.amber,fontWeight: FontWeight.bold,fontSize: 25),),
                               ),
                               Padding(
                                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                                  child: Text(
                                    myConsultations[index].patient_complaint,
                                    maxLines: 5,
                                    textDirection: isRTL(myConsultations[index].patient_complaint) ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                                    style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,
                                  )
                               ),
                               Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.circle,size: 10,color: statusColor[myConsultations[index].status_name],),
                                      SizedBox(width: 4,),
                                      Text(AppLocalizations.of(context)!.consultationStatus + myConsultations[index].status_name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold,color: statusColor[myConsultations[index].status_name]),)
                                    ],
                                  ),
                              ),
                            ]
                          ),
                        )
                    ),
                    key: ValueKey(index),
                    background: Container(
                      color: Colors.amber,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10,),
                          Text(AppLocalizations.of(context)!.details,style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(AppLocalizations.of(context)!.delete,style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                          SizedBox(width: 10,),
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return false;
                    },
                    onUpdate: (details) async{
                      if (details.reached && !details.previousReached){
                        bool hasVib = await Vibration.hasVibrator() ?? false;
                        if (hasVib)
                          Vibration.vibrate(duration: 100);
                        if (details.direction == DismissDirection.startToEnd){
                          if (myPatient.gender == "Female") {
                            await Navigator.pushNamed(context, '/addconsultationfemaleinfo',arguments: {
                              'info': myPatient,
                              'consultation': myConsultations[index],
                            });
                          }
                          else {
                            await Navigator.pushNamed(context, '/addconsultationmain',arguments: {
                              'info': myPatient,
                              'consultation': myConsultations[index],
                            });
                          }
                          await getMyConsultations();
                        }
                        else {
                          showAlertDialog(context,index);
                        }
                      }
                    },
                  ),
                );
              },
            ),
          )

      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(AppLocalizations.of(context)!.newConsultation),
        onPressed: () async {
          if (myPatient.gender == "Female")
            await Navigator.pushNamed(context, '/addconsultationfemaleinfo',arguments: {
              'info': myPatient,
            });
          else
            await Navigator.pushNamed(context, '/addconsultationmain',arguments: {
              'info': myPatient,
            });
          getMyConsultations();
        },
      ),
    );
  }


}
