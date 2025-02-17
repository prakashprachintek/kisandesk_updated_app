import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';
import '../auth/AuthSelectionScreen.dart';
import '../widgets/GradientButton.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> onboardingTexts = [
    "Buy & Sell Agricultural Crops with Ease",
    "Find the Best Machinery & Equipment",
    "Connect with Dealers & Manufacturers",
  ];

  final List<String> onboardingFiles = [
    "assets/animations/onb1.json",
    "assets/animations/onb2.json",
    "assets/animations/onb3.json",
  ];

  void _nextPage() {
    if (_currentIndex < onboardingFiles.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingFiles.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(onboardingFiles[index], width: 300, height: 300),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        onboardingTexts[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    if (index == onboardingFiles.length - 1)
                      GradientButton(
                        text: "Get Started",
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => AuthSelectionScreen()),
                          );
                        },
                      )
                  ],
                ),
              );
            },
          ),
          // Skip top-right
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: _skip,
              child: Text(
                "Skip",
                style: TextStyle(fontSize: 16, color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // next bottom-center if not last
          if (_currentIndex < onboardingFiles.length - 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GradientButton(
                  text: "Next",
                  onPressed: _nextPage,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
