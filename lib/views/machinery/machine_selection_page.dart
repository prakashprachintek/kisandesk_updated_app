import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mainproject1/views/services/image_caching.dart';

import '../services/api_config.dart';
import 'bookpage.dart';

class MachineSelectionPage extends StatefulWidget {
  const MachineSelectionPage({super.key});

  @override
  State<MachineSelectionPage> createState() => _MachineSelectionPageState();
}

class _MachineSelectionPageState extends State<MachineSelectionPage> {
  List<Map<String, dynamic>> machineryData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMachinery();
  }

  /// ================= API =================
  Future<void> fetchMachinery() async {
    try {
      final res = await http.post(
        Uri.parse("${KD.api}/app/get_master_data"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"type": "machine"}),
      );

      final data = jsonDecode(res.body);

      if (data["status"] == "success") {
        setState(() {
          machineryData = List<Map<String, dynamic>>.from(
            data["results"][0]["machinery_type"],
          );
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /// ================= IMAGE =================
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

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC), // ✅ LIGHT BACKGROUND

      appBar: AppBar(
        title: const Text(
          "Select_Machinery",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ).tr(),

        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;

                double itemWidth = (width - 48) / 2;
                double itemHeight = itemWidth;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: machineryData.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: itemWidth / itemHeight,
                  ),
                  itemBuilder: (_, i) {
                    final m = machineryData[i];
                    final isKannada = Localizations.localeOf(context).languageCode == 'kn';

final name = isKannada
    ? (m["name_in_kannada"] ?? m["name_in_english"])
    : (m["name_in_english"] ?? m["name"]);

                    return InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookPage(
                              selectedMachine: name,
                              machineData: m,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06), // ✅ SOFT SHADOW
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            children: [
                              /// IMAGE
                              Positioned.fill(
                                //child: networkImage(m["image"]),
                                child: CachedImageWidget(
                                  imageUrl: m["image"] ?? "",
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  ),
                              ),

                              /// LIGHT OVERLAY (soft look)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),

                              /// LIGHT GRADIENT (NOT DARK)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.35), // ✅ LIGHTER
                                        Colors.transparent
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ),

                              /// TEXT
                              Positioned(
                                bottom: 14,
                                left: 12,
                                right: 12,
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}