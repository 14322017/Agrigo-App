import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoricalDataPage extends StatefulWidget {
  final String language;
  const HistoricalDataPage({super.key, required this.language});

  @override
  State<HistoricalDataPage> createState() => _HistoricalDataPageState();
}

class _HistoricalDataPageState extends State<HistoricalDataPage> {
  List<Map<String, dynamic>> soilData = []; // Store soil readings
  List<Map<String, String>> recommendationsHistory = []; // Store advice
  late String _currentLanguage;

  // Controllers for adding new sensor data
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _cropController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _loadSoilData();
    _loadFirebaseData();
  }

  Future<void> _loadSoilData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('soilData');
    String? recs = prefs.getString('recommendationsHistory');

    if (data != null) {
      setState(() {
        soilData = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }

    if (recs != null) {
      setState(() {
        recommendationsHistory = List<Map<String, String>>.from(
          json.decode(recs),
        );
      });
    }
  }

  Future<void> _saveSoilData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('soilData', json.encode(soilData));
    prefs.setString(
      'recommendationsHistory',
      json.encode(recommendationsHistory),
    );
  }

  // Load data from Firebase
  Future<void> _loadFirebaseData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('soil_tests')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      final List<Map<String, dynamic>> firebaseData = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      setState(() {
        soilData = firebaseData;
        recommendationsHistory = firebaseData
            .map((entry) => {
                  'date': "${entry['date']} ${entry['time']}",
                  'advice': entry['advisory']?.toString() ?? '',
                })
            .toList();
      });
    }
  }

  // Save data to Firebase
  Future<void> _saveToFirebase(Map<String, dynamic> entry) async {
    final user = _auth.currentUser;
    if (user != null) {
      entry['userId'] = user.uid;
      entry['timestamp'] = FieldValue.serverTimestamp();
      await _firestore.collection('soil_tests').add(entry);
    }
  }

  void addSoilData() {
    final phText = _phController.text.trim();
    final moistureText = _moistureController.text.trim();
    final tempText = _temperatureController.text.trim();
    final nText = _nController.text.trim();
    final pText = _pController.text.trim();
    final kText = _kController.text.trim();
    final cropText = _cropController.text.trim();

    if (phText.isEmpty || moistureText.isEmpty || tempText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _currentLanguage == "sw"
                ? "Tafadhali jaza pH, unyevu na joto"
                : "Please enter pH, moisture, and temperature",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ph = double.tryParse(phText);
    final moisture = double.tryParse(moistureText);
    final temperature = double.tryParse(tempText);
    final n = double.tryParse(nText) ?? 0;
    final p = double.tryParse(pText) ?? 0;
    final k = double.tryParse(kText) ?? 0;

    if (ph == null || moisture == null || temperature == null) {
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

    final now = DateTime.now();
    final advice = _generateRecommendation(ph, n, p, k, cropText);

    final newEntry = {
      "date": DateFormat('yyyy-MM-dd').format(now),
      "time": DateFormat('HH:mm').format(now),
      "ph": ph,
      "moisture": moisture,
      "temperature": temperature,
      "N": n,
      "P": p,
      "K": k,
      "crop": cropText,
      "remarks": _remarksController.text.trim(),
      "advisory": advice,
    };

    setState(() {
      soilData.add(newEntry);
      recommendationsHistory.add({
        "date": "${newEntry['date']} ${newEntry['time']}",
        "advice": advice,
      });
    });

    _saveSoilData();
    _saveToFirebase(newEntry);

    // Clear fields
    _phController.clear();
    _moistureController.clear();
    _temperatureController.clear();
    _nController.clear();
    _pController.clear();
    _kController.clear();
    _cropController.clear();
    _remarksController.clear();
  }

  String _generateRecommendation(
      double ph, double n, double p, double k, String crop) {
    String recommendation = "";

    if (ph < 5.5) {
      recommendation += _currentLanguage == "sw"
          ? "Udongo ni chachu. Ongeza lime. "
          : "Soil is acidic. Add lime. ";
    } else if (ph > 7.0) {
      recommendation += _currentLanguage == "sw"
          ? "Udongo ni alcalini. Ongeza mbolea asili. "
          : "Soil is alkaline. Add organic matter. ";
    } else {
      recommendation +=
          _currentLanguage == "sw" ? "pH ya udongo ni nzuri. " : "Soil pH is optimal. ";
    }

    if (crop.toLowerCase() == "maize") {
      if (n < 50) recommendation += _currentLanguage == "sw" ? "Ongeza N. " : "Increase N. ";
      if (p < 30) recommendation += _currentLanguage == "sw" ? "Ongeza P. " : "Increase P. ";
      if (k < 50) recommendation += _currentLanguage == "sw" ? "Ongeza K. " : "Increase K. ";
    } else if (crop.toLowerCase() == "rice") {
      if (n < 40) recommendation += _currentLanguage == "sw" ? "Ongeza N. " : "Increase N. ";
      if (p < 25) recommendation += _currentLanguage == "sw" ? "Ongeza P. " : "Increase P. ";
      if (k < 30) recommendation += _currentLanguage == "sw" ? "Ongeza K. " : "Increase K. ";
    } else if (crop.toLowerCase() == "cassava") {
      if (n < 20) recommendation += _currentLanguage == "sw" ? "Ongeza N. " : "Increase N. ";
      if (p < 15) recommendation += _currentLanguage == "sw" ? "Ongeza P. " : "Increase P. ";
      if (k < 30) recommendation += _currentLanguage == "sw" ? "Ongeza K. " : "Increase K. ";
    } else if (crop.toLowerCase() == "coffee") {
      if (n < 25) recommendation += _currentLanguage == "sw" ? "Ongeza N. " : "Increase N. ";
      if (p < 20) recommendation += _currentLanguage == "sw" ? "Ongeza P. " : "Increase P. ";
      if (k < 25) recommendation += _currentLanguage == "sw" ? "Ongeza K. " : "Increase K. ";
    }

    return recommendation.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentLanguage == "sw" ? "Historia ya Udongo" : "Soil Historical Data",
        ),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _currentLanguage = value;
              });
            },
            itemBuilder: (ctx) => [
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
            // Existing UI with Cards and ListViews
            // Copy your previous code for displaying soilData and recommendationsHistory here
          ],
        ),
      ),
    );
  }
}
