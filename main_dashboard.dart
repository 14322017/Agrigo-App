import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import pages
import 'soil_testing.dart';
import 'assistance_help.dart';
import 'historical_data.dart';
import 'general_report.dart';
import 'ai_advisory.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  String _language = "sw"; // sw or en
  bool _detailsSaved = true;

  // Farmer details
  String _farmerName = "John Farmer";
  String _region = "";
  String _ward = "";
  String _district = "";
  String _crop = "Maize";
  var _hectares = "3";
  String _status = "Healthy";

  // Controllers for editing details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _cropController = TextEditingController();
  final TextEditingController _hectaresController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crop Info Data
  final List<Map<String, String>> crops = [
    {
      "name": "Maize",
      "planting": "Plant at onset of rains with spacing 25cm x 75cm.",
      "irrigation": "Water regularly, especially during tasseling.",
      "harvesting": "Harvest 90–120 days after planting when cobs are dry.",
      "soil": "Well-drained loamy soil, pH 5.5 – 7.0",
    },
    {
      "name": "Rice",
      "planting": "Best planted in flooded fields, use certified seeds.",
      "irrigation": "Needs continuous flooding until maturity.",
      "harvesting": "Harvest 100–150 days after planting when grains harden.",
      "soil": "Clay soil, pH 5.0 – 6.5",
    },
    {
      "name": "Cassava",
      "planting": "Use stem cuttings, spacing 1m x 1m.",
      "irrigation": "Requires little irrigation once established.",
      "harvesting": "Harvest 9–12 months after planting.",
      "soil": "Sandy loam, pH 5.5 – 6.5",
    },
    {
      "name": "Coffee",
      "planting": "Plant seedlings under shade at 2.5m x 2.5m spacing.",
      "irrigation": "Needs watering during dry spells.",
      "harvesting": "Harvest after 2–3 years, when berries are red.",
      "soil": "Volcanic soils, pH 6.0 – 6.5",
    },
  ];

  // Recommendations Data
  final List<Map<String, String>> recommendations = [
    {
      "crop": "Maize",
      "advice":
          "Your soil pH is suitable. Apply NPK fertilizer at planting. Weed after 3 weeks.",
    },
    {
      "crop": "Rice",
      "advice":
          "Ensure continuous flooding. Add urea fertilizer at tillering stage.",
    },
    {
      "crop": "Cassava",
      "advice":
          "Cassava grows well in sandy loam. Avoid waterlogging. Apply organic manure.",
    },
    {
      "crop": "Coffee",
      "advice":
          "Maintain shade. Apply compost manure every 6 months. Control pests regularly.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection("users").doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _farmerName = doc["username"] ?? user.email ?? "Farmer";
          _region = doc["region"] ?? "";
          _district = doc["district"] ?? "";
          _ward = doc["ward"] ?? "";
          _crop = doc["crop"] ?? _crop;
          _hectares = doc["hectares"] ?? _hectares;
          _status = doc["status"] ?? _status;
          _detailsSaved = true;
        });
      } else {
        setState(() {
          _farmerName = user.email ?? "Farmer";
        });
      }
    }
  }

  Future<void> _saveUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).set({
        "username": _farmerName,
        "region": _region,
        "district": _district,
        "ward": _ward,
        "crop": _crop,
        "hectares": _hectares,
        "status": _status,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _toggleLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = value;
      prefs.setString("language", value);
    });
  }

  // Function to edit farm details
  void _editFarmDetails(BuildContext context) {
    _nameController.text = _farmerName;
    _regionController.text = _region;
    _districtController.text = _district;
    _wardController.text = _ward;
    _cropController.text = _crop;
    _hectaresController.text = _hectares;
    _statusController.text = _status;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
                title: Text(_language == "sw" ? "Badili Maelezo" : "Edit Details"),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Farmer Name")),
                      TextField(controller: _regionController, decoration: const InputDecoration(labelText: "Region")),
                      TextField(controller: _districtController, decoration: const InputDecoration(labelText: "District")),
                      TextField(controller: _wardController, decoration: const InputDecoration(labelText: "Ward")),
                      TextField(controller: _cropController, decoration: const InputDecoration(labelText: "Crop")),
                      TextField(controller: _hectaresController, decoration: const InputDecoration(labelText: "Hectares")),
                      TextField(controller: _statusController, decoration: const InputDecoration(labelText: "Status")),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _farmerName = _nameController.text;
                        _region = _regionController.text;
                        _district = _districtController.text;
                        _ward = _wardController.text;
                        _crop = _cropController.text;
                        _hectares = _hectaresController.text;
                        _status = _statusController.text;
                        _detailsSaved = true;
                      });
                      _saveUserDetails(); // ✅ Save to Firestore
                      Navigator.pop(ctx);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
    );
  }

  // New: Open General Report Page
  void _openGeneralReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => GeneralReportPage(language: _language),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_language == "sw" ? "AgriGo App" : "AgriGo App"),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            onSelected: _toggleLanguage,
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: "en", child: Text("English")),
              const PopupMenuItem(value: "sw", child: Text("Swahili")),
            ],
            icon: const Icon(Icons.language, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.agriculture, size: 50, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    _language == "sw" ? "Karibu AgriGo" : "Welcome to AgriGo",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (_detailsSaved)
                    Text(
                      "$_farmerName\n$_region, $_district",
                      style: const TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sensors),
              title: Text(_language == "sw" ? "Kupima Udongo" : "Soil Testing"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => SoilTestingPage(language: _language))),
            ),
            ListTile(
              leading: const Icon(Icons.support),
              title: Text(_language == "sw" ? "Msaada" : "Assistance Help"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => AssistanceHelp(language: _language))),
            ),
            ListTile(
              leading: const Icon(Icons.computer),
              title: Text(_language == "sw" ? "Huduma za AI" : "AI Advisory Services"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => AIAdvisoryPage(language: _language))),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(_language == "sw" ? "Historia ya Data" : "Historical Data"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => HistoricalDataPage(language: _language))),
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart),
              title: Text(_language == "sw" ? "Ripoti ya Jumla" : "General Report"),
              onTap: _openGeneralReport, // ✅ Open enhanced general report
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(_language == "sw" ? "Ondoka" : "Logout"),
              onTap: () async {
                await _auth.signOut();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _detailsSaved ? _buildDashboardContent(context) : _buildFarmDetailsForm(),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.green.shade100,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_farmerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [const Icon(Icons.landscape, color: Colors.green), Text("$_hectares Ha")]),
                    Column(children: [const Icon(Icons.check_circle, color: Colors.orange), Text(_status)]),
                    Column(children: [const Icon(Icons.spa, color: Colors.green), Text(_crop)]),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(_language == "sw" ? "Vitendo Haraka" : "Quick Actions", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _quickActionCard(icon: Icons.edit, label: _language == "sw" ? "Badili Maelezo" : "Edit Details", color: Colors.blue, onTap: () => _editFarmDetails(context)),
            _quickActionCard(icon: Icons.science, label: _language == "sw" ? "Pima Udongo" : "Soil Testing", color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => SoilTestingPage(language: _language)))),
            _quickActionCard(icon: Icons.info, label: _language == "sw" ? "Taarifa za Mazao" : "Crop Info", color: Colors.green, onTap: () => _showCropInfoDialog(context)),
            _quickActionCard(icon: Icons.recommend, label: _language == "sw" ? "Mapendekezo" : "Recommendations", color: Colors.purple, onTap: () => _showRecommendationsDialog(context)),
            _quickActionCard(icon: Icons.table_chart, label: _language == "sw" ? "Ripoti ya Jumla" : "General Report", color: Colors.teal, onTap: _openGeneralReport), // ✅ New button
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 40), const SizedBox(height: 10), Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))]),
        ),
      ),
    );
  }

  Widget _buildFarmDetailsForm() => const Center(child: Text("Form to enter farm details here"));

  void _showCropInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Crop Information"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: crops.length,
            itemBuilder: (context, index) {
              final crop = crops[index];
              return Card(
                child: ListTile(
                  title: Text(crop["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("🌱 Planting: ${crop["planting"]}"), Text("💧 Irrigation: ${crop["irrigation"]}"), Text("🌾 Harvesting: ${crop["harvesting"]}"), Text("🌍 Soil & pH: ${crop["soil"]}")]),
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  void _showRecommendationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Recommendations"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return Card(
                child: ListTile(
                  title: Text(rec["crop"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(rec["advice"]!),
                  leading: const Icon(Icons.recommend, color: Colors.green),
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }
}
