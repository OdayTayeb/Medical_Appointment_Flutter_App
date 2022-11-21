
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_app/BackEndURL.dart';
import 'package:medical_app/MyColors.dart';
import 'package:bubble/bubble.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/classes/RequestAttachmentInfo.dart';
import 'package:medical_app/classes/RequestInfo.dart';
import 'package:medical_app/globalWidgets.dart';
import '../../SecureStorage.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';


class ConsultationInformation extends StatefulWidget {
  const ConsultationInformation({Key? key}) : super(key: key);

  @override
  _ConsultationInformationState createState() =>
      _ConsultationInformationState();
}

class _ConsultationInformationState extends State<ConsultationInformation> {
  String id = "";

  String email = "";
  String name = "";
  String age = "";
  String phone = "";
  String work = "";
  String address = "";
  String gender = "";
  String maritalStatus = "";
  String pregnant = "";
  String pregnancyMonth = "";
  String breastFeed = "";
  String breastFeedingMonth = "";
  String complaint = "";
  String startAt = "";
  String endAt = "";
  List<String> consultationImageIds = List.empty(growable: true);
  List<Uint8List> consultationImages = List.empty(growable: true);
  List<String> consultationPdfIds = List.empty(growable: true);
  List<Uint8List> consultationPdfs = List.empty(growable: true);
  String audioId ="";

  List <Object> requestAndAttachmentData = List.empty(growable: true);
  List <Widget> requestAndAttachment = List.empty(growable: true);
  bool mediaDataIsFetched = false;
  bool dataIsFetched = false;


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;
      id = arguments['id'];
    }).then((value) async {
      await FetchMainConsultation();
      setState(() {
        dataIsFetched = true;
      });
      FetchConsultationMedia().then(
        (value) {if (mounted) setState(() {mediaDataIsFetched = true;});}
      );
      FetchRequests();
    });
  }

  Future<void> FetchMainConsultation() async {
    String? token = await storage.read(key: 'token');
    http.Response response = await http.get(
      Uri.parse(URL + '/api/consultation/' + id),
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
    if (response.statusCode == 200) {
      Map<String, dynamic> x = JsonResponse['data'];
      List<dynamic> images = x['photos'];
      for (int i = 0; i < images.length; i++) {
        Map<String, dynamic> oneImage = images[i];
        consultationImageIds.add(oneImage['id'].toString());
      }
      List<dynamic> pdf = x['pdf'];
      for (int i = 0; i < pdf.length; i++) {
        Map<String, dynamic> onePdf = pdf[i];
        consultationPdfIds.add(onePdf['id'].toString());
      }
      List<dynamic> audio = x['audios'];
      if (audio.isNotEmpty) {
        Map <String,dynamic> oneAudio = audio[0];
        audioId = oneAudio['id'];
      }
      startAt = x['start_at'].toString();
      endAt = x['end_at'].toString();
      complaint = x['patient_complaint'].toString();
      pregnant = x['pregnant'].toString();
      if (pregnant == "1")
        pregnant = AppLocalizations.of(context)!.yes;
      else
        pregnant = AppLocalizations.of(context)!.no;
      pregnancyMonth = x['pregnant_month'].toString();
      if (pregnancyMonth == "0") pregnancyMonth = "-";
      breastFeed = x['breast_feeding'].toString();
      if (breastFeed == "1")
        breastFeed = AppLocalizations.of(context)!.yes;
      else
        breastFeed = AppLocalizations.of(context)!.no;
      breastFeedingMonth = x['breast_feeding_month'].toString();
      if (breastFeedingMonth == "0") breastFeedingMonth = "-";
      Map<String, dynamic> patient = x['patient'];
      name = patient['name'].toString();
      phone = patient['phone'].toString();
      address = patient['address'].toString();
      work = patient['work'].toString();
      gender = patient['gender'].toString();
      maritalStatus = patient['marital'].toString();
      String birthDate = patient['birthDate'].toString();
      age = (DateTime.now().year - DateTime.parse(birthDate).year).toString();
      Map<String, dynamic> user = x['user'];
      email = user['email'].toString();
    }
  }

  Future<void> FetchConsultationMedia() async {
    await FetchConsultationImages();
    await FetchConsultationPdfs();
  }

  Future<void> FetchConsultationImages() async {
    for (int i = 0; i < consultationImageIds.length; i++)
      consultationImages.add(await FetchOneConsultationImage(consultationImageIds[i]));
  }

  Future<Uint8List> FetchOneConsultationImage(String ImageId) async {
    String? token = await storage.read(key: 'token');
    http.Response response = await http.get(
      Uri.parse(URL + '/api/image/' + ImageId),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.bodyBytes;
  }

  Future<void> FetchConsultationPdfs() async {
    for (int i = 0; i < consultationPdfIds.length; i++)
      consultationPdfs.add(await FetchOneConsultationPdf(consultationPdfIds[i]));
  }

  Future<Uint8List> FetchOneConsultationPdf(String pdfId) async {
    String? token = await storage.read(key: 'token');
    http.Response response = await http.get(
      Uri.parse(URL + '/api/pdf/' + pdfId),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.bodyBytes;
  }

  Future<Uint8List> FetchAudio() async {
    String? token = await storage.read(key: 'token');
    http.Response response = await http.get(
      Uri.parse(URL + '/api/audio/' + audioId),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.bodyBytes;
  }

  Future <void> FetchRequests() async{
    String? token = await storage.read(key: 'token');
    http.Response response = await http.get(
      Uri.parse(URL+ '/api/' + id + '/req'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      Map JsonResponse = jsonDecode(response.body);
      List <dynamic> data = JsonResponse['data'];
      int index = 0;
      for (int i=0;i<data.length;i++){
        Map item = data[i];
        String id = item['id'].toString();
        String comment = item['comment'];
        List <String> bloodTests = List.empty(growable: true);
        List <dynamic> bt = item['bloodTests'];
        for (int j=0;j<bt.length;j++)
          bloodTests.add(bt[j]['name'].toString());
        List <String> radioTests = List.empty(growable: true);
        List <dynamic> rt = item['radiographs'];
        for (int j=0;j<rt.length;j++)
          radioTests.add(rt[j]['name'].toString());

        List <dynamic> att = item['attachments'];
        List <Uint8List> attachments = List.empty(growable: true);
        for (int j=0;j<att.length;j++) {
          String x = att[j]['id'].toString();
          attachments.add(await FetchAttachment(x));
        }
        bool isFulfilled = false;
        if (attachments.length > 0)
          isFulfilled = true;
        requestAndAttachmentData.add(RequestInfo(id,index,comment,bloodTests,radioTests,isFulfilled));
        requestAndAttachment.add(Request(requestAndAttachmentData.last as RequestInfo));
        index++;

        if (attachments.length>0) {
          requestAndAttachmentData.add(RequestAttachmentInfo(attachments, index));
          requestAndAttachment.add(Attachment(requestAndAttachmentData.last as RequestAttachmentInfo));
          index++;
        }
      }
    }
    setState(() {

    });
  }

  Future< Uint8List > FetchAttachment(String attachmentID) async{
    String? token = await storage.read(key: 'token');
    http.Response response = await http.get(
      Uri.parse(URL+ '/api/attachment/' + attachmentID),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.bodyBytes;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue.shade900,
        elevation: 2,
        title: Text(
          AppLocalizations.of(context)!.consultation + " " + id,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: dataIsFetched
          ? SingleChildScrollView(
              child: Column(
                children: [
                  MainConsultation(),
                  RequestAndAttachment(),
                ]
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  bool isRTL(String text) {
    return Bidi.detectRtlDirectionality(text);
  }

  Widget MainConsultation() {
    return Bubble(
      alignment: Alignment.topLeft,
      nip: BubbleNip.leftTop,
      nipHeight: 10,
      nipWidth: 15,
      margin: BubbleEdges.fromLTRB(10, 10, 25, 10),
      color: MyCyanColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 2,color: Colors.black,),
          Container(
              width: double.infinity,
              height: 80,
              child: Center(child: Text(AppLocalizations.of(context)!.mainConsultation,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900,fontSize: 25),))
          ),
          Divider(thickness: 2,color: Colors.black,),
          MyDivider(
              AppLocalizations.of(context)!.pateintInformation, Colors.black),
          Text(AppLocalizations.of(context)!.userEmail + email + "\n" +
              AppLocalizations.of(context)!.patientName + name + "\n" +
              AppLocalizations.of(context)!.age + age + " " +
              AppLocalizations.of(context)!.yearsOld + "\n" +
              AppLocalizations.of(context)!.phoneNumber + ": " + phone + "\n" +
              AppLocalizations.of(context)!.work + ": " + work + "\n" +
              AppLocalizations.of(context)!.address + ": " + address + "\n" +
              AppLocalizations.of(context)!.gender + ": " + gender + "\n" +
              AppLocalizations.of(context)!.maritalStatus + ": " + maritalStatus
          ),
          if (gender == "Female")
            MyDivider(
                AppLocalizations.of(context)!
                    .pregnancyAndBreastFeedingInformation,
                Colors.black),
          if (gender == "Female")
            Text(AppLocalizations.of(context)!.pregnant + " " + pregnant + "\n" +
                AppLocalizations.of(context)!.pregnancyMonth + " " + pregnancyMonth + "\n" +
                AppLocalizations.of(context)!.breastFeeding + " " + breastFeed + "\n" +
                AppLocalizations.of(context)!.breastFeedingMonth + " " + breastFeedingMonth
            ),
          MyDivider(
              AppLocalizations.of(context)!.patientComplaint, Colors.black),
          Text(
            complaint,
            textDirection:
                isRTL(complaint) ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          ),
          MyDivider(
              AppLocalizations.of(context)!.uploadedDocuments, Colors.black),
          if (!mediaDataIsFetched)
            Center(child: CircularProgressIndicator()),
          if (mediaDataIsFetched && consultationImages.length > 0)
            Text(AppLocalizations.of(context)!.images),
          if (mediaDataIsFetched && consultationImages.length > 0 )
            Container(
            height: 100,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: consultationImages.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                          context, '/imageshow', arguments: {
                        'image': Image.memory(consultationImages[index])
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(1),
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: MyGreyColorDarker,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                consultationImages[index],
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                ),
                              ),
                          ),
                      );
                }),
          ),
          if (mediaDataIsFetched && consultationPdfs.length > 0)
            Text("PDF :"),
          if (mediaDataIsFetched && consultationPdfs.length > 0)
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: consultationPdfs.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                          context, '/pdfview', arguments: {
                          'pdf': consultationPdfs[index]
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(1),
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: MyGreyColorDarker,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'images/pdf.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,),
                        ),
                      ),
                  );
                }),
            )
        ],
      ),
    );
  }

  Widget RequestAndAttachment(){
    return Column(
      children: requestAndAttachment,
    );
  }

  Widget Request(RequestInfo R){
    List <Widget> content = List.empty(growable: true);
    content.add(Text(AppLocalizations.of(context)!.requestInformation,style: TextStyle(fontWeight: FontWeight.bold),));
    content.add(Text(AppLocalizations.of(context)!.message + R.comment));
    if (R.bloodTests.length>0) {
      content.add(Text(AppLocalizations.of(context)!.requestedBloodTests));
      for (int i=0;i<R.bloodTests.length;i++)
        content.add(Text('- '+R.bloodTests[i]));
    }
    if (R.radioTests.length>0) {
      content.add(Text(AppLocalizations.of(context)!.requestedRadioGraphTests));
      for (int i=0;i<R.radioTests.length;i++)
        content.add(Text('- '+R.radioTests[i]));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width/1.5,
          child: Bubble(
            alignment: Alignment.topRight,
            nip: BubbleNip.rightTop,
            nipHeight: 10,
            nipWidth: 15,
            margin: BubbleEdges.fromLTRB(0, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children : content,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () {
                addAttachment(R);
              },
              icon: Icon(Icons.add),
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void addAttachment(RequestInfo R) async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.length>0) {
      String? token = await storage.read(key: 'token');
      var request = new http.MultipartRequest("POST",
          Uri.parse(
              URL + '/api/request/' + R.id + '/attachment'));
      request.headers['Authorization'] = 'Bearer ' + token!;
      request.headers['Accept'] = '*/*';
      request.headers['Accept'] = 'application/json';
      for (XFile image in images)
        request.files.add(await http.MultipartFile.fromPath(
            'photos[]', image.path));
      var response = await request.send();
      if (response.statusCode == 200) {
      updateRequestAndAttachment(R.index,images);
      }
      else {
      print(response.statusCode);
      print(response.stream.bytesToString());
      }
    }
  }

  void updateRequestAndAttachment(int index,List <XFile> images) async {
    RequestInfo R = requestAndAttachmentData[index] as RequestInfo;
    R.isFulfilled = true;
    int newIndex = index+1;
    List <Uint8List> x = List.empty(growable: true);
    for (int i=0;i<images.length;i++)
      x.add(await images[i].readAsBytes());

    if (newIndex < requestAndAttachmentData.length && requestAndAttachmentData[newIndex] is RequestAttachmentInfo) {
      RequestAttachmentInfo r = requestAndAttachmentData[newIndex] as RequestAttachmentInfo;
      r.appendListOfImages(x);
      requestAndAttachment.removeAt(newIndex);
      requestAndAttachment.insert(newIndex, Attachment(r));
    }
    else {
      requestAndAttachmentData.insert(
          newIndex, RequestAttachmentInfo(x, newIndex));
      // update index in all next requestAndAttachmentData objects
      for (int i = newIndex + 1; i < requestAndAttachmentData.length; i++) {
        if (requestAndAttachmentData[i] is RequestInfo) {
          RequestInfo r = requestAndAttachmentData[i] as RequestInfo;
          r.incrementIndex();
        }
        else if (requestAndAttachmentData[i] is RequestAttachmentInfo) {
          RequestAttachmentInfo r = requestAndAttachmentData[i] as RequestAttachmentInfo;
          r.incrementIndex();
        }
      }
      // insert new (ui element) attachment to requestAndAttachment
      requestAndAttachment.insert(newIndex, Attachment(requestAndAttachmentData[newIndex] as RequestAttachmentInfo));
    }
    setState(() {

    });
  }

  Widget Attachment(RequestAttachmentInfo R){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: IconButton(
              onPressed: () async {
                RequestInfo requestInfo = requestAndAttachmentData[R.index-1] as RequestInfo;
                showAlertDialog(context, requestInfo);
              },
              icon: Icon(Icons.remove,color: Colors.white,),
            ),
          ),
        ),
        Bubble(
          alignment: Alignment.topLeft,
          nip: BubbleNip.leftTop,
          nipHeight: 10,
          nipWidth: 15,
          margin: BubbleEdges.fromLTRB(10, 10, 0, 10),
          color: MyCyanColor,
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.uploadedDocuments,style: TextStyle(fontWeight: FontWeight.bold,)),
                  Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width/1.8,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: R.images.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/imageshow', arguments: {
                                'image': Image.memory(R.images[index])
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.all(5),
                              padding: EdgeInsets.all(1),
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                color: MyGreyColorDarker,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child:
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  R.images[index],
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
          ),
        ),
      ],
    );
  }

  showAlertDialog(BuildContext context,RequestInfo R) {
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.no),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context)!.yes),
      onPressed:  () async {
        await deleteAttachments(R);
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.delete),
      content: Text(AppLocalizations.of(context)!.areYouSureYouWantTo+AppLocalizations.of(context)!.delete+" "+AppLocalizations.of(context)!.uploadedDocuments+"?"),
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

  Future<void> deleteAttachments(RequestInfo R) async {
    String? token = await storage.read(key: 'token');
    http.Response response = await http.delete(
      Uri.parse(URL+ '/api/req/' + R.id + '/attachment'),
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
      int index = R.index+1;
      for (int i=index+1;i<requestAndAttachmentData.length;i++)
      {
        if (requestAndAttachmentData[i] is RequestInfo) {
          RequestInfo r = requestAndAttachmentData[i] as RequestInfo;
          r.decrementIndex();
        }
        else if (requestAndAttachmentData[i] is RequestAttachmentInfo) {
          RequestAttachmentInfo r = requestAndAttachmentData[i] as RequestAttachmentInfo;
          r.decrementIndex();
        }
      }
      requestAndAttachmentData.removeAt(index);
      requestAndAttachment.removeAt(index);
      print('removed');
      setState(() {

      });
    }
    else {
      print(response.statusCode);
      print(response.body);
    }
  }


}


