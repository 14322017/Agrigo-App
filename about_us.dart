import 'package:agrigo_app/main_dashboard.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  String _selectedLanguage = "en"; // Default = English

  final Map<String, Map<String, String>> content = {
    "en": {
      "title": "About AgriGo",
      "general":
          "AgriGo is a smart agricultural mobile application designed to help farmers protect their crops and successfully reach the market. "
          "The app combines soil monitoring with AI-powered advisory services to support farmers in making better decisions. "
          "Extension officers, agro-dealers, and other experts are also connected to provide timely support. "
          "Together, we protect the crops and ensure they reach the market.",
      "soilHeading": "How to Monitor Your Soil",
      "soilDescription":
          "AgriGo provides soil testing services using smart soil sensors. "
          "These sensors detect early signs of problems that may affect crops. "
          "Before planting, farmers can understand the health of their soil and take corrective measures. "
          "After planting, continuous monitoring helps farmers know what actions to take at every stage, protecting crops and improving productivity.",
      "aiHeading": "AI Advisory Services",
      "aiDescription":
          "AgriGo also offers AI-powered advisory services that provide farmers with valuable recommendations and data-driven decision-making support. "
          "Farmers can get personalized advice on crop management, pest control, and soil treatment. "
          "The platform connects farmers with agro-dealers, extension officers, experts, and even transportation services—helping them move their crops efficiently to the market.",
      "contactHeading": "Contact & Location",
      "contactDetails":
          "📍 Location: Morogoro, Vumero, P.O. Box 01, Mzumbe University\n"
          "📞 Phone: 0718 068 895 / 0694 481 232\n"
          "🕒 Working Hours: Monday - Friday, 8:00 AM - 5:00 PM\n\n"
          "💳 All services require a valid subscription for full access.",
    },
    "sw": {
      "title": "Kuhusu AgriGo",
      "general":
          "AgriGo ni programu ya kilimo yenye akili iliyoundwa kusaidia wakulima kulinda mazao yao na kuyafikisha sokoni kwa mafanikio. "
          "Programu hii inachanganya ufuatiliaji wa udongo na huduma za ushauri zinazoendeshwa na AI ili kusaidia wakulima kufanya maamuzi bora. "
          "Maafisa ugani, wauzaji wa pembejeo, na wataalam wengine pia wanaunganishwa ili kutoa msaada kwa wakati. "
          "Pamoja, tunalinda mazao na kuhakikisha yanafika sokoni.",
      "soilHeading": "Jinsi ya Kufuatilia Udongo Wako",
      "soilDescription":
          "AgriGo inatoa huduma za kupima udongo kwa kutumia vihisi vya kisasa. "
          "Vihisi hivi hutambua dalili za awali zinazoweza kuathiri mazao. "
          "Kabla ya kupanda, mkulima anaweza kuelewa afya ya udongo na kuchukua hatua stahiki. "
          "Baada ya kupanda, kufuatilia kwa muda wote humsaidia mkulima kujua hatua za kuchukua kila wakati, kulinda mazao na kuongeza uzalishaji.",
      "aiHeading": "Huduma za Ushauri wa AI",
      "aiDescription":
          "AgriGo pia hutoa huduma za ushauri zinazoendeshwa na AI ambazo zinawapa wakulima mapendekezo muhimu na msaada wa kufanya maamuzi kupitia taarifa za kidigitali. "
          "Wakulima hupokea ushauri binafsi kuhusu usimamizi wa mazao, kudhibiti wadudu, na matibabu ya udongo. "
          "Jukwaa linawaunganisha wakulima na wauzaji wa pembejeo, maafisa ugani, wataalam, na hata huduma za usafirishaji—kuwawezesha kufikisha mazao yao sokoni kwa ufanisi.",
      "contactHeading": "Mawasiliano na Mahali",
      "contactDetails":
          "📍 Eneo: Morogoro, Vumero, SLP 01, Chuo Kikuu cha Mzumbe\n"
          "📞 Simu: 0718 068 895 / 0694 481 232\n"
          "🕒 Saa za Kazi: Jumatatu - Ijumaa, Saa 2:00 Asubuhi - 11:00 Jioni\n\n"
          "💳 Huduma zote zinahitaji usajili wa malipo ili kupata huduma kamili.",
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      content[_selectedLanguage]!["title"]!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // General description
                  Text(
                    content[_selectedLanguage]!["general"]!,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 30),

                  // Soil Monitoring Section
                  Text(
                    content[_selectedLanguage]!["soilHeading"]!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    content[_selectedLanguage]!["soilDescription"]!,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/images/soil_sensors.jpg",
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "📸 Soil sensors testing moisture, nutrients, and temperature in the farm.",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 14),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // AI Advisory Section
                  Text(
                    content[_selectedLanguage]!["aiHeading"]!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    content[_selectedLanguage]!["aiDescription"]!,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/images/ai_services.jpg",
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "📸 Farmer using mobile phone to read soil data and get AI recommendations.",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 14),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // New Contact & Location Section
                  Text(
                    content[_selectedLanguage]!["contactHeading"]!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    content[_selectedLanguage]!["contactDetails"]!,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // Go to Dashboard Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainDashboard(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Go to Dashboard",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Language Switch Buttons (unchanged)
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                children: [
                  _buildLangButton("EN", "en"),
                  const SizedBox(width: 5),
                  _buildLangButton("SW", "sw"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String label, String code) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _selectedLanguage == code ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedLanguage == code ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
