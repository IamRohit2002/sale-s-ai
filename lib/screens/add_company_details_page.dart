// ignore_for_file: must_be_immutable, use_super_parameters, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/controller.dart';
import '../styles/styles.dart';
import 'package:image_picker/image_picker.dart';

class AddCompanyDetails extends StatefulWidget {
  AddCompanyDetails({Key? key}) : super(key: key);

  @override
  _AddCompanyDetailsState createState() => _AddCompanyDetailsState();
}

class _AddCompanyDetailsState extends State<AddCompanyDetails> {
  final GlobalKey<FormState> addCompanyDetails = GlobalKey<FormState>();
  Controller controller = Get.put(Controller());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyAddressController =
      TextEditingController();
  final TextEditingController companyAddress2Controller =
      TextEditingController();
  final TextEditingController companyAddress3Controller =
      TextEditingController();
  final TextEditingController companyGSTNoController = TextEditingController();
  final TextEditingController companyEmailController = TextEditingController();
  final TextEditingController companyNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDataAndFillFields(); // Fetch data on page initialization
  }

  void fetchDataAndFillFields() async {
    try {
      if (_auth.currentUser != null) {
        String uid = _auth.currentUser!.uid;

        // Fetch data from Firestore based on UID
        DocumentSnapshot documentSnapshot =
            await _firestore.collection('users').doc(uid).get();

        if (documentSnapshot.exists) {
          Map<String, dynamic> loadedData =
              documentSnapshot.data() as Map<String, dynamic>;
          fillDataLocally(loadedData);
        }
      }
    } catch (error) {
      print('Error fetching and filling data: $error');
    }
  }

  void fillDataLocally(Map<String, dynamic> loadedData) {
    setState(() {
      controller.companyName.value = loadedData['companyName'];
      controller.companyAddress.value = loadedData['AddressLine1'];
      controller.companyAddress2.value = loadedData['AddressLine2'];
      controller.companyAddress3.value = loadedData['AddressLine3'];
      controller.initialTaxValue.value = loadedData['Tax Percentage'];
      controller.companyGSTNo.value = loadedData['GST Number'];
      controller.companyNumber.value = loadedData['Phone Number'];
      controller.companyEmail.value = loadedData['Email Address'];
      controller.selectedImagePath.value = loadedData['companyLogo'];
    });
  }

  void storeUserProfileData() async {
    try {
      if (_auth.currentUser != null) {
        String uid = _auth.currentUser!.uid;

        Map<String, dynamic> userData = {
          'companyLogo': controller.selectedImagePath.value,
          'companyName': controller.companyName.value,
          'AddressLine1': controller.companyAddress.value,
          'AddressLine2': controller.companyAddress2.value,
          'AddressLine3': controller.companyAddress3.value,
          'Tax Percentage': controller.initialTaxValue.value,
          'GST Number': controller.companyGSTNo.value,
          'Phone Number': controller.companyNumber.value,
          'Email Address': controller.companyEmail.value,
          'ThemeColor': controller.themeColor.value.toString(),
        };

        if (controller.selectedImagePath.value.isNotEmpty) {
          await uploadLogoToFirebase(
              _auth.currentUser!.uid, File(controller.selectedImagePath.value));
        }

        await _firestore.collection('users').doc(uid).set(userData);

        saveDataLocally(userData);

        ScaffoldMessenger.of(controller.pagesViewScaffoldKey.currentContext!)
            .showSnackBar(
          const SnackBar(
            content: Text('User profile data stored successfully!'),
          ),
        );
      }
    } catch (error) {
      print('Error storing user profile data: $error');
    }
  }

  Future<void> uploadLogoToFirebase(String userId, File logoFile) async {
    try {
      String fileName = 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final Reference storageReference =
          FirebaseStorage.instance.ref().child('user_logos/$userId/$fileName');

      await storageReference.putFile(logoFile);
      print('Logo uploaded successfully');
    } catch (e) {
      print('Error uploading logo: $e');
    }
  }

  void saveDataLocally(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('companyLogo', userData['companyLogo']);
    prefs.setString('companyName', userData['companyName']);
    prefs.setString('AddressLine1', userData['AddressLine1']);
    prefs.setString('AddressLine2', userData['AddressLine2']);
    prefs.setString('AddressLine3', userData['AddressLine3']);
    prefs.setInt('Tax Percentage', userData['Tax Percentage']);
    prefs.setString('GST Number', userData['GST Number']);
    prefs.setString('Phone Number', userData['Phone Number']);
    prefs.setString('Email Address', userData['Email Address']);
    // Save other data as needed...
  }

  // Function to load data from SharedPreferences
  Future<Map<String, dynamic>> loadDataLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? companyName = prefs.getString('companyName');
    String? addressLine1 = prefs.getString('AddressLine1');
    String? addressLine2 = prefs.getString('AddressLine2');
    String? addressLine3 = prefs.getString('AddressLine3');
    int? taxPercentage = prefs.getInt('Tax Percentage');
    String? gstNumber = prefs.getString('GST Number');
    String? phoneNumber = prefs.getString('Phone Number');
    String? emailAddress = prefs.getString('Email Address');
    String? companyLogo = prefs.getString('companyLogo');
    // Load other data as needed...

    return {
      'companyLogo': companyLogo,
      'companyName': companyName,
      'AddressLine1': addressLine1,
      'AddressLine2': addressLine2,
      'AddressLine3': addressLine3,
      'Tax Percentage': taxPercentage,
      'GST Number': gstNumber,
      'Phone Number': phoneNumber,
      'Email Address': emailAddress,
      // Other loaded data...
    };
  }

  @override
  Widget build(BuildContext context) {
    if (controller.companyAddress.value != "") {
      companyNameController.text = controller.companyName.value;
      companyAddressController.text = controller.companyAddress.value;
      companyAddress2Controller.text = controller.companyAddress2.value;
      companyAddress3Controller.text = controller.companyAddress3.value;
      companyGSTNoController.text = controller.companyGSTNo.value;
      companyEmailController.text = controller.companyEmail.value;
      companyNumberController.text = controller.companyNumber.value;
    }

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Obx(() => Text("Company Details", style: appBarText())),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              onSave();
              storeUserProfileData();
            },
            style: textButtonStyle(),
            child: const Text("Save"),
          ),
        ],
        backgroundColor: controller.themeColor.value,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 25),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Obx(
                    () => CircleAvatar(
                      radius: 70,
                      backgroundColor:
                          controller.themeColor.value.withOpacity(0.2),
                      backgroundImage:
                          (controller.selectedImagePath.value == "")
                              ? null
                              : FileImage(
                                  File(controller.selectedImagePath.value),
                                ),
                      child: (controller.selectedImagePath.value != "")
                          ? const Text("")
                          : Text(
                              textAlign: TextAlign.center,
                              "Company\nLogo",
                              style: TextStyle(
                                fontSize: 20,
                                color: controller.themeColor.value,
                              ),
                            ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      imageAdd();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.themeColor.value,
                      shape: const CircleBorder(),
                    ),
                    child: Obx(
                      () => Icon(
                          (controller.selectedImagePath.value.isEmpty)
                              ? Icons.add
                              : Icons.edit,
                          color: (controller.isDarkTheme.value)
                              ? Colors.black
                              : Colors.white),
                    ),
                  ),
                ],
              ),
              Form(
                key: addCompanyDetails,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text("Company Name", style: textStyleProducts()),
                    const SizedBox(height: 10),
                    TextFormField(
                      cursorColor: controller.themeColor.value,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter Company Name...";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        controller.companyName.value = val!.toString();
                      },
                      controller: companyNameController,
                      decoration: textFieldDecoration("Company Name."),
                    ),
                    const SizedBox(height: 10),
                    Text("Address Line 1", style: textStyleProducts()),
                    const SizedBox(height: 10),
                    TextFormField(
                      cursorColor: controller.themeColor.value,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter Company Address...";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        controller.companyAddress.value = val.toString();
                      },
                      controller: companyAddressController,
                      decoration:
                          textFieldDecoration("Address (Street, Building No)"),
                    ),
                    const SizedBox(height: 10),
                    Text("Address Line 2", style: textStyleProducts()),
                    const SizedBox(height: 10),
                    TextFormField(
                      cursorColor: controller.themeColor.value,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter Company Address Line 2...";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        controller.companyAddress2.value = val.toString();
                      },
                      controller: companyAddress2Controller,
                      decoration: textFieldDecoration("Address Line 2"),
                    ),
                    const SizedBox(height: 10),
                    Text("Address Line 3", style: textStyleProducts()),
                    const SizedBox(height: 10),
                    TextFormField(
                      cursorColor: controller.themeColor.value,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter Company Address Line 3...";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        controller.companyAddress3.value = val.toString();
                      },
                      controller: companyAddress3Controller,
                      decoration: textFieldDecoration("Address Line 3"),
                    ),
                    const SizedBox(height: 10),
                    Text("Tax Percentage", style: textStyleProducts()),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      hint: Text(
                        "Select Tax Percentage",
                        style: TextStyle(
                          color: controller.themeColor.value,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text("Tax : 0%"),
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text("Tax : 5%"),
                        ),
                        DropdownMenuItem(
                          value: 12,
                          child: Text("Tax : 12%"),
                        ),
                        DropdownMenuItem(
                          value: 18,
                          child: Text("Tax : 18%"),
                        ),
                        DropdownMenuItem(
                          value: 28,
                          child: Text("Tax : 28%"),
                        ),
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color: controller.themeColor.value, width: 1.5),
                        ),
                      ),
                      validator: (val) {
                        if (controller.initialTaxValue.value < 0) {
                          return "Select Tax Percentage First...";
                        }
                        return null;
                      },
                      value: (controller.initialTaxValue.value != 0)
                          ? controller.initialTaxValue.value
                          : null,
                      onChanged: (val) {
                        controller.initialTaxValue.value = val as int;
                      },
                    ),
                    const SizedBox(height: 10),
                    Text("GST Number", style: textStyleProducts()),
                    const SizedBox(height: 10),
                    TextFormField(
                      cursorColor: controller.themeColor.value,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter Company GST No... Other Wise Write'NA' ";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        controller.companyGSTNo.value = val.toString();
                      },
                      controller: companyGSTNoController,
                      decoration: textFieldDecoration("Company GST No"),
                    ),
                    const SizedBox(height: 10),
                    Text("Phone Number", style: textStyleProducts()),
                    const SizedBox(height: 10),
                    TextFormField(
                      cursorColor: controller.themeColor.value,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter Company Phone Number...";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        controller.companyNumber.value = val.toString();
                      },
                      keyboardType: TextInputType.phone,
                      controller: companyNumberController,
                      decoration: textFieldDecoration("Company Phone Number"),
                    ),
                    const SizedBox(height: 10),
                    Text("Email Address", style: textStyleProducts()),
                    const SizedBox(height: 10),
                    TextFormField(
                      cursorColor: controller.themeColor.value,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Enter Company Email...";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        controller.companyEmail.value = val.toString();
                      },
                      keyboardType: TextInputType.emailAddress,
                      controller: companyEmailController,
                      decoration: textFieldDecoration("Company Email"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        onSave();
                        storeUserProfileData();
                      },
                      style: elevatedButtonStyle(),
                      label: const Text("Save"),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onSave() {
    if (addCompanyDetails.currentState!.validate()) {
      addCompanyDetails.currentState!.save();

      if (controller.selectedImagePath.value == "") {
        Get.snackbar(
          "Please Select Image First",
          "Tap To Select Image",
          backgroundColor: controller.themeColor.value.withOpacity(0.7),
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.error_outline),
          barBlur: 70,
          margin: const EdgeInsets.all(15),
          onTap: (val) {
            imageAdd();
            Get.back();
          },
        );
      } else {
        Get.back();
      }
    }
  }

  imageAdd() {
    return Get.dialog(
      AlertDialog(
        scrollable: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        title: Text(
          "When You go to pick Image ?",
          style: textStyle(),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              controller.getImage(ImageSource.gallery);
              Get.back();
            },
            style: outLinedButtonStyle(),
            child: const Text("gallery"),
          ),
          OutlinedButton(
            onPressed: () {
              controller.getImage(ImageSource.camera);
              Get.back();
            },
            style: outLinedButtonStyle(),
            child: const Text("Camera"),
          ),
        ],
      ),
    );
  }
}

class CompanyDetailsUtility {
  static Future<void> fetchDataAndFillFields() async {
    try {
      // Load data from SharedPreferences
      Map<String, dynamic> loadedData = await loadDataLocally();
      // Check if loaded data is not null
      if (loadedData.isNotEmpty) {
        fillDataLocally(loadedData);
      }
    } catch (error) {
      print('Error fetching and filling data: $error');
    }
  }

  static void fillDataLocally(Map<String, dynamic> loadedData) {
    Controller controller = Get.find<Controller>();
    controller.companyName.value = loadedData['companyName'];
    controller.companyAddress.value = loadedData['AddressLine1'];
    controller.companyAddress2.value = loadedData['AddressLine2'];
    controller.companyAddress3.value = loadedData['AddressLine3'];
    controller.initialTaxValue.value = loadedData['Tax Percentage'];
    controller.companyGSTNo.value = loadedData['GST Number'];
    controller.companyNumber.value = loadedData['Phone Number'];
    controller.companyEmail.value = loadedData['Email Address'];
    controller.selectedImagePath.value = loadedData['companyLogo'];
  }

  static Future<Map<String, dynamic>> loadDataLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? companyName = prefs.getString('companyName');
    String? addressLine1 = prefs.getString('AddressLine1');
    String? addressLine2 = prefs.getString('AddressLine2');
    String? addressLine3 = prefs.getString('AddressLine3');
    int? taxPercentage = prefs.getInt('Tax Percentage');
    String? gstNumber = prefs.getString('GST Number');
    String? phoneNumber = prefs.getString('Phone Number');
    String? emailAddress = prefs.getString('Email Address');
    String? companyLogo = prefs.getString('companyLogo');

    return {
      'companyName': companyName,
      'AddressLine1': addressLine1,
      'AddressLine2': addressLine2,
      'AddressLine3': addressLine3,
      'Tax Percentage': taxPercentage,
      'GST Number': gstNumber,
      'Phone Number': phoneNumber,
      'Email Address': emailAddress,
      'companyLogo': companyLogo,
    };
  }
}
