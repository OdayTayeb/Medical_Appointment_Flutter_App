import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/globalWidgets.dart';
import '../../SecureStorage.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../classes/PatientInfoClass.dart';
import '../../MyColors.dart';
import '../../BackEndURL.dart';
import 'package:vibration/vibration.dart';



class Patients extends StatefulWidget {
  const Patients({Key? key}) : super(key: key);

  @override
  _PatientsState createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {

  List<PatientInfo> myPatients = List.empty(growable: true);
  bool dataIsFetched = false;

  @override
  void initState() {
    super.initState();
    getMyPatients();
  }

  Future<void> getMyPatients() async {
    myPatients.clear();
    String? token = await storage.read(key: 'token');
    http.Response response = await http.get(
      Uri.parse( URL+ '/api/patient'),
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
        String name = onePatient['name'].toString();
        String birthDate = onePatient['birthDate'].toString();
        String phone = onePatient['phone'].toString();
        String work = onePatient['work'].toString();
        String address = onePatient['address'].toString();
        String gender = onePatient['gender'].toString();
        String marital = onePatient['marital'].toString();
        myPatients.add(new PatientInfo(id, name, birthDate, phone, work, address, gender, marital));
      }
    }
    setState(() {
      dataIsFetched = true;
    });
  }

  String Capitalize(String s){
    s.toLowerCase();
    return s.split(" ").map(
            (str) {
              if (str.startsWith(RegExp(r'[a-z]+$')))
                str = str.replaceRange(0, 1, str[0].toUpperCase());
              return str;
            }
    ).join(" ");
  }

  showAlertDialog(BuildContext context,String PatientName,int index) {
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
          Uri.parse( URL+'/api/patient/'+myPatients[index].id),
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
            myPatients.removeAt(index);
          });
        }
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.delete),
      content: Text(AppLocalizations.of(context)!.areYouSureYouWantTo+AppLocalizations.of(context)!.delete+" "+PatientName+"?"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectPatient,style: TextStyle(color: Colors.black),),
      ),
      body: Container(
        child: dataIsFetched == false ?
          Center(
            child: CircularProgressIndicator(),
          ) :
            ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: myPatients.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: (){

                    },
                    onLongPress: (){

                    },
                    child: Dismissible(
                      child: MyContainer(
                        Text(myPatients[index].name,style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold)),
                        Text(Capitalize(myPatients[index].work+" \u25CF "+myPatients[index].calculateAge()+" "+AppLocalizations.of(context)!.yearsOld),style: TextStyle(fontSize: 16, color: MyGreyColorDarker))
                      ),
                      key: ValueKey(index),
                      background: Container(
                          color: Colors.amber,
                          margin: EdgeInsets.all(20),
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
                        margin: EdgeInsets.all(20),
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
                            await Navigator.pushNamed(context, '/patientinformation',arguments: {
                              'info': myPatients[index],
                            });
                            await getMyPatients();
                          }
                          else {
                            showAlertDialog(context, myPatients[index].name,index);
                          }
                        }
                      },
                    ),
                  );
                },
            )

      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(AppLocalizations.of(context)!.addNewPatient),
        onPressed: () async {
          await Navigator.pushNamed(context, '/addpatient1');
          getMyPatients();
        },
      ),
    );
  }


}
