import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:mainproject1/src/core/style/colors.dart';
import 'package:mainproject1/src/features/auth/view_model/login_controller.dart';
import 'package:mainproject1/src/shared/presentation/widgets/custom_text_field.dart';
import 'package:mainproject1/views/auth/OTPVerificationScreen.dart';
import 'package:mainproject1/views/services/api_config.dart';
import 'package:geolocator/geolocator.dart'; // ADDED: For getting GPS location
import 'package:geocoding/geocoding.dart'; // ADDED: For converting lat/lng to pincode

class SignupBottomSheet extends StatefulWidget {
  final String phone;
  const SignupBottomSheet({Key? key, required this.phone}) : super(key: key);

  @override
  State<SignupBottomSheet> createState() => _SignupBottomSheetState();
}

class _SignupBottomSheetState extends State<SignupBottomSheet> {
  final controller = Get.find<LoginController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // String? selectedDistrict; // COMMENTED OUT: Removed district field
  // String? selectedTaluk; // COMMENTED OUT: Removed taluk field
  // String? selectedVillage; // COMMENTED OUT: Removed village field
  bool hasSubmitted = false;
  bool isSubmitting = false;
  bool isLoadingPincode = false; // ADDED: Track pincode loading state

  // List<String> districts = []; // COMMENTED OUT: Not needed anymore
  // List<String> taluks = []; // COMMENTED OUT: Not needed anymore
  // List<String> villagesList = []; // COMMENTED OUT: Not needed anymore

  // Map<String, List<dynamic>> talukasMap = {}; // COMMENTED OUT: Not needed anymore
  // Map<String, List<dynamic>> villagesMap = {}; // COMMENTED OUT: Not needed anymore

  @override
  void initState() {
    super.initState();
    // _loadLocationData(); // COMMENTED OUT: No need to load districts/taluks/villages

    // ADDED: Show location permission popup when signup opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLocationPermissionDialog();
    });
  }

  // ADDED: Beautiful location permission dialog - user MUST select location
  // UPDATED: Removed "Don't Allow" button - location is mandatory now
  Future<void> _showLocationPermissionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // UPDATED: User cannot dismiss, must choose
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // UPDATED: Better rounded corners
          child: Padding(
            padding: const EdgeInsets.all(24), // UPDATED: More padding for better look
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // UPDATED: Better icon design with gradient background
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.buttonPrimary.withOpacity(0.2),
                        AppColors.buttonPrimary.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.my_location_rounded,
                    size: 45,
                    color: AppColors.buttonPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // UPDATED: Title with better styling
                const Text(
                  "Location Required",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // UPDATED: Clear description
                Text(
                  "Turn on location to auto-detect your pincode for faster signup.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // REMOVED: Don't Allow button - location is mandatory now
                // TextButton(
                // onPressed: () {
                // Navigator.of(context).pop();
                // setState(() => isLoadingPincode = false);
                // },
                // child: const Text("Don't Allow"),
                // ),

                // UPDATED: Button - Only This Time with better design
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppColors.buttonPrimary, width: 1.5),
                    ),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop(); // Close dialog
                      await _getUserPincode(accuracy: LocationAccuracy.low); // FIXED: Now triggers location
                    },
                    child: Text(
                      "Only This Time",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.buttonPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // UPDATED: Button - While Using App with gradient
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop(); // Close dialog
                      await _getUserPincode(accuracy: LocationAccuracy.high); // FIXED: Now triggers location + turns on GPS if off
                    },
                    child: const Text(
                      "Enable Location",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // UPDATED: Get user pincode + auto prompt to turn on GPS if it's OFF like Zepto
  Future<void> _getUserPincode({required LocationAccuracy accuracy}) async {
    setState(() => isLoadingPincode = true); // Start loading
    try {
      // 1. Check if location services are enabled on device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      // ADDED: If GPS is OFF, open Android's native "Turn on location?" popup
      // This is the Zepto-style behavior - system dialog to enable GPS
      if (!serviceEnabled) {
        if (mounted) {
          // ADDED: This triggers Android system popup: "Turn on device location?"
          // User sees native dialog with "No thanks" and "OK" buttons
          await Geolocator.openLocationSettings(); // Opens system location settings

          // ADDED: Wait and check again if user enabled it
          await Future.delayed(const Duration(milliseconds: 500));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();

          // ADDED: If still OFF after popup, show our dialog again to force user
          if (!serviceEnabled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location is required to detect pincode")),
            );
            await _showLocationPermissionDialog(); // Re-show our dialog
            setState(() => isLoadingPincode = false);
            return;
          }
        }
      }

      // 2. Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location permission is required for signup")),
            );
            await _showLocationPermissionDialog(); // UPDATED: Re-show dialog if denied
          }
          setState(() => isLoadingPincode = false);
          return;
        }
      }

      // 3. If user permanently denied, open app settings
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Please enable location from settings"),
              action: SnackBarAction(
                label: "Settings",
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        setState(() => isLoadingPincode = false);
        return;
      }

      // 4. Get current GPS coordinates - this works now because GPS is ON
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy, // Use accuracy from dialog selection
      );

      // 5. Convert coordinates to address using reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // 6. Extract pincode from address and fill textfield
      if (placemarks.isNotEmpty && mounted) {
        String? pincode = placemarks.first.postalCode;
        if (pincode!= null && pincode.isNotEmpty) {
          setState(() {
            _pincodeController.text = pincode;
            isLoadingPincode = false;
          });
        } else {
          setState(() => isLoadingPincode = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not detect pincode. Please enter manually.")),
          );
        }
      }
    } catch (e) {
      print("Error getting pincode: $e");
      if (mounted) {
        setState(() => isLoadingPincode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  // COMMENTED OUT: Not needed anymore - removed district/taluk/village loading
  // Future<void> _loadLocationData() async {
  // final String jsonString =
  // await rootBundle.loadString('assets/loadLocation_data.json');
  // final Map<String, dynamic> locationData = json.decode(jsonString);
  //
  // talukasMap = Map.from(locationData['talukas']);
  // villagesMap = Map.from(locationData['villages']);
  //
  // talukasMap.forEach((key, value) {
  // value.sort((a, b) =>
  // a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
  // });
  //
  // villagesMap.forEach((key, value) {
  // value.sort((a, b) =>
  // a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
  // });
  //
  // setState(() {
  // districts =
  // List<String>.from(locationData['districts']['Karnataka']?? []);
  // districts.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  // });
  // }

  Future<void> _submitForm() async {
    setState(() => hasSubmitted = true);

    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      try {
        final userInsertUrl = Uri.parse("${KD.api}/user/insert_user");
        final response = await http.post(
          userInsertUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "phoneNumber": widget.phone,
            "fullName": _nameController.text.trim(),
            "district": "", // COMMENTED OUT - sending empty string
            "taluka": "", // COMMENTED OUT - sending empty string
            "village": "", // COMMENTED OUT - sending empty string
            "pincode": _pincodeController.text.trim(),
            "state": "Karnataka",
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data["status"] == "success") {
          final generateOtpUrl = Uri.parse("${KD.api}/admin/generate_otp");
          final otpResponse = await http.post(
            generateOtpUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"phoneNumber": widget.phone}),
          );

          final otpData = jsonDecode(otpResponse.body);

          if (otpResponse.statusCode == 200 && otpData["status"] == "success") {
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr("Sign_Up_Initiated_Successfully" ))),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      OTPVerificationScreen(phoneNumber: widget.phone),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text(otpData["message"]?? tr("Failed_to_generate_OTP")),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"]?? tr("Registration_failed")),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr("Error: $e"))),
        );
      } finally {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75, //
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr("Sign_Up"),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: tr("Mobile_Number"),
                          readOnly: true,
                          controller: TextEditingController(text: widget.phone),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        // Full Name
                        CustomTextField(
                          controller: _nameController,
                          label: tr("full_name"),
                          keyboardType: TextInputType.name,
                          hint: "Eg: Ram Kumar",
                          validator: (value) => value == null ||
                              value.trim().isEmpty
                              ? tr("please_enter_full_name")
                              : null,
                          onChanged: (value) {
                            if (hasSubmitted) {
                              _formKey.currentState!.validate();
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // District - COMMENTED OUT
                        // DropdownButtonFormField<String>(
                        // value: selectedDistrict,
                        // decoration: _dropdownDecoration(tr("district")),
                        // hint: Text(tr("Select_District"),style: TextStyle(color: Colors.black26),),
                        // items: districts.map((district) {
                        // return DropdownMenuItem(
                        // value: district,
                        // child: Text(district),
                        // );
                        // }).toList(),
                        // onChanged: (value) {
                        // setState(() {
                        // selectedDistrict = value;
                        // selectedTaluk = null;
                        // selectedVillage = null;
                        // taluks = value!= null
                        //? List<String>.from(talukasMap[value]?? [])
                        // : [];
                        // villagesList = [];
                        // });
                        // },
                        // validator: (value) =>
                        // value == null? tr("Please_select_a_district") : null,
                        // ),
                        // const SizedBox(height: 12),

                        // Taluk - COMMENTED OUT
                        // if (selectedDistrict!= null)...[
                        // DropdownButtonFormField<String>(
                        // value: selectedTaluk,
                        // isExpanded: true,
                        // decoration: _dropdownDecoration(tr("taluka")),
                        // hint: Text(tr("Select_Taluka",),style: TextStyle(color: Colors.black26),),
                        // items: taluks.map((taluk) {
                        // return DropdownMenuItem<String>(
                        // value: taluk,
                        // child: Text(
                        // taluk,
                        // overflow: TextOverflow.ellipsis,
                        // ),
                        // );
                        // }).toList(),
                        // onChanged: (value) {
                        // setState(() {
                        // selectedTaluk = value;
                        // selectedVillage = null;
                        // villagesList = value!= null
                        //? List<String>.from(villagesMap[value]?? [])
                        // : [];
                        // });
                        // },
                        // validator: (value) =>
                        // value == null? tr("Please_select_a_taluka") : null,
                        // ),
                        // const SizedBox(height: 12),
                        // ],

                        // Village - COMMENTED OUT
                        // if (selectedTaluk!= null)...[
                        // DropdownButtonFormField<String>(
                        // value: selectedVillage,
                        // isExpanded: true,
                        // decoration: _dropdownDecoration(tr("village")),
                        // hint: Text(tr("Select_Village"),style: TextStyle(color: Colors.black26),),
                        //
                        // items: villagesList.map((village) {
                        // return DropdownMenuItem<String>(
                        // value: village,
                        // child: Text(
                        // village,
                        // overflow: TextOverflow.ellipsis,
                        // ),
                        // );
                        // }).toList(),
                        // onChanged: (value) {
                        // setState(() {
                        // selectedVillage = value;
                        // });
                        // },
                        // validator: (value) =>
                        // value == null? tr("Please_select_a_village") : null,
                        // ),
                        // const SizedBox(height: 12),
                        // ],

                        // Pincode - AUTO-FILLED FROM GPS
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            CustomTextField(
                              controller: _pincodeController,
                              fieldType: TextFieldType.pinCode,
                              keyboardType: TextInputType.number,
                              label: tr("pincode"),
                              hint: isLoadingPincode? "Fetching location..." : "Eg: 568038",
                              readOnly: isLoadingPincode,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return tr("please_enter_pincode");
                                }
                                if (value.length!= 6) {
                                  return tr("pincode_must_be_6_digits");
                                }
                                return null;
                              },
                            ),
                            if (isLoadingPincode)
                              const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 80), // extra space above button
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isSubmitting || isLoadingPincode? null : _submitForm,
                          child: isSubmitting
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Text(tr("submit")),
                        ),
                        // Terms
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text.rich(
                            TextSpan(
                              text: tr("By_continuing,_you_agree_to_our_"),
                              style:
                              const TextStyle(fontSize: 13, color: Colors.black54),
                              children: [
                                TextSpan(
                                  text: tr("Terms_&_Conditions"),
                                  style: const TextStyle(
                                    color: AppColors.buttonPrimary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = controller.openTerms,
                                ),
                                const TextSpan(text: " and "),
                                TextSpan(
                                  text: tr("Privacy_Policy"),
                                  style: const TextStyle(
                                    color: AppColors.buttonPrimary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = controller.openPrivacyPolicy,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
        BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}