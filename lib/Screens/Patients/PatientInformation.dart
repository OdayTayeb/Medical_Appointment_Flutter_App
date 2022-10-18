import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medical_app/MyColors.dart';
import 'package:medical_app/classes/PatientInfoClass.dart';
import 'package:medical_app/globalWidgets.dart';


class PatientInformationSecreen extends StatelessWidget {
  const PatientInformationSecreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    PatientInfo info = arguments['info'];

    List <String> patient = [info.phone,info.address,info.work,info.gender,info.birthDate,info.martial];
    List <String> patientFieldNames = [AppLocalizations.of(context)!.phoneNumber,AppLocalizations.of(context)!.address,AppLocalizations.of(context)!.work,AppLocalizations.of(context)!.gender,AppLocalizations.of(context)!.dateOfBirth,AppLocalizations.of(context)!.maritalStatus];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.blueAccent,
              height: MediaQuery.of(context).size.height/2,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(info.name,style: TextStyle(color: Colors.white,fontSize: 32,fontWeight: FontWeight.bold),),
                  SizedBox(height: 20,),
                  Text(info.calculateAge()+" "+AppLocalizations.of(context)!.yearsOld,style:TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold) ,),
                ],
              )
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height/3.2,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  itemBuilder: (BuildContext context, int index){
                      return MyContainer.anotherConstructor(
                        Text(patientFieldNames[index],style: TextStyle(color: MyGreyColorDarker,fontSize: 18,fontWeight: FontWeight.bold)),
                        Text(patient[index],style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold)),
                        MediaQuery.of(context).size.height/3,
                        MediaQuery.of(context).size.width/2
                      );
                  },
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton(onPressed: () async {
                    await Navigator.pushNamed(context, '/addpatient1',arguments: {
                      'isEdit': true,
                      'info': info,
                    });
                    Navigator.pop(context);
                  }, child: Text(AppLocalizations.of(context)!.edit,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
