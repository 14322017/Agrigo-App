import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class AIAdvisoryPage extends StatefulWidget {
  final String language;
  const AIAdvisoryPage({super.key, required this.language});

  @override
  State<AIAdvisoryPage> createState() => _AIAdvisoryPageState();
}

class _AIAdvisoryPageState extends State<AIAdvisoryPage> {
  // Input fields
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();

  bool _isLoading = false;
  String _advisoryResult = "";

  List<Map<String, dynamic>> historicalData = [];
  List<Map<String, String>> recommendationsHistory = [];

  // Current language state
  late String _currentLanguage;

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _loadHistoricalData();
    _loadFirebaseData();
  }

  // Load SharedPreferences data
  Future<void> _loadHistoricalData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('soilData');
    String? recs = prefs.getString('recommendationsHistory');

    if (data != null) {
      historicalData = List<Map<String, dynamic>>.from(json.decode(data));
    }
    if (recs != null) {
      recommendationsHistory = List<Map<String, String>>.from(
        json.decode(recs),
      );
    }
    setState(() {});
  }

  // Save to SharedPreferences
  Future<void> _saveHistoricalData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('soilData', json.encode(historicalData));
    prefs.setString(
      'recommendationsHistory',
      json.encode(recommendationsHistory),
    );
  }

  // Load data from Firebase
  Future<void> _loadFirebaseData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot =
          await _firestore
              .collection('ai_advisory')
              .where('userId', isEqualTo: user.uid)
              .orderBy('timestamp', descending: true)
              .get();

      final List<Map<String, dynamic>> firebaseData =
          snapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        historicalData = firebaseData;
        recommendationsHistory =
            firebaseData
                .map(
                  (entry) => {
                    'date': "${entry['date']} ${entry['time']}",
                    'advice': entry['advisory']?.toString() ?? '',
                  },
                )
                .toList();
      });
      _saveHistoricalData(); // Keep SharedPreferences synced
    }
  }

  // Save one entry to Firebase
  Future<void> _saveToFirebase(Map<String, dynamic> entry) async {
    final user = _auth.currentUser;
    if (user != null) {
      entry['userId'] = user.uid;
      entry['timestamp'] = FieldValue.serverTimestamp();
      await _firestore.collection('ai_advisory').add(entry);
    }
  }

  // ===========================
  // API call to trained Crop AI
  // ===========================
  Future<Map<String, dynamic>> _aiadvisory ({
    required double ph,
    required double moisture,
    required double temperature,
    required double n,
    required double p,
    required double k,
  }) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
      "http://<YOUR_SERVER_IP>:8000/predict",
    ); // replace with your FastAPI IP
    final soilData = {
      "N": n,
      "P": p,
      "K": k,
      "Temperature": temperature,
      "Moisture": moisture,
      "pH": ph,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(soilData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> res =
            jsonDecode(response.body)["predictions"];
        return res; // Each crop -> list of recommendations
      } else {
        throw Exception("Failed to get predictions");
      }
    } catch (e) {
      return {};
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _runAdvisory() async {
    final phText = _phController.text.trim();
    final moistureText = _moistureController.text.trim();
    final tempText = _temperatureController.text.trim();
    final nText = _nController.text.trim();
    final pText = _pController.text.trim();
    final kText = _kController.text.trim();

    if ([
      phText,
      moistureText,
      tempText,
      nText,
      pText,
      kText,
    ].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _currentLanguage == "sw"
                ? "Tafadhali jaza mashamba yote"
                : "Please fill all fields",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ph = double.tryParse(phText);
    final moisture = double.tryParse(moistureText);
    final temperature = double.tryParse(tempText);
    final n = double.tryParse(nText);
    final p = double.tryParse(pText);
    final k = double.tryParse(kText);

    if ([ph, moisture, temperature, n, p, k].any((e) => e == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _currentLanguage == "sw"
                ? "Tafadhali weka nambari halali"
                : "Please enter valid numbers",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _advisoryResult = "";
    });

    // Call the trained model API
    final predictions = await _aiadvisory(
      ph: ph!,
      moisture: moisture!,
      temperature: temperature!,
      n: n!,
      p: p!,
      k: k!,
    );

    // Build advisory text
    String advisoryText = "";
    predictions.forEach((cropName, recs) {
      advisoryText += "🌾 $cropName:\n";
      for (var i = 0; i < recs.length; i++) {
        advisoryText += "${i + 1}. ${recs[i]}\n";
      }
      advisoryText += "\n";
    });

    final now = DateTime.now();
    final entry = {
      "date": DateFormat('yyyy-MM-dd').format(now),
      "time": DateFormat('HH:mm').format(now),
      "ph": ph,
      "moisture": moisture,
      "temperature": temperature,
      "N": n,
      "P": p,
      "K": k,
      "advisory": advisoryText,
      "predictions": predictions,
    };

    setState(() {
      _advisoryResult = advisoryText;
      _isLoading = false;

      historicalData.add(entry);
      recommendationsHistory.add({
        "date": "${entry['date']} ${entry['time']}",
        "advice": advisoryText,
      });
    });

    _saveHistoricalData();
    _saveToFirebase(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentLanguage == "sw" ? "Huduma za AI" : "AI Advisory Services",
        ),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _currentLanguage = value;
              });
            },
            itemBuilder:
                (ctx) => [
                  const PopupMenuItem(value: "en", child: Text("English")),
                  const PopupMenuItem(value: "sw", child: Text("Swahili")),
                ],
            icon: const Icon(Icons.language, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _phController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            _currentLanguage == "sw"
                                ? "pH ya Udongo"
                                : "Soil pH",
                      ),
                    ),
                    TextField(
                      controller: _moistureController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            _currentLanguage == "sw"
                                ? "Unyevu (%)"
                                : "Moisture (%)",
                      ),
                    ),
                    TextField(
                      controller: _temperatureController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            _currentLanguage == "sw"
                                ? "Joto (°C)"
                                : "Temperature (°C)",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "N"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _pController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "P"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _kController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "K"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _runAdvisory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text(
                          _currentLanguage == "sw"
                              ? "Pata Ushauri"
                              : "Get Advisory",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _advisoryResult.isEmpty
                ? Container()
                : Card(
                  color: Colors.green.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentLanguage == "sw"
                              ? "Ushauri uliopatikana"
                              : "Advisory Result",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _advisoryResult,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            Text(
              _currentLanguage == "sw"
                  ? "Historia ya Mapendekezo"
                  : "Advisory History",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            recommendationsHistory.isEmpty
                ? Text(
                  _currentLanguage == "sw"
                      ? "Hakuna mapendekezo yaliyopatikana"
                      : "No advisory data yet.",
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      recommendationsHistory.length > 5
                          ? 5
                          : recommendationsHistory.length,
                  itemBuilder: (ctx, index) {
                    final rec =
                        recommendationsHistory[recommendationsHistory.length -
                            1 -
                            index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.recommend,
                          color: Colors.purple,
                        ),
                        title: Text(rec["date"] ?? ""),
                        subtitle: Text(rec["advice"] ?? ""),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
