import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_ai/Login/login_screen.dart';
import '../styles/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(seconds: 3), () => Get.off(() => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          color: controller.themeColor.value.shade100,
          child: Column(
            children: [
              const Spacer(),
              // Replace Icon with Image widget for your logo
              Image.asset(
                'assets/logo.png', // replace with your image asset path
                width: 150, // set the width as needed
                height: 150, // set the height as needed
                // color: controller.themeColor.value,
              ),
              const Spacer(),
              CircularProgressIndicator(color: controller.themeColor.value),
              const SizedBox(height: 40),
              Text(
                "Sale's AI",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: controller.themeColor.value,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
