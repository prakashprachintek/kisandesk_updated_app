// lib/views/support/SupportPage.dart
import 'package:flutter/material.dart';
import 'package:mainproject1/src/core/constant/local_db_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    String _callNumber = '';
    String _whatsappNumber = '';

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  init() async {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    SharedPreferences pref = await SharedPreferences.getInstance();
    _callNumber =  pref.getString(LocalDBConstant.supportMobileNumber.key) ?? "08020014300";
    _whatsappNumber = pref.getString(LocalDBConstant.supportWhatsAppNumber.key) ?? "919743204088";
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _makeCall() async {
    final Uri uri = Uri(scheme: 'tel', path: _callNumber);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $uri');
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri uri = Uri.parse('https://wa.me/$_whatsappNumber');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $uri');
    }
  }

  void _confirmAction(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? name = UserSession.user?['full_name'];
    final String greeting = name != null ? "Hey $name 👋" : "Hey there 👋";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Customer Support'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        /*
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74EBD5), Color(0xFFACB6E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        */
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ---- Lottie Animation ----------------------------------
                  Lottie.asset(
                    'assets/animations/contact_us.json',
                    height: 180,
                  ),

                  const SizedBox(height: 10),

                  // ---- Greeting -------------------------------------------
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We're here to help you anytime!",
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ---- Call Card -----------------------------------------
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.green.shade50,
                        child: const Icon(Icons.phone, color: Colors.green),
                      ),
                      title: Text(
                        'Call Support',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800),
                      ),
                      subtitle: Text(_callNumber),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.grey),
                      // onTap: () => _confirmAction(
                      //   "Call Support",
                      //   "Do you want to call $_callNumber?",
                      //   _makeCall,
                      // ),
                      onTap: () => _makeCall(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---- WhatsApp Card -------------------------------------
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.green.shade50,
                        child: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Chat on WhatsApp',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                          _formatWhatsAppNumber(_whatsappNumber),),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.grey),
                      // onTap: () => _confirmAction(
                      //   "Open WhatsApp",
                      //   "Do you want to chat with support on WhatsApp?",
                      //   _openWhatsApp,
                      // ),
                      onTap: _openWhatsApp,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---- Additional contact links --------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.email_outlined,
                            color: Colors.white, size: 28),
                        onPressed: () async {
                          final Uri uri = Uri(
                            scheme: 'mailto',
                            path: 'support@yourapp.com',
                            query: 'subject=Support Request',
                          );
                          await launchUrl(uri);
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.help_outline,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          // Navigate to FAQ screen or docs link
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
    String _formatWhatsAppNumber(String? number) {
      if (number == null || number.isEmpty) {
        return 'N/A'; // or ''
      }

      // Remove spaces and symbols, just in case
      final clean = number.replaceAll(RegExp(r'\D'), '');

      // Example: if you expect country code + number (e.g., 919876543210)
      if (clean.length > 2) {
        final countryCode = clean.substring(0, 2);
        final rest = clean.substring(2);
        return '+$countryCode $rest';
      }

      // If too short, return as-is
      return number;
    }
}
