
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medical_app/SecureStorage.dart';
import 'package:medical_app/classes/ConsultationInfo.dart';
import 'package:medical_app/classes/PatientInfoClass.dart';
import 'package:medical_app/globalWidgets.dart';
import '../../MyColors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../BackEndURL.dart';
import 'dart:convert';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';


class addConsultationMain extends StatefulWidget {
  const addConsultationMain({Key? key}) : super(key: key);

  @override
  _addConsultationMainState createState() => _addConsultationMainState();
}

class _addConsultationMainState extends State<addConsultationMain> {

  TextEditingController DescriptionController =TextEditingController(text: "");
  List <Widget> ImageWidgets = [];
  List <Widget> PdfWidgets = [];
  List <XFile> selectedImages = [];
  List <File> selectedPdfs = [];
  bool valuesIsInit = false;
  FlutterSoundRecorder myRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer myPlayer = FlutterSoundPlayer();
  double sliderPosition = 0;
  bool recordIsReady = false;
  bool recordIsBeingPlayed = false;
  bool isEdit = false;
  bool isDoneButtonClicked = false;

  late PatientInfo myPatient;
  late ConsultationInfo myConsultation;
  String isPregnant = "0";
  String pregnancyMonth = "0";
  String isBreastFeed = "0";
  String breastFeedMonth = "0";


  @override
  void initState() {
    super.initState();
    InitVoiceRecorderAndPlayer();
    InitImageSelector();
    InitPdfSelector();

  }

  @override
  void dispose() {
    myRecorder.closeRecorder();
    myPlayer.closePlayer();
    super.dispose();
  }

  Future <void> InitVoiceRecorderAndPlayer() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted)
      throw RecordingPermissionException('Microphone permission not granted');

    myRecorder.openRecorder();
    myPlayer.openPlayer();
    myPlayer.setSubscriptionDuration(Duration(milliseconds: 100));
  }

  void InitPdfSelector(){
    PdfWidgets.add(
      TextButton(
        child: Icon(Icons.add,color: Colors.black ,),
        onPressed: () async {
          FilePickerResult? _picker = await FilePicker.platform.pickFiles(allowMultiple: true,type: FileType.custom, allowedExtensions: ['pdf'],);
          if (_picker == null) return;
          List<File> files = _picker.paths.map((p) => File(p!)).toList();
          for (int i=0;i<files!.length;i++) {
            File cur = files[i];
            selectedPdfs.add(cur);
            PdfWidgets.add(
                Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 10,right: 10),
                        child: InkWell(
                          onTap: (){
                            int i;
                            for (i = 1; i < selectedPdfs.length + 1; i++)
                              if (cur.path == selectedPdfs[i - 1].path)
                                break;
                            setState(() {
                              selectedPdfs.removeAt(i-1);
                              PdfWidgets.removeAt(i);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(1),
                            height: 85,
                            width: 85,
                            decoration: BoxDecoration(color: MyGreyColorDarker, borderRadius: BorderRadius.circular(20)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  Image.asset('images/pdf.png',width: 100,height: 100,fit: BoxFit.cover,),
                                  Padding(padding: EdgeInsets.all(4), child: Icon(CupertinoIcons.clear_circled_solid,color: Colors.red,),),
                                ],
                              ),
                            ),
                          ),
                        )
                    ),
                    Container(height: 15, width: 80,child: Center(child: Text(cur.uri.pathSegments.last,maxLines: 1,style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis,)))
                  ],
                )
            );
          }
          setState(() {

          });
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              side: BorderSide(color: MyGreyColorDarker),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          minimumSize: MaterialStateProperty.all(Size(100,100)),
        ),
      ),
    );
  }

  void InitImageSelector(){
    ImageWidgets.add(
      TextButton(
        child: Icon(Icons.add,color: Colors.black ,),
        onPressed: () async {
          final ImagePicker _picker = ImagePicker();
          final List<XFile>? images = await _picker.pickMultiImage();
          int n = ImageWidgets.length;
          for (int i=0;i<images!.length;i++) {
            XFile f = images[i];
            selectedImages.add(f);
            File F = File(f.path);
            ImageWidgets.add(
                Padding(
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                      onTap: (){
                        int i;
                        for (i = 1; i < selectedImages.length + 1; i++)
                          if (f.path == selectedImages[i - 1].path)
                            break;
                        setState(() {
                          selectedImages.removeAt(i-1);
                          ImageWidgets.removeAt(i);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(1),
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(color: MyGreyColorDarker, borderRadius: BorderRadius.circular(20)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Image.file(F,width: 100,height: 100,fit: BoxFit.cover,),
                              Padding(padding: EdgeInsets.all(4), child: Icon(CupertinoIcons.clear_circled_solid,color: Colors.red,),),
                            ],
                          ),
                        ),
                      ),
                    )
                )
            );
          }
          setState(() {

          });
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              side: BorderSide(color: MyGreyColorDarker),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          minimumSize: MaterialStateProperty.all(Size(100,100)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    if (!valuesIsInit) {
      myPatient = arguments['info'];
      isPregnant = arguments['pregnant'] ?? "0";
      pregnancyMonth = arguments['pregnancy_month'] ?? "0";
      isBreastFeed = arguments['breast_feeding'] ?? "0";
      breastFeedMonth = arguments['breast_feeding_month'] ?? "0";

      if (isPregnant == "0")
        pregnancyMonth = "0";

      if (isBreastFeed == "0")
        breastFeedMonth = "0";

      if (arguments['consultation'] != null){
        myConsultation = arguments['consultation'];
        DescriptionController.text = myConsultation.patient_complaint;
        isEdit = true;
      }


      valuesIsInit = true;
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.consultationInformation,style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Description(),
              if (!isEdit) Text(AppLocalizations.of(context)!.uploadedImages,style: TextStyle(color: Colors.black,)),
              if (!isEdit) ImageSelector(),
              if (!isEdit) Text(AppLocalizations.of(context)!.uploadedPdfs,style: TextStyle(color: Colors.black,)),
              if (!isEdit) PdfSelector(),
              if (!isEdit) VoiceRecorder(),
              DoneButton()
            ],
          ),
        ),
    );
  }

  Widget Description(){
    return MyContainer.anotherConstructor(
        Text(AppLocalizations.of(context)!.problemDescription,style: TextStyle(fontSize: 20,color: MyGreyColorDarker),),
        SizedBox(
            width: 250,
            height: MediaQuery.of(context).size.height/7,
            child: Center(
              child: TextField(
                  controller: DescriptionController,
                  cursorColor: Colors.black,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterYour+AppLocalizations.of(context)!.problemDescription,
                    hintStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: DescriptionController.text ==""? BorderSide(color: Colors.blueAccent,): BorderSide.none,
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
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
            ),
        ),
        MediaQuery.of(context).size.height/4,
        MediaQuery.of(context).size.width
    );
  }



  Widget ImageSelector(){
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: ImageWidgets,
                ),
            ),
        ),
    );
  }

  Widget PdfSelector(){
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: PdfWidgets,
          ),
        ),
      ),
    );
  }

  Widget VoiceRecorder(){
    return Container(
      margin: EdgeInsets.all(20),
      color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: Colors.black12,
            child: IconButton(
                onPressed: recordIsReady ? () async {
                  showAlertDialog(context);
                } : null,
                icon: Icon(Icons.delete)
            ),
          ),
          Container(
            color: Colors.black38,
            child: IconButton(
                onPressed: recordIsReady ? () async {
                  if (myPlayer.isPlaying) {
                    myPlayer.pausePlayer();
                    setState(() {
                      recordIsBeingPlayed = false;
                    });
                  }
                  else {
                    if (!myPlayer.isPaused)
                      myPlayer.startPlayer(
                          fromURI: 'myRecord',
                          whenFinished: (){
                            setState(() {
                              sliderPosition = 0;
                              recordIsBeingPlayed = false;
                            });
                          }
                      );
                    else myPlayer.resumePlayer();
                    setState(() {
                      recordIsBeingPlayed = true;
                    });
                  }
                  myPlayer.onProgress!.listen(
                          (e) {
                        Duration maxDuration = e.duration;
                        Duration position = e.position;
                        int md = maxDuration.inMilliseconds;
                        int p = position.inMilliseconds;
                        double val = (p/md).toDouble();
                        setState(() {
                          sliderPosition =  val;
                        });
                      }
                  );
                } : null,
                icon: Icon(recordIsBeingPlayed ? Icons.pause : Icons.play_arrow)
            ),
          ),
          Expanded(
            child: Slider(
              min: 0,
              max: 1,
              value: sliderPosition,
              onChanged: recordIsReady ? (newValue) async {
                var progress = await (myPlayer.getProgress());
                Duration? maxDuration = progress['duration'];
                int maxDurationMS = maxDuration!.inMilliseconds;
                setState(() {
                  sliderPosition = newValue;
                });
                int curMS = (sliderPosition * maxDurationMS).toInt();
                Duration newPos = Duration(milliseconds: curMS );
                myPlayer.seekToPlayer(newPos);
              } : null,
              activeColor: Colors.black,
              inactiveColor: Colors.white,
            ),
          ),
          Container(
            color: Colors.black38,
            child: IconButton(

                onPressed: recordIsBeingPlayed ? null : () async {
                  if (myRecorder.isRecording) {
                    await myRecorder.stopRecorder();
                    setState(() {
                      recordIsReady = true;
                    });
                  }
                  else if (!myRecorder.isRecording) {
                    await myRecorder.startRecorder(toFile: 'myRecord');
                    setState(() {
                      recordIsReady = false;
                    });
                  }
                },
                icon: Icon(myRecorder.isRecording ? Icons.stop_sharp : Icons.mic  ,color: Colors.black,)
            ),
          ),
        ],
      ),
    );
  }

  Widget DoneButton(){
    return Padding(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: isDoneButtonClicked == false ? ()async{
            setState(() {
              isDoneButtonClicked = true;
            });
            if (isEdit){
              String? token = await storage.read(key: 'token');
              http.Response response;
              response = await http.put(
                Uri.parse(URL + '/api/consultation/'+myConsultation.id),
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  'Accept': '*/*',
                  'Connection': 'keep-alive',
                  'Accept-Encoding': 'gzip, deflate, br',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode(<String, String>{
                  'breast_feeding' : isBreastFeed,
                  'breast_feeding_month': breastFeedMonth,
                  'pregnant' : isPregnant,
                  'pregnant_month' : pregnancyMonth,
                  'patient_complaint' : DescriptionController.text,
                }),
              );
              if (response.statusCode == 200) {
                if (myPatient.gender == "Female")
                  Navigator.pop(context);
                Navigator.pop(context);
              }
              else {
                print(response.statusCode);
                print(response.body);
              }
              setState(() {
                isDoneButtonClicked = false;
              });
              return;
            }
            String? recordPath = await myRecorder.getRecordURL(path: 'myRecord');
            String? token = await storage.read(key: 'token');
            var request = new http.MultipartRequest("POST", Uri.parse(URL + '/api/consultation'));
            request.headers['Authorization'] = 'Bearer ' + token!;
            request.headers['Accept'] =  '*/*';
            request.headers['Accept'] =  'application/json';
            request.fields['patient_id'] = myPatient.id;
            request.fields['breast_feeding'] = isBreastFeed;
            request.fields['breast_feeding_month'] = breastFeedMonth;
            request.fields['pregnant'] = isPregnant;
            request.fields['pregnant_month'] = pregnancyMonth;
            request.fields['patient_complaint'] = DescriptionController.text;
            for (XFile image in selectedImages)
              request.files.add(await http.MultipartFile.fromPath('photos[]', image.path ));
            for (File pdf in selectedPdfs)
              request.files.add(await http.MultipartFile.fromPath('pdf[]', pdf.path ));
            if (recordIsReady)
              request.files.add(
                  await http.MultipartFile.fromPath('audios[]', recordPath!));
            var response = await request.send();
            if (response.statusCode == 201) {
              if (myPatient.gender == "Female")
                Navigator.pop(context);
              Navigator.pop(context);
            }
            else print(await response.stream.bytesToString());
            setState(() {
              isDoneButtonClicked = false;
            });
          } : null,
          child: isDoneButtonClicked ? CircularProgressIndicator(color: Colors.white,) : Text(AppLocalizations.of(context)!.done),
        ),
    );
  }


  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.no),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context)!.yes),
      onPressed:  () async {
        myRecorder.deleteRecord(fileName: 'myRecord');
        setState(() {
          recordIsReady = false;
          sliderPosition = 0;
        });
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.delete),
      content: Text(AppLocalizations.of(context)!.areYouSureYouWantTo+AppLocalizations.of(context)!.delete+" "+AppLocalizations.of(context)!.theRecord +"?"),
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

}
