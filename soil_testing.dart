import 'package:flutter/material.dart';

class SoilTestingPage extends StatefulWidget {
  final String language;
  const SoilTestingPage({super.key, required this.language});

  @override
  State<SoilTestingPage> createState() => _SoilTestingPageState();
}

class _SoilTestingPageState extends State<SoilTestingPage> {
  // Example sensor data (you’ll later replace with real sensor API)
  double _ph = 6.2;
  double _moisture = 45.0; // %
  double _nitrogen = 35.0; // mg/kg
  double _phosphorus = 20.0; // mg/kg
  double _potassium = 40.0; // mg/kg

  // Example function to generate recommendations
  String _getRecommendation() {
    if (_ph < 5.5) {
      return widget.language == "sw"
          ? "Udongo una asidi sana, ongeza chokaa."
          : "Soil is too acidic, add lime.";
    } else if (_moisture < 30) {
      return widget.language == "sw"
          ? "Udongo una unyevu kidogo, ongeza umwagiliaji."
          : "Soil moisture is low, increase irrigation.";
    } else if (_nitrogen < 20) {
      return widget.language == "sw"
          ? "Ongeza mbolea yenye Nitrojeni (urea, CAN)."
          : "Add nitrogen fertilizer (urea, CAN).";
    } else if (_phosphorus < 15) {
      return widget.language == "sw"
          ? "Ongeza mbolea yenye Fosforasi (DAP, TSP)."
          : "Add phosphorus fertilizer (DAP, TSP).";
    } else if (_potassium < 25) {
      return widget.language == "sw"
          ? "Ongeza mbolea yenye Potasiamu (MOP)."
          : "Add potassium fertilizer (MOP).";
    }
    return widget.language == "sw"
        ? "Udongo wako uko vizuri kwa kilimo."
        : "Your soil is healthy for farming.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == "sw" ? "Kupima Udongo" : "Soil Testing"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sensor data display
            Expanded(
              child: ListView(
                children: [
                  _buildSensorCard(
                      widget.language == "sw" ? "pH ya Udongo" : "Soil pH",
                      _ph.toString()),
                  _buildSensorCard(
                      widget.language == "sw"
                          ? "Unyevu wa Udongo (%)"
                          : "Soil Moisture (%)",
                      "$_moisture%"),
                  _buildSensorCard(
                      "Nitrogen (mg/kg)", _nitrogen.toString()),
                  _buildSensorCard(
                      "Phosphorus (mg/kg)", _phosphorus.toString()),
                  _buildSensorCard(
                      "Potassium (mg/kg)", _potassium.toString()),
                ],
              ),
            ),

            // Recommendation section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightGreen.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.recommend, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getRecommendation(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Button to refresh sensor data (simulate reading new data)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  // simulate new data (in real case: fetch from sensor)
                  _ph = 5.3;
                  _moisture = 25.0;
                  _nitrogen = 18.0;
                  _phosphorus = 12.0;
                  _potassium = 22.0;
                });
              },
              icon: const Icon(Icons.sensors),
              label: Text(widget.language == "sw"
                  ? "Soma Data za Sensor"
                  : "Read Sensor Data"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for clean sensor cards
  Widget _buildSensorCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.science, color: Colors.green),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
