// ignore_for_file: avoid_print, non_constant_identifier_names, prefer_const_constructors

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';

import '../models/models.dart';

class Controller extends GetxController {
  OnTap() {
    Drawer();
  }

  var pagesViewScaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> uploadLogoToFirebase() async {
    try {
      if (selectedImagePath.isNotEmpty) {
        File logoFile = File(selectedImagePath.value);
        Reference storageReference = FirebaseStorage.instance.ref().child(
            'company_logos/${DateTime.now().millisecondsSinceEpoch}.png');
        UploadTask uploadTask = storageReference.putFile(logoFile);
        String downloadURL = await (await uploadTask).ref.getDownloadURL();
        updateLogoDownloadURL(downloadURL);
      }
    } catch (error) {
      print('Error uploading logo to Firebase: $error');
    }
  }

  void updateLogoDownloadURL(String url) {
    selectedImagePath.value = url;
  }

  void openDrawer() {
    pagesViewScaffoldKey.currentState?.openDrawer();
    update();
  }

  var isDarkTheme = false.obs;
  List<Products> productsList = <Products>[].obs;
  List<Customer> customersList = <Customer>[].obs;
  var tabIndex = 0.obs;
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  var themeColor = Colors.blue.obs;
  RxDouble total = 0.0.obs;
  var counter = [].obs;
  var totalList = <double>[].obs;

  var pdfColor = PdfColors.blue.obs;
  var pdfColorLight = PdfColors.blue200.obs;

  var companyName = "".obs;
  var companyAddress = "".obs;
  var companyAddress2 = "".obs;
  var companyAddress3 = "".obs;
  var companyGSTNo = "".obs;
  var companyNumber = "".obs;
  var companyEmail = "".obs;

  var initialTaxValue = 0.obs;

  var selectedImagePath = "".obs;

  void getImage(ImageSource imageSource) async {
    final pickedImage = await ImagePicker().pickImage(source: imageSource);
    if (pickedImage != null) {
      selectedImagePath.value = pickedImage.path;
    }
  }

  compressImage(void pickedFile) {}
}
