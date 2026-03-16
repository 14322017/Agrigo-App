import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AssistanceHelp extends StatefulWidget {
  final String language; // "sw" or "en"
  const AssistanceHelp({super.key, required this.language});

  @override
  State<AssistanceHelp> createState() => _AssistanceHelpState();
}

class _AssistanceHelpState extends State<AssistanceHelp> {
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final isSw = widget.language == "sw";

    final List<Map<String, String>> extensionOfficers = [
      {
        "name": "Bwana Hassan Kilosa",
        "location": "Kilosa HQ",
        "phone": "+255712345678"
      },
      {
        "name": "Bi. Rehema Mtitu",
        "location": "Kilosa Mashariki",
        "phone": "+255713456789"
      },
      {
        "name": "Bwana John Mnyalu",
        "location": "Kilosa Magharibi",
        "phone": "+255714567890"
      },
    ];

    final List<Map<String, String>> agroDealers = [
      {
        "name": "Kilosa Agrovet Supplies",
        "location": "Kilosa Town",
        "phone": "+255715678901"
      },
      {
        "name": "GreenFarm Inputs",
        "location": "Kimamba, Kilosa",
        "phone": "+255716789012"
      },
    ];

    final List<Map<String, String>> seedSuppliers = [
      {
        "name": "Tanzania Seed Co. Kilosa",
        "location": "Kilosa Town",
        "phone": "+255717890123"
      },
      {
        "name": "AgroSeed Dealers",
        "location": "Kilosa Magole",
        "phone": "+255718901234"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isSw ? "Msaada wa Ugani" : "Assistance Help"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isSw ? "Wafanyakazi wa Ugani" : "Extension Officers",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...extensionOfficers.map((o) => _contactCard(o, isSw)),

          const SizedBox(height: 20),
          Text(
            isSw ? "Wauzaji wa Pembejeo" : "Agro Input Dealers",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...agroDealers.map((d) => _contactCard(d, isSw)),

          const SizedBox(height: 20),
          Text(
            isSw ? "Wauzaji wa Mbegu" : "Seed Suppliers",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...seedSuppliers.map((s) => _contactCard(s, isSw)),

          const SizedBox(height: 20),
          Text(
            isSw ? "Msaada wa Dharura" : "Emergency Assistance",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.support_agent, color: Colors.white),
              ),
              title: Text(isSw
                  ? "Meneja wa Kampuni AgriGo"
                  : "AgriGo Company Manager"),
              subtitle: const Text("+255719012345"),
              trailing: ElevatedButton.icon(
                onPressed: () => _makePhoneCall("+255719012345"),
                icon: const Icon(Icons.call),
                label: Text(isSw ? "Piga" : "Call"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(Map<String, String> contact, bool isSw) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(contact["name"]!),
        subtitle: Text(contact["location"]!),
        trailing: ElevatedButton.icon(
          onPressed: () => _makePhoneCall(contact["phone"]!),
          icon: const Icon(Icons.call),
          label: Text(isSw ? "Piga" : "Call"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade100,
            foregroundColor: Colors.green,
          ),
        ),
      ),
    );
  }
}
