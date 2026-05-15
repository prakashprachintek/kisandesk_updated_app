import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/services/image_caching.dart';
import 'dart:convert';

import '../services/api_config.dart';
import '../services/user_session.dart';
import 'machinery_rent_page.dart';

class _SuccessPopupContent extends StatefulWidget {
  const _SuccessPopupContent();

  @override
  State<_SuccessPopupContent> createState() => _SuccessPopupContentState();
}

class _SuccessPopupContentState extends State<_SuccessPopupContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _iconScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ✅ ANIMATED ICON
              ScaleTransition(
                scale: _iconScale,
                child: Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00AD83).withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00AD83),
                    size: 60,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Booking_Successful!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ).tr(),

              const SizedBox(height: 10),

              const Text(
                "Your_machinery_booking_is_confirmed.\nWe_will_contact_you_soon.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ).tr(),

              const SizedBox(height: 20),

              /// ✅ BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MachineryRentPage(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AD83),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Go To Home",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookPage extends StatefulWidget {
  final String selectedMachine;
  final Map<String, dynamic> machineData;

  const BookPage({
    super.key,
    required this.selectedMachine,
    required this.machineData,
  });

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  String? selectedMachinery;
  String? selectedWorkType;
  String? bookingDate;

  bool isVehicle = false;
  bool isHarvest = false;

  int quantity = 1;

  List<Map<String, dynamic>> workTypeList = [];

  bool isSubmitting = false;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
final TextEditingController destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();

    selectedMachinery = widget.selectedMachine;

    final name = selectedMachinery!.toLowerCase();

    isVehicle = name.contains("car") || name.contains("cruiser");
    isHarvest = name.contains("harwest") || name.contains("harvest");

    if (!isVehicle) {
      workTypeList = List<Map<String, dynamic>>.from(
        (widget.machineData["work_types"] as List)
            .map((e) => Map<String, dynamic>.from(e)),
      );
    }
  }

  /// DATE
  void pickDate() async {
    DateTime today = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2036),
    );

    if (picked != null) {
      setState(() {
        bookingDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
void showSuccessPopup() {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Success",
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return const SizedBox(); // required
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return Transform.scale(
        scale: Curves.easeOutBack.transform(animation.value),
        child: Opacity(
          opacity: animation.value,
          child: const Center(
            child: _SuccessPopupContent(),
          ),
        ),
      );
    },
  );
}
  /// SUBMIT
void submitBooking() async {
  if (bookingDate == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Select date")));
    return;
  }

  if (!isVehicle && selectedWorkType == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(tr("Select_Work_Type"))));
    return;
  }

  setState(() => isSubmitting = true);

  final uri = Uri.parse("${KD.api}/app/book_machinary");

  final payload = {
    "userId": UserSession.userId,
    "machineryType": selectedMachinery!,
    "workDate": bookingDate!,
    "description": descriptionController.text,
  };

  /// 🚗 VEHICLE (CAR / CRUISER)
  if (isVehicle) {
    payload.addAll({
      "workInQuantity": "$quantity day",
      "sourcepoint": sourceController.text,
      "destinationpoint": destinationController.text,
      "workType": "",
    });
  }

  /// 🌾 HARVEST
  else if (isHarvest) {
    payload.addAll({
      "workInQuantity": "$quantity", // acres/packets
      "workType": selectedWorkType!,
    });
  }

  /// 🚜 NORMAL MACHINES
  else {
    payload.addAll({
      "workInQuantity": "$quantity hour",
      "workType": selectedWorkType!,
    });
  }

  try {
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final responseData = jsonDecode(res.body);

    if (responseData["status"] == "success") {
      showSuccessPopup();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData["message"])),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }

  setState(() => isSubmitting = false);
}

  /// IMAGE
  Widget networkImage(String? url) {
    if (url == null || !url.startsWith("http")) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      cacheWidth: 400,
      loadingBuilder: (c, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (_, __, ___) {
        return Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        );
      },
    );
  }

  /// HEADER
  Widget buildHeader() {
    return Stack(
      children: [
        SizedBox(
          height: 230,
          width: double.infinity,
          //child: networkImage(widget.machineData["image"]),
          child: CachedImageWidget(
            imageUrl: widget.machineData["image"] ?? "",
            width: double.infinity,
            height: 230,
            fit: BoxFit.cover,
            ),
        ),
        Container(
          height: 230,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedMachinery ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (selectedWorkType != null)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 29, 108, 92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    selectedWorkType!,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
            ],
          ),
        )
      ],
    );
  }

  /// 🔥 PREMIUM WORK TYPES
  Widget buildWorkTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select_Work_Type",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D6C5C),
          ),
        ).tr(),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: workTypeList.length,
            itemBuilder: (_, i) {
              final w = workTypeList[i];
              final isKannada =
    Localizations.localeOf(context).languageCode == 'kn';

final name = isKannada
    ? (w["type_in_kannada"] ?? w["type_in_english"])
    : (w["type_in_english"] ?? w["type"]);
              final selected = selectedWorkType == name;

              return GestureDetector(
                onTap: () => setState(() => selectedWorkType = name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF00AD83)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selected
                            ? const Color(0xFF00AD83).withOpacity(0.4)
                            : Colors.black.withOpacity(0.08),
                        blurRadius: selected ? 12 : 6,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedImageWidget(
                            imageUrl: w["image"] ?? "",
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            ),
                          //child: networkImage(w["image"]),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 10,
                          right: 10,
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (selected)
                          const Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// DETAILS
  Widget buildWorkDetails() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Work_Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ).tr(),

          const SizedBox(height: 16),

          /// ================= DATE =================
          const Text(
            "Select_Work_Date",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ).tr(),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF00AD83)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bookingDate ?? "Booking_Date",
                      style: TextStyle(
                        fontSize: 15,
                        color: bookingDate == null ? Colors.grey : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ).tr(),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ================= HOURS =================
          Text(
            isVehicle
            ? "Select_Days".tr()
            : isHarvest
              ? "Select_Quantity".tr()
              : "Select_Hours".tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// MINUS BUTTON
                GestureDetector(
                  onTap: () {
                    if (quantity > 1) {
                      setState(() => quantity--);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: const Icon(Icons.remove),
                  ),
                ),

                /// VALUE
                Column(
                  children: [
                    Text(
                      "$quantity",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isVehicle
                      ? "days"
                      : isHarvest
                      ? "qty"
                      : "hours",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),

                /// PLUS BUTTON
                GestureDetector(
                  onTap: () {
                    setState(() => quantity++);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00AD83),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00AD83).withOpacity(0.4),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ================= DESCRIPTION =================
          const Text(
            "description",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ).tr(),

          const SizedBox(height: 10),

          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "work_description".tr(),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
             child: Column(
  children: [

    /// 🚗 SHOW ONLY FOR VEHICLES
    if (isVehicle) ...[
      const SizedBox(height: 20),

      TextField(
        controller: sourceController,
        decoration: InputDecoration(
          hintText: "Source Location",
          prefixIcon: const Icon(Icons.my_location),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 12),

      TextField(
        controller: destinationController,
        decoration: InputDecoration(
          hintText: "Destination Location",
          prefixIcon: const Icon(Icons.location_on),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],

    /// 🚜 NORMAL MACHINES
    if (!isVehicle) buildWorkTypes(),

    /// DETAILS
    if (isVehicle || selectedWorkType != null)
      buildWorkDetails(),
  ],
),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : submitBooking,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "submit_booking",
                      style: TextStyle(fontSize: 16),
                    ).tr(),
            ),
          )
        ],
      ),
    );
  }
}
