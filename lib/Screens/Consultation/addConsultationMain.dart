
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medical_app/globalWidgets.dart';
import '../../MyColors.dart';
import 'package:image_picker/image_picker.dart';


class addConsultationMain extends StatefulWidget {
  const addConsultationMain({Key? key}) : super(key: key);

  @override
  _addConsultationMainState createState() => _addConsultationMainState();
}

class _addConsultationMainState extends State<addConsultationMain> {

  TextEditingController DescriptionController =TextEditingController(text: "");
  List <Widget> ImageWidgets = [];
  List <XFile> selectedImages = [];

  @override
  void initState() {
    super.initState();

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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.add+" "+AppLocalizations.of(context)!.newConsultation,style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Description(),
              Text('Uploaded Images',style: TextStyle(color: Colors.black,)),
              ImageSelector(),
              DoneButton(),

            ],
          ),
        ),
      ),
    );
  }

  Widget Description(){
    return MyContainer.anotherConstructor(
        Text(AppLocalizations.of(context)!.problemDescription,style: TextStyle(fontSize: 20,color: MyGreyColorDarker),),
        SizedBox(
            width: 250,
            height: MediaQuery.of(context).size.height/6,
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
        MediaQuery.of(context).size.height/3,
        MediaQuery.of(context).size.width
    );
  }

  Widget ImageSelector(){
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 120,
        child: CustomScrollView(
          scrollDirection: Axis.horizontal,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: ImageWidgets,
              ),
          ),
          ]
        ),
      ),
    );
  }

  Widget DoneButton(){
    return Padding(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: (){
            
          },
          child: Text(AppLocalizations.of(context)!.done),
        ),
    );
  }


}
