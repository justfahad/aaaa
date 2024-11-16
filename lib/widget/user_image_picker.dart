import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key , required this.onPickImage});

      final void Function(File pickedImage) onPickImage;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends  State<UserImagePicker>{
 File? _pickedImagFile;
  void _pickImage() async{
    final pickedImage =await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150,);
    if(pickedImage== null){
      return;
    }
    setState(() {
      _pickedImagFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImagFile!);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
//        CircleAvatar(
  //        radius: 40,
    //      backgroundColor: Colors.grey,
      //    foregroundImage: _pickedImagFile!= null ? FileImage(_pickedImagFile!) : null,
        //),
        TextButton.icon(onPressed: _pickImage,icon: const Icon(Icons.image), label:const Text('Add Image', style: TextStyle(
          color: Colors.black
        ),))
      ],
    );
  }
}