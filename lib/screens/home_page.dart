// ignore_for_file: must_be_immutable, deprecated_member_use, unused_import, unused_field, unused_local_variable, prefer_const_constructors_in_immutables, avoid_print, use_build_context_synchronously, prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_ai/Login/login_screen.dart';
import 'package:sales_ai/screens/suggetion.dart';
import '../controllers/controller.dart';
import '../models/models.dart';
import '../styles/styles.dart';
import 'HistoryPage.dart';
import 'add_company_details_page.dart';
import 'package:pdf/pdf.dart';

import 'create_invoice_page.dart';

class HomePage extends StatefulWidget {
  // ignore: use_super_parameters
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Controller controller = Get.put(Controller());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> addProduct = GlobalKey<FormState>();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final GlobalKey<FormState> addCustomer = GlobalKey<FormState>();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerNumberController =
      TextEditingController();

  String? productName;

  String? price;

  String? customerName;

  String? customerNumber;

  List<Map> themeColors = [
    {
      "name": "Blue",
      "color": Colors.blue,
      "pdfColor": PdfColors.blue,
      "pdfColorLight": PdfColors.blue100,
    },
    {
      "name": "Green",
      "color": Colors.green,
      "pdfColor": PdfColors.green,
      "pdfColorLight": PdfColors.green100,
    },
    {
      "name": "Orange",
      "color": Colors.orange,
      "pdfColor": PdfColors.orange,
      "pdfColorLight": PdfColors.orange100,
    },
    {
      "name": "Purple",
      "color": Colors.purple,
      "pdfColor": PdfColors.purple,
      "pdfColorLight": PdfColors.purple100,
    },
    {
      "name": "Teal",
      "color": Colors.teal,
      "pdfColor": PdfColors.teal,
      "pdfColorLight": PdfColors.teal100,
    },
    {
      "name": "Pink",
      "color": Colors.pink,
      "pdfColor": PdfColors.pink,
      "pdfColorLight": PdfColors.pink100,
    },
    {
      "name": "Red",
      "color": Colors.red,
      "pdfColor": PdfColors.red,
      "pdfColorLight": PdfColors.red100,
    },
  ];

  @override
  void initState() {
    super.initState();
    CompanyDetailsUtility.fetchDataAndFillFields();
    loadProductsFromFirebase();
    loadCustomersFromFirebase();
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      // Navigate to the login screen (replace 'LoginScreen' with your actual login screen route)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LoginScreen(), // Replace with your actual login screen widget
        ),
      );
    } catch (error) {
      print('Error logging out: $error');
    }
  }

  Future<void> loadProductsFromFirebase() async {
    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;
      CollectionReference product =
          FirebaseFirestore.instance.collection('users/$uid/products');

      QuerySnapshot<Map<String, dynamic>>? querySnapshot =
          (await product.get()) as QuerySnapshot<Map<String, dynamic>>?;

      controller.customersList.clear();
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot!.docs) {
        controller.productsList.add(Products.fromJson(document.data()));
      }
    }
  }

  Future<void> loadCustomersFromFirebase() async {
    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;
      CollectionReference customers =
          FirebaseFirestore.instance.collection('users/$uid/customers');

      QuerySnapshot<Map<String, dynamic>>? querySnapshot =
          (await customers.get()) as QuerySnapshot<Map<String, dynamic>>?;

      controller.customersList.clear();
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot!.docs) {
        controller.customersList.add(Customer.fromJson(document.data()));
      }
    }
  }

  Future<void> deleteCollection(String collectionPath) async {
    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;
      CollectionReference<Map<String, dynamic>> collection =
          FirebaseFirestore.instance.collection('users/$uid/$collectionPath');

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collection.get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        await document.reference.delete();
      }
    }
  }

  void deleteProductFromFirebase(String productId) async {
    if (_auth.currentUser != null && productId.isNotEmpty) {
      try {
        String uid = _auth.currentUser!.uid;

        CollectionReference products =
            FirebaseFirestore.instance.collection('users/$uid/products');

        await deleteCollection('products');

        controller.productsList
            .removeWhere((product) => product.productName == productId);
      } catch (e) {
        print("Error deleting product: $e");
      }
    }
  }

  void deleteCustomerFromFirebase(String customerId) async {
    if (_auth.currentUser != null && customerId.isNotEmpty) {
      try {
        String uid = _auth.currentUser!.uid;
        CollectionReference customers =
            FirebaseFirestore.instance.collection('users/$uid/customers');

        await deleteCollection('customers');

        controller.customersList.removeWhere(
          (customer) => customer.customerName == customerId,
        );

        print("Customer removed locally: $customerId");
      } catch (e) {
        print("Error deleting customer: $e");
      }
    }
  }

  void uploadProductsToFirebase(List<Products> productsList) async {
    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;
      CollectionReference products =
          FirebaseFirestore.instance.collection('users/$uid/products');

      for (var product in productsList) {
        await products.add(product.toJson());
      }
    }
  }

  void uploadCustomersToFirebase(List<Customer> customersList) async {
    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;
      CollectionReference customers =
          FirebaseFirestore.instance.collection('users/$uid/customers');

      for (var customer in customersList) {
        await customers.add(customer.toJson());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await Get.dialog(
          AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            scrollable: true,
            title: Center(
              child: Text("Exit From App", style: textStyle()),
            ),
            content:
                Text("Are you sure want to exit?", style: textStyleProducts()),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: elevatedButtonStyle(),
                child: const Text("Yes"),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: outLinedButtonStyle(),
                child: const Text("No"),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        key: controller.pagesViewScaffoldKey,
        drawer: drawer(CompanyDetails(), themeColors),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              controller.openDrawer();
            },
            icon: Obx(() => Icon(Icons.dehaze,
                color: (controller.isDarkTheme.value)
                    ? Colors.black
                    : Colors.white)),
          ),
          title: Obx(
            () => (controller.tabIndex.value == 0)
                ? Text("Products", style: appBarText())
                : (controller.tabIndex.value == 1)
                    ? Text("Customers", style: appBarText())
                    : const SizedBox(), // Leave it empty or replace with your desired behavior
          ),
          actions: [
            Obx(
              () => TextButton(
                onPressed: () {
                  if (controller.companyName.value == "") {
                    controller.openDrawer();
                    Get.snackbar(
                      "Please Enter Company/Shop Details",
                      "Tap To Enter Details",
                      backgroundColor:
                          controller.themeColor.value.withOpacity(0.7),
                      snackPosition: SnackPosition.BOTTOM,
                      icon: const Icon(Icons.error_outline),
                      barBlur: 70,
                      margin: const EdgeInsets.all(15),
                      onTap: (val) {
                        Get.to(AddCompanyDetails());
                        Get.back();
                      },
                    );
                  } else if (controller.productsList.isEmpty) {
                    controller.tabIndex.value = 0;
                    Get.snackbar(
                      "Please Add Product/Service",
                      "Tap To Add Product/Service",
                      backgroundColor:
                          controller.themeColor.value.withOpacity(0.7),
                      snackPosition: SnackPosition.BOTTOM,
                      icon: const Icon(Icons.error_outline),
                      barBlur: 70,
                      margin: const EdgeInsets.all(15),
                      onTap: (val) {
                        addEditDialogBox(controller, "");
                        Get.back();
                      },
                    );
                  } else if (controller.customersList.isEmpty) {
                    controller.tabIndex.value = 1;
                    Get.snackbar(
                      "Please Add Customer",
                      "Tap To Add Customer",
                      backgroundColor:
                          controller.themeColor.value.withOpacity(0.7),
                      snackPosition: SnackPosition.BOTTOM,
                      icon: const Icon(Icons.error_outline),
                      barBlur: 70,
                      margin: const EdgeInsets.all(15),
                      onTap: (val) {
                        addEditDialogBox(controller, "");
                        Get.back();
                      },
                    );
                  } else {
                    Get.to(const CreateInvoice());
                  }
                },
                style: textButtonStyle(),
                child: const Text(
                  "Create\nInvoice",
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
          centerTitle: true,
          backgroundColor: controller.themeColor.value,
        ),
        body: homePage(controller),
        floatingActionButton: Obx(() => (controller.tabIndex.value == 0)
            ? ElevatedButton.icon(
                onPressed: () {
                  addEditDialogBox(controller, "");
                },
                label: const Text("Product"),
                icon: const Icon(Icons.add_shopping_cart),
                style: elevatedButtonStyle(),
              )
            : (controller.tabIndex.value == 1)
                ? ElevatedButton.icon(
                    onPressed: () {
                      addEditDialogBox(controller, "");
                    },
                    label: const Text("Customer"),
                    icon: const Icon(Icons.person_add_rounded),
                    style: elevatedButtonStyle(),
                  )
                : Container()),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            unselectedItemColor: (controller.isDarkTheme.value)
                ? controller.themeColor.value.shade100
                : Colors.black45,
            selectedItemColor: (controller.isDarkTheme.value)
                ? controller.themeColor.value.shade400
                : controller.themeColor.value.shade600,
            backgroundColor: controller.themeColor.value.withOpacity(0.15),
            onTap: (value) {
              if (value == 0) {
                controller.tabIndex.value = value;
              } else if (value == 1) {
                controller.tabIndex.value = value;
              } else if (value == 2) {
                Get.to(() => InvoiceHistoryPage());
              }
            },
            currentIndex: controller.tabIndex.value,
            elevation: 0,
            iconSize: 32,
            unselectedFontSize: 13,
            selectedFontSize: 16,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: const [
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.shopping_cart),
                icon: Icon(Icons.shopping_cart_outlined),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(Icons.people_alt),
                icon: Icon(Icons.people_alt_outlined),
                label: 'Customers',
              ),
            ],
          ),
        ),
      ),
    );
  }

  homePage(controller) {
    return Obx(
      () => (controller.tabIndex.value == 0
              ? controller.productsList.isEmpty
              : controller.customersList.isEmpty)
          ? Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    (controller.tabIndex.value == 0)
                        ? Icons.production_quantity_limits
                        : Icons.people_alt,
                    color: controller.themeColor.value.withOpacity(0.7),
                    size: 70,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    (controller.tabIndex.value == 0)
                        ? "You don't have any Products"
                        : "You don't have any customers",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: controller.themeColor.value.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: (controller.tabIndex.value == 0)
                  ? controller.productsList.length
                  : controller.customersList.length,
              itemBuilder: (context, i) {
                return Card(
                  margin: const EdgeInsets.only(top: 8),
                  shape: const StadiumBorder(),
                  color: controller.themeColor.value.withOpacity(0.15),
                  elevation: 0,
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${i + 1}",
                          style: textStyleProducts(),
                        ),
                      ],
                    ),
                    title: Text(
                      (controller.tabIndex.value == 0)
                          ? "Name  :  ${controller.productsList[i].productName}"
                          : "Name  :  ${controller.customersList[i].customerName}",
                      style: textStyleProducts(),
                    ),
                    subtitle: Text(
                      (controller.tabIndex.value == 0)
                          ? "Price  :  ${controller.productsList[i].price}"
                          : "Number  :  ${controller.customersList[i].customerNumber}",
                      style: textStyleProducts(),
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: (controller.tabIndex.value == 0)
                                ? "Edit Product"
                                : "Edit Customer",
                            onPressed: () {
                              addEditDialogBox(controller, i);
                            },
                            icon: Icon(
                              Icons.edit,
                              color: controller.themeColor.value,
                            ),
                          ),
                          IconButton(
                            tooltip: (controller.tabIndex.value == 0)
                                ? "Delete Product"
                                : "Delete Customer",
                            onPressed: () {
                              if (controller.tabIndex.value == 0 &&
                                  i >= 0 &&
                                  i < controller.productsList.length) {
                                String productId =
                                    controller.productsList[i].productName ??
                                        "";
                                print("Deleting product with ID: $productId");
                                deleteProductFromFirebase(productId);
                                controller.productsList.removeAt(i);
                              } else if (controller.tabIndex.value == 1 &&
                                  i >= 0 &&
                                  i < controller.customersList.length) {
                                String customerId =
                                    controller.customersList[i].customerName ??
                                        "";
                                print("Deleting customer with ID: $customerId");
                                deleteCustomerFromFirebase(customerId);
                                controller.customersList.removeAt(i);
                              }
                            },
                            icon: Icon(
                              Icons.delete,
                              color: controller.themeColor.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  addEditDialogBox(controller, i) {
    if (i == "") {
      productPriceController.clear();
      productNameController.clear();
      customerNameController.clear();
      customerNumberController.clear();
      productName = "";
      price = "";
      customerName = "";
      customerNumber = "";
    } else {
      if (controller.tabIndex.value == 0) {
        productNameController.text = controller.productsList[i].productName;
        productPriceController.text = controller.productsList[i].price;
      } else {
        customerNameController.text = controller.customersList[i].customerName;
        customerNumberController.text =
            controller.customersList[i].customerNumber;
      }
    }
    return Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        scrollable: true,
        title: Text(
          (controller.tabIndex.value == 0)
              ? 'Product/Service Details'
              : "Customer Details",
          textAlign: TextAlign.center,
          style: textStyle(),
        ),
        content: Form(
          key: (controller.tabIndex.value == 0) ? addProduct : addCustomer,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: [
              TextFormField(
                cursorColor: controller.themeColor.value,
                validator: (val) {
                  if (val!.isEmpty) {
                    return (controller.tabIndex.value == 0)
                        ? "Enter Product/Service Name..."
                        : "Enter Customer Name...";
                  }
                  return null;
                },
                onSaved: (val) {
                  (controller.tabIndex.value == 0)
                      ? productName = val
                      : customerName = val;
                },
                controller: (controller.tabIndex.value == 0)
                    ? productNameController
                    : customerNameController,
                decoration: textFieldDecoration((controller.tabIndex.value == 0)
                    ? "Product/Service Name"
                    : "Customer Name"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                cursorColor: controller.themeColor.value,
                validator: (val) {
                  if (val!.isEmpty) {
                    return (controller.tabIndex.value == 0)
                        ? "Enter Product/Service Price..."
                        : "Enter Customer Number...";
                  }
                  return null;
                },
                onSaved: (val) {
                  (controller.tabIndex.value == 0)
                      ? price = val
                      : customerNumber = val;
                },
                keyboardType: TextInputType.number,
                controller: (controller.tabIndex.value == 0)
                    ? productPriceController
                    : customerNumberController,
                decoration: textFieldDecoration((controller.tabIndex.value == 0)
                    ? "Product/Service Price"
                    : "Customer Number"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if ((controller.tabIndex.value == 0)
                      ? addProduct.currentState!.validate()
                      : addCustomer.currentState!.validate()) {
                    (controller.tabIndex.value == 0)
                        ? addProduct.currentState!.save()
                        : addCustomer.currentState!.save();

                    if (controller.tabIndex.value == 0) {
                      Products p = Products.fromAdd(
                        productName: productName.toString(),
                        price: price.toString(),
                      );
                      (i == "")
                          ? controller.productsList.add(p)
                          : controller.productsList[i] = p;

                      // Upload to Firebase
                      uploadProductsToFirebase(controller.productsList);
                    } else {
                      Customer c = Customer.fromAdd(
                        customerName: customerName.toString(),
                        customerNumber: customerNumber.toString(),
                      );
                      (i == "")
                          ? controller.customersList.add(c)
                          : controller.customersList[i] = c;

                      // Upload to Firebase
                      uploadCustomersToFirebase(controller.customersList);
                    }
                    Get.back();
                  }
                },
                style: elevatedButtonStyle(),
                child: Text((i == "")
                    ? (controller.tabIndex.value == 0)
                        ? "Add Products/Service"
                        : "Add Customer"
                    : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer drawer(CompanyDetails companyDetails, List themeColors) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(50),
        ),
      ),
      child: Obx(
        () => Container(
          child: (CompanyDetails.companyName.isEmpty)
              ? AddCompanyDetails()
              : buildCompanyDrawer(companyDetails, themeColors),
        ),
      ),
    );
  }

  Widget buildEmptyDrawer(List themeColors) {
    return ListView(
      children: [
        const Spacer(flex: 5),
        Icon(
          Icons.info_outline,
          color: controller.themeColor.value.withOpacity(0.7),
          size: 50,
        ),
        const SizedBox(height: 20),
        Text(
          "ADD\nCompany Details",
          style: textStyle(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_business_outlined),
          label: const Text("ADD   "),
          onPressed: () {
            Get.to(() => AddCompanyDetails());
          },
          style: elevatedButtonStyle(),
        ),
        const Spacer(flex: 4),
        // InkWell(
        //   onTap: () {
        //     themeDialog(themeColors);
        //   },
        //   child: drawerItems(Icons.color_lens_sharp, "Change Theme Color"),
        // ),
        darkMode(),
      ],
    );
  }

  Widget buildCompanyDrawer(CompanyDetails companyDetails, List themeColors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: controller.themeColor.value,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: controller.themeColor.value.shade200,
                  backgroundImage: FileImage(
                    File(controller.selectedImagePath.value),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  controller.companyName.value,
                  style: TextStyle(
                    color: (controller.isDarkTheme.value)
                        ? Colors.black
                        : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Get.to(AddCompanyDetails());
            },
            child: drawerItems(Icons.edit, "Edit Company Details"),
          ),
          // InkWell(
          //   onTap: () {
          //     themeDialog(themeColors);
          //   },
          //   child: drawerItems(
          //     Icons.color_lens_sharp,
          //     "Change Theme Color",
          //   ),
          // ),
          // darkMode(),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceHistoryPage(),
                ),
              );
            },
            child: drawerItems(
                Icons.history_rounded, "View Your Previous Records"),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuggestionsPage(
                      companyName: controller.companyName.value),
                ),
              );
            },
            child: drawerItems(Icons.feedback, "Suggestions"),
          ),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _logout(),
            style: ElevatedButton.styleFrom(
              primary: controller.themeColor.value,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

darkMode() {
  return ListTile(
    onTap: () {
      controller.isDarkTheme.value = !controller.isDarkTheme.value;
      (controller.isDarkTheme.value)
          ? Get.changeTheme(ThemeData.dark())
          : Get.changeTheme(ThemeData.light());
    },
    title: Text(
      "Dark Mode",
      style: TextStyle(
        fontSize: 15,
        color: (controller.isDarkTheme.value)
            ? controller.themeColor.value
            : Colors.grey.shade700,
      ),
    ),
    leading: Icon(
      Icons.dark_mode_rounded,
      size: 24,
      color: (controller.isDarkTheme.value)
          ? controller.themeColor.value
          : Colors.grey.shade700,
    ),
    shape: Border(
      bottom: BorderSide(color: controller.themeColor.value.shade500),
    ),
    trailing: Switch(
      activeColor: controller.themeColor.value,
      value: controller.isDarkTheme.value,
      onChanged: (val) {
        (val)
            ? Get.changeTheme(ThemeData.dark())
            : Get.changeTheme(ThemeData.light());
        controller.isDarkTheme.value = val;
      },
    ),
  );
}

drawerItems(icon, name) {
  return ListTile(
    title: Text(
      name,
      style: TextStyle(
        fontSize: 15,
        color: (controller.isDarkTheme.value)
            ? controller.themeColor.value
            : Colors.grey.shade700,
      ),
    ),
    leading: Icon(
      icon,
      size: 24,
      color: (controller.isDarkTheme.value)
          ? controller.themeColor.value
          : Colors.grey.shade700,
    ),
    shape: Border(
      bottom: BorderSide(color: controller.themeColor.value.shade500),
    ),
  );
}

themeDialog(List themeColors) {
  return Get.dialog(
    AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      scrollable: true,
      title: Container(
        alignment: Alignment.center,
        child: Text(
          'Select Theme Color',
          style: textStyle(),
        ),
      ),
      content: Column(
          children: themeColors
              .map(
                (e) => InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    controller.themeColor.value = e["color"];
                    controller.pdfColor.value = e["pdfColor"] as PdfColor;
                    controller.pdfColorLight.value =
                        e["pdfColorLight"] as PdfColor;
                    Get.offAll(() => HomePage());
                    controller.openDrawer();
                  },
                  child: Card(
                    shape: StadiumBorder(
                      side: BorderSide(color: controller.themeColor.value),
                    ),
                    elevation: 0,
                    color: controller.themeColor.value.withOpacity(0.07),
                    child: ListTile(
                      leading: Icon(
                        Icons.color_lens_sharp,
                        color: e["color"],
                        size: 35,
                      ),
                      title: Text(e["name"],
                          style: TextStyle(
                            color: e["color"],
                            fontSize: 18,
                          )),
                    ),
                  ),
                ),
              )
              .toList()),
    ),
  );
}
