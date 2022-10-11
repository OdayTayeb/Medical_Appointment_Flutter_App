import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medical_app/Screens/Consultation/addConsultationMain.dart';
import 'Screens/Authentication/SignUp.dart';
import 'Screens/Authentication/SignIn.dart';
import 'Screens/Patients/Patients.dart';
import 'Screens/Patients/addPatient.dart';
import 'Screens/Patients/addPatient2.dart';
import 'Screens/Patients/PatientInformation.dart';
import 'Screens/Consultation/Consultations.dart';
import 'Screens/Consultation/addConsultationFemaleInfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context)  {

    return MaterialApp(
      // For Internationalization (Arabic and English)
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      locale: Locale('en',''),
      // routing
      routes: {
        '/signup': (context) => SignUp(),
        '/signin': (context) => SignIn(),
        '/patients': (context) => Patients(),
        '/addpatient1': (context) => addPatient1(),
        '/addpatient2': (context) => addPatient2(),
        '/patientinformation': (context) => PatientInformationSecreen(),
        '/consultations': (context) => Consultations(),
        '/addconsultationmain': (context) => addConsultationMain(),
        '/addconsultationfemaleinfo': (context) => addConsultationFemaleInfo(),
      },
      initialRoute: '/signup',
      // Theme
      theme: ThemeData.light().copyWith(
        backgroundColor: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                )
            ),
            minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
          )
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          textTheme: TextTheme(headline6: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.w500)),
          elevation: 0,
        )
      ),
    );
  }
}


