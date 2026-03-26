import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/user_session.dart';
import 'list_my_machinery_page.dart';
import '../services/api_config.dart';

class ListMyMachinesPage extends StatefulWidget {
  const ListMyMachinesPage({Key? key}) : super(key: key);

  @override
  State<ListMyMachinesPage> createState() => _ListMyMachinesPageState();
}

class _ListMyMachinesPageState extends State<ListMyMachinesPage> {
  List machines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMachines();
  }

  Future<void> deleteMachine(String machineId) async {
    print("Deleting Machine ID: $machineId");

    try {
      final response = await http.post(
        Uri.parse("${KD.api}/user/remove_my_machine"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "_id": machineId,
        }),
      );

      print("Delete Status Code: ${response.statusCode}");
      print("Delete Response: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == "success") {
        setState(() {
          machines.removeWhere((m) => m["_id"] == machineId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Machine_deleted_successfully").tr()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['Message'] ?? "Failed_to_delete_machine".tr()),
          ),
        );
      }
    } catch (e) {
      print("Delete Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something_went_wrong_while_deleting.".tr()),
        ),
      );
    }
  }

  void confirmDelete(String machineId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete_Machine".tr()),
        content: Text("Are_you_sure_you_want_to_delete_this_machine").tr(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel").tr(),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteMachine(machineId);
            },
            child: const Text(
              "delete",
              style: TextStyle(color: Colors.red),
            ).tr(),
          ),
        ],
      ),
    );
  }

  Future<void> fetchMachines() async {
    print("Full session data: ${UserSession.user}");
    print("Session _id: ${UserSession.userId}");
    final String? farmerId = UserSession.userId;

    if (farmerId == null) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("User_not_logged_in"))),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${KD.api}/user/get_my_machines"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"farmerId": farmerId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == "success") {
        setState(() {
          machines = data["results"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          machines = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something_went_wrong._Please_try_again.").tr(),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchWorkTypesForMachine(
      String machineName) async {
    try {
      final res = await http.post(
        Uri.parse("${KD.api}/app/get_master_data"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"type": "machine"}),
      );

      final data = jsonDecode(res.body);

      print("MASTER DATA RESPONSE: $data");

      if (res.statusCode == 200 && data["status"] == "success") {
        // Get machinery list
        final List machineryList = data["results"][0]["machinery_type"];

        // Find correct machinery
        final machinery = machineryList.firstWhere(
          (item) => item["name_in_english"] == machineName,
          orElse: () => null,
        );

        if (machinery != null) {
          return List<Map<String, dynamic>>.from(machinery["work_types"]);
        }
      }
    } catch (e) {
      print("Master Data Error: $e");
    }

    return [];
  }

  Future<void> updateMachineWorkTypes(
      String machineId, List<String> workTypes) async {
    try {
      final response = await http.post(
        Uri.parse("${KD.api}/user/update_my_machine"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "_id": machineId,
          "workTypes": workTypes,
        }),
      );

      final data = jsonDecode(response.body);

      print("UPDATE RESPONSE: $data");

      if (response.statusCode == 200 && data["status"] == "success") {
        setState(() {
          final index = machines.indexWhere((m) => m["_id"] == machineId);
          if (index != -1) {
            machines[index]["work_types"] = workTypes;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Machine_updated_successfully").tr(),
          ),
        );
      }
    } catch (e) {
      print("Update Error: $e");
    }
  }

  void showEditWorkTypesBottomSheet(Map machine) async {
    // Get selected work types
    List<String> selectedWorkTypes =
        List<String>.from(machine["work_types"] ?? []);

    // Get machine name (first machinery type)
    String machineName = (machine["machinery_type"] as List).first;

    // Fetch work types from master API
    List<Map<String, dynamic>> masterWorkTypes =
        await fetchWorkTypesForMachine(machineName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit_Work_Types",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ).tr(),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: masterWorkTypes.length,
                      itemBuilder: (context, index) {
                        final item = masterWorkTypes[index];

                        final String name = item["type_in_english"];
                        final String image = item["image"] ?? "";

                        final bool isSelected =
                            selectedWorkTypes.contains(name);

                        return GestureDetector(
                          onTap: () {
                            setStateSheet(() {
                              if (isSelected) {
                                selectedWorkTypes.remove(name);
                              } else {
                                selectedWorkTypes.add(name);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2E7D65)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              color: isSelected
                                  ? Colors.green.shade50
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                // Image from API
                                if (image.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      image,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  const Icon(Icons.image, size: 60),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),

                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? const Color(0xFF2E7D65)
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D65),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await updateMachineWorkTypes(
                            machine["_id"], selectedWorkTypes);
                      },
                      child: const Text("Update").tr(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildMachineCard(Map machine) {
    final List machineryTypes = machine["machinery_type"] ?? [];
    final List workTypes = machine["work_types"] ?? [];
    final String VehicleNumber = machine["vehicle_number"]?.toString() ?? "N/A";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        machineryTypes.first.toString(),
                        style: const TextStyle(
                          color: Colors.teal,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showEditWorkTypesBottomSheet(machine);
                      },
                    ),
                    //const SizedBox(width: 2),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        confirmDelete(machine["_id"]);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 1),
            Row(
              children: [
                const Icon(Icons.directions_car,
                    size: 18, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  "Vehicle No: $VehicleNumber",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              "Works",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ).tr(),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: workTypes
                  .map<Widget>((type) => Chip(
                        label: Text(type.toString()),
                        backgroundColor: Colors.blue.shade100,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "List_My_Machines",
          style: TextStyle(fontWeight: FontWeight.w600),
        ).tr(),
        backgroundColor: const Color(0xFF2E7D65),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : machines.isEmpty
              ? Center(
                  child: Text(
                    "No_Machines_Added_Yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ).tr(),
                )
              : RefreshIndicator(
                  onRefresh: fetchMachines,
                  child: ListView.builder(
                    itemCount: machines.length,
                    itemBuilder: (context, index) {
                      return buildMachineCard(machines[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D65),
        icon: const Icon(Icons.add),
        label: const Text("Add_Machine").tr(),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ListMyMachineryPage(),
            ),
          );

          fetchMachines(); // Refresh after returning
        },
      ),
    );
  }
}
