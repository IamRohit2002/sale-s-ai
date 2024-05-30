class Products {
  String productName;
  String price;

  Products({required this.productName, required this.price});

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'price': price,
    };
  }

  Products.fromAdd({
    required String productName,
    required String price,
  }) : this(
          productName: productName,
          price: price,
        );

  // Add factory method to convert from JSON
  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      productName: json['productName'] ?? "",
      price: json['price'] ?? "",
    );
  }
}

class Customer {
  String customerName;
  String customerNumber;

  Customer({required this.customerName, required this.customerNumber});

  // Factory constructor for creating an instance from some input (e.g., Map)
  factory Customer.fromAdd({
    required String customerName,
    required String customerNumber,
  }) {
    return Customer(
      customerName: customerName,
      customerNumber: customerNumber,
    );
  }

  // Add this factory constructor for deserialization
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerName: json['customerName'] ?? "",
      customerNumber: json['customerNumber'] ?? "",
    );
  }

  // Add this method for serialization
  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'customerNumber': customerNumber,
    };
  }
}

class CompanyDetails {
  static String companyName =
      "Your Company Name"; // Default value, replace with user input
  static String companyAddress =
      "Your Company Address"; // Default value, replace with user input
  static String companyAddress2 =
      "Your Company Address 2"; // Default value, replace with user input
  static String companyAddress3 =
      "Your Company Address 3"; // Default value, replace with user input
  static String companyGSTNo =
      "Your GST Number"; // Default value, replace with user input
  static String companyNumber =
      "Your Company Contact Number"; // Default value, replace with user input
  static String companyEmail =
      "Your Company Email"; // Default value, replace with user input

  // Update the company details with user input
  static void updateUserDetails({
    String? companyName,
    String? companyAddress,
    String? companyAddress2,
    String? companyAddress3,
    String? companyGSTNo,
    String? companyNumber,
    String? companyEmail,
  }) {
    CompanyDetails.companyName = companyName ?? CompanyDetails.companyName;
    CompanyDetails.companyAddress =
        companyAddress ?? CompanyDetails.companyAddress;
    CompanyDetails.companyAddress2 =
        companyAddress2 ?? CompanyDetails.companyAddress2;
    CompanyDetails.companyAddress3 =
        companyAddress3 ?? CompanyDetails.companyAddress3;
    CompanyDetails.companyGSTNo = companyGSTNo ?? CompanyDetails.companyGSTNo;
    CompanyDetails.companyNumber =
        companyNumber ?? CompanyDetails.companyNumber;
    CompanyDetails.companyEmail = companyEmail ?? CompanyDetails.companyEmail;
  }
}
