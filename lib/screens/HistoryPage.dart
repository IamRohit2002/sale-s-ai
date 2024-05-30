// ignore_for_file: file_names, prefer_final_fields, unused_field, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, deprecated_member_use, avoid_unnecessary_containers

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:sales_ai/models/Colurs.dart';
import 'package:sales_ai/styles/styles.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class InvoiceHistoryPage extends StatefulWidget {
  const InvoiceHistoryPage({super.key});

  @override
  _InvoiceHistoryPageState createState() => _InvoiceHistoryPageState();
}

class _InvoiceHistoryPageState extends State<InvoiceHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late RxString userId = controller.companyName;
  List<String> pdfFileNames = [];
  bool latestFirst = false; // Default to sort by latest first
  TextEditingController searchController = TextEditingController();
  bool _isProcessing = false;
  Map<String, bool> _cardProcessingMap = {};
  bool _sortingInProgress = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _getUserData();
    });
  }

  Future<void> _getUserData() async {
    if (_auth.currentUser != null && userId.value.isNotEmpty) {
      // Fetch user invoices from Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('user_invoices')
          .doc(userId.value)
          .collection('invoices')
          .get();

      // Access the documents from the query snapshot
      List<QueryDocumentSnapshot> invoices = querySnapshot.docs;

      // Sort invoices by timestamp or any other criteria
      invoices.sort((a, b) {
        DateTime timeA = a['timestamp'].toDate();
        DateTime timeB = b['timestamp'].toDate();
        return latestFirst ? timeB.compareTo(timeA) : timeA.compareTo(timeB);
      });

      try {
        Reference storageReference =
            _storage.ref().child('user_invoices/$userId');
        // List all items (files) in the folder
        ListResult result = await storageReference.list();

        // Extract file names from the list result
        List<String> fileNames = result.items.map((item) => item.name).toList();

        // Sort file names by timestamp or any other criteria
        fileNames.sort((a, b) {
          return latestFirst ? b.compareTo(a) : a.compareTo(b);
        });

        // Update the state with the sorted file names
        if (mounted) {
          setState(() {
            pdfFileNames = fileNames;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    } else {
      print('User ID is empty or null. Cannot fetch data.');
    }
  }

  Future<void> _openPdf(String fileName) async {
    try {
      File pdfFile = await _downloadPdfFile(fileName);

      // Open the PDF file using a PDF viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(pdfFile: pdfFile),
        ),
      );
    } catch (error) {
      print('Error opening PDF: $error');
    }
  }

  Future<File> _downloadPdfFile(String fileName) async {
    Reference storageReference =
        _storage.ref().child('user_invoices/$userId/$fileName');

    File tempFile =
        File('${(await getTemporaryDirectory()).path}/$fileName.pdf');
    await storageReference.writeToFile(tempFile);

    return tempFile;
  }

  Future<void> _sharePdf(String fileName) async {
    try {
      setState(() {
        _cardProcessingMap[fileName] = true;
      });

      File pdfFile = await _downloadPdfFile(fileName);
      var sharePdf = await pdfFile.writeAsBytes(await pdfFile.readAsBytes());
      await Share.shareFiles([sharePdf.path]);
    } catch (error) {
      print('Error sharing PDF: $error');
    } finally {
      setState(() {
        _cardProcessingMap[fileName] = false;
      });
    }
  }

  Future<void> _printPdf(String fileName) async {
    try {
      setState(() {
        _cardProcessingMap[fileName] = true;
      });

      File pdfFile = await _downloadPdfFile(fileName);
      Uint8List bytes = await pdfFile.readAsBytes();
      await Printing.layoutPdf(onLayout: (format) => bytes);
    } catch (error) {
      print('Error printing PDF: $error');
    } finally {
      setState(() {
        _cardProcessingMap[fileName] = false;
      });
    }
  }

  String _extractUserName(String fileName) {
    List<String> parts = fileName.split('-');
    return parts.last.split('.').first;
  }

  // void _sortInvoices() {
  //   setState(() {
  //     latestFirst = !latestFirst;
  //     _getUserData();
  //   });
  // }

  void _searchInvoices(String query) async {
    try {
      showLoadingIndicator();
      await Future.delayed(const Duration(seconds: 2));
      List<String> filteredList = pdfFileNames
          .where((fileName) => _extractUserName(fileName)
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      setState(() {
        pdfFileNames = filteredList;
      });
      hideLoadingIndicator();
    } catch (error) {
      handleError(error);
    }
  }

  void showLoadingIndicator() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 50,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      },
    );
  }

  void hideLoadingIndicator() {
    // Hide the loading indicator, for example, by popping the bottom sheet
    Navigator.pop(context);
  }

  void handleError(dynamic error) {
    // Handle errors, for example, show a snackbar with the error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildProgressIndicator(String fileName) {
    return Visibility(
      visible: _cardProcessingMap[fileName] ?? false,
      child: const CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Invoice History',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: Colors.blue,
      ),
      body: (pdfFileNames.isEmpty)
          ? Center(
              child: Container(
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    Text('Invoices Loading'),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Search by User Name',
                              filled: true,
                              fillColor:
                                  myFillColor, // Use your desired grey color
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    30.0), // Adjust the radius as needed
                                borderSide: BorderSide.none, // Remove border
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  // Call the search function when the search button is pressed
                                  _searchInvoices(searchController.text);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              latestFirst = !latestFirst;
                              _sortingInProgress = !_sortingInProgress;
                              _getUserData();
                            });
                            setState(() {
                              _sortingInProgress = true;
                            });
                            pdfFileNames.sort((a, b) {
                              return latestFirst
                                  ? b.compareTo(a)
                                  : a.compareTo(b);
                            });
                            _getUserData();

                            setState(() {
                              _sortingInProgress = false;
                            });
                          },
                          icon: _sortingInProgress
                              ? const CircularProgressIndicator()
                              : Icon(
                                  latestFirst
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: pdfFileNames.length,
                    itemBuilder: (context, index) {
                      String fileName = pdfFileNames[index];
                      String userName = _extractUserName(fileName);

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(18, 2, 18, 0),
                        child: Card(
                          color: mycardColor,
                          child: ListTile(
                            title: Text('User Name: $userName'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('File Name: $fileName'),
                              ],
                            ),
                            onTap: () => _openPdf(fileName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _sharePdf(fileName),
                                  icon: const Icon(Icons.share),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _printPdf(fileName),
                                  icon: const Icon(Icons.print),
                                ),
                                const SizedBox(width: 8),
                                _buildProgressIndicator(
                                  fileName,
                                ), // Add this line to display a progress indicator
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final File pdfFile;

  const PdfViewerPage({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: SfPdfViewer.file(pdfFile),
    );
  }
}
