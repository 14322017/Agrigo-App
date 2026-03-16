import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class GeneralReportPage extends StatefulWidget {
  final String language;
  const GeneralReportPage({super.key, required this.language});

  @override
  State<GeneralReportPage> createState() => _GeneralReportPageState();
}

class _GeneralReportPageState extends State<GeneralReportPage> {
  late String _currentLanguage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String farmerName = "";
  List<Map<String, dynamic>> reportData = [];

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language;
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      farmerName = user.displayName ?? user.email ?? "Farmer";
      // Fetch farmer-specific data from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('soilMeasurements')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      reportData = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'date': data['date'] ?? '',
          'time': data['time'] ?? '',
          'crop': data['crop'] ?? '',
          'hectares': data['hectares'] ?? '',
          'ph': data['ph'] ?? '',
          'N': data['N'] ?? '',
          'P': data['P'] ?? '',
          'K': data['K'] ?? '',
          'temperature': data['temperature'] ?? '',
          'moisture': data['moisture'] ?? '',
          'recommendations': data['recommendations'] ?? [],
          'actions': data['actions'] ?? [],
          'status': data['status'] ?? '',
          'assistance': data['assistance'] ?? '',
        };
      }).toList();

      setState(() {});
    }
  }

  void _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            _currentLanguage == "sw"
                ? "Ripoti ya Jumla ya $farmerName"
                : "General Report of $farmerName",
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: [
              'Date',
              'Time',
              'Crop',
              'Hectares',
              'pH',
              'N',
              'P',
              'K',
              'Temp',
              'Moisture',
              'Recommendations',
              'Actions',
              'Status',
              'Assistance'
            ],
            data: reportData.map((entry) {
              return [
                entry['date'],
                entry['time'],
                entry['crop'],
                entry['hectares'].toString(),
                entry['ph'].toString(),
                entry['N'].toString(),
                entry['P'].toString(),
                entry['K'].toString(),
                entry['temperature'].toString(),
                entry['moisture'].toString(),
                (entry['recommendations'] as List).join(", "),
                (entry['actions'] as List).join(", "),
                entry['status'],
                entry['assistance'],
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentLanguage == "sw"
              ? "Ripoti ya Jumla ya $farmerName"
              : "General Report of $farmerName",
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
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
      body: reportData.isEmpty
          ? Center(
              child: Text(
                _currentLanguage == "sw"
                    ? "Hakuna data ya kutokea"
                    : "No data available.",
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Time')),
                  DataColumn(label: Text('Crop')),
                  DataColumn(label: Text('Hectares')),
                  DataColumn(label: Text('pH')),
                  DataColumn(label: Text('N')),
                  DataColumn(label: Text('P')),
                  DataColumn(label: Text('K')),
                  DataColumn(label: Text('Temp')),
                  DataColumn(label: Text('Moisture')),
                  DataColumn(label: Text('Recommendations')),
                  DataColumn(label: Text('Actions')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Assistance')),
                ],
                rows: reportData
                    .map(
                      (entry) => DataRow(cells: [
                        DataCell(Text(entry['date'] ?? '')),
                        DataCell(Text(entry['time'] ?? '')),
                        DataCell(Text(entry['crop'] ?? '')),
                        DataCell(Text(entry['hectares'].toString())),
                        DataCell(Text(entry['ph'].toString())),
                        DataCell(Text(entry['N'].toString())),
                        DataCell(Text(entry['P'].toString())),
                        DataCell(Text(entry['K'].toString())),
                        DataCell(Text(entry['temperature'].toString())),
                        DataCell(Text(entry['moisture'].toString())),
                        DataCell(Text((entry['recommendations'] as List).join(", "))),
                        DataCell(Text((entry['actions'] as List).join(", "))),
                        DataCell(Text(entry['status'] ?? '')),
                        DataCell(Text(entry['assistance'] ?? '')),
                      ]),
                    )
                    .toList(),
              ),
            ),
    );
  }
}
