// lib/views/support/SupportPage.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import '../services/user_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage>
    with SingleTickerProviderStateMixin {
  // HARD-CODED SUPPORT NUMBERS - 100% reliable
  static const String _callNumber = "+918020014300"; // 080-20014300
  static const String _whatsappNumber = "919743204088"; // +91 97432 04088

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _makeCall() async {
    final Uri uri = Uri(scheme: 'tel', path: _callNumber);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar("Could not open phone dialer");
    }
  }

  Future<void> _openWhatsApp() async {
    final String url = "https://wa.me/$_whatsappNumber";
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar("WhatsApp not installed or number invalid");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  String _formatDisplayNumber(String international) {
    // Converts +918020014300 → 080-20014300
    // Converts 919743204088  → +91 97432 04088
    final digits = international.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      final n = digits.substring(2);
      if (n.startsWith('80') || n.startsWith('70') || n.startsWith('90')) {
        // Mobile: +91 97432 04088
        return '+91 ${n.substring(0, 5)} ${n.substring(5)}';
      } else {
        // Landline: 080-20014300
        return '${n.substring(0, 3)}-${n.substring(3, 7)}${n.length > 7 ? '${n.substring(7)}' : ''}';
      }
    }
    return international;
  }

  @override
  Widget build(BuildContext context) {
    final String? name = UserSession.user?['full_name'];
    final String greeting = name != null ? "Hey $name" : "Hey there".tr();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Customer Support'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Container(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/animations/contact_us.json',
                      height: 180),
                  const SizedBox(height: 10),
                  Text(
                    greeting,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "We're here to help you anytime!",
                    style: TextStyle(fontSize: 16),
                  ).tr(),
                  const SizedBox(height: 40),

                  // Call Card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.greenAccent,
                        child: Icon(Icons.phone, color: Colors.green),
                      ),
                      title:  Text('Call Support'.tr(),
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(_formatDisplayNumber(_callNumber)),
                      trailing:
                          const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      onTap: _makeCall,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // WhatsApp Card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.greenAccent,
                        child: FaIcon(FontAwesomeIcons.whatsapp,
                            color: Colors.green, size: 28),
                      ),
                      title:  Text('Chat on WhatsApp'.tr(),
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(_formatDisplayNumber(_whatsappNumber)),
                      trailing:
                          const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      onTap: _openWhatsApp,
                    ),
                  ),

                  const SizedBox(height: 40),
                  // Optional: Email / FAQ buttons (you can keep or remove)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
