import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  TextStyle _titleStyle() => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A202C),
  );

  TextStyle _contentStyle() => const TextStyle(
    fontSize: 14,
    color: Color(0xFF4A5568),
    height: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: const Color(0xFF3182CE), // Blue 600
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _buildSection(
            title: "5. Data Retention and Deletion",
            content:
            "We retain your personal data only for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required by law or to defend legal claims.\n\n"
                "When data is no longer needed:\n"
                "- We securely delete or anonymize it to prevent unauthorized access.\n"
                "- You can request deletion of your personal information (see “Your Rights and Choices”).",
          ),

          _buildSection(
            title: "6. Your Rights and Choices",
            content:
            "Depending on your location and applicable data protection laws, you may have the following rights:\n\n"
                "- Access: Request details about the personal information we hold about you.\n"
                "- Correction: Request corrections to inaccurate or incomplete data.\n"
                "- Deletion: Request deletion of your personal data.\n"
                "- Restriction: Request restrictions on data processing.\n"
                "- Objection: Object to processing for marketing or legitimate interests.\n"
                "- Data portability: Request transfer of your data to another organization.\n\n"
                "To exercise your rights, contact us at Info@Webutsav.com or call 8766922792.",
          ),

          _buildSection(
            title: "7. Cookies and Tracking Technologies",
            content:
            "Our websites and apps may use cookies, web beacons, and similar tracking technologies to:\n\n"
                "- Enhance user experience by remembering preferences and settings.\n"
                "- Analyze usage patterns to improve services.\n"
                "- Serve relevant advertising (with consent where required).\n\n"
                "You can control cookie preferences via browser settings or app permissions. Disabling cookies may impact functionality.",
          ),

          _buildSection(
            title: "8. Data Security Measures",
            content:
            "We implement appropriate security measures to protect your data:\n\n"
                "- Encryption: SSL/TLS for secure transmission.\n"
                "- Access controls: Limited to authorized personnel.\n"
                "- Regular security assessments and system updates.\n"
                "- Employee training on confidentiality and protection.\n\n"
                "While we strive to protect your data, no system is fully secure. Please safeguard your credentials and report suspicious activity.",
          ),

          _buildSection(
            title: "9. Policy for Minors",
            content:
            "Our services are not intended for children under 18.\n\n"
                "- We do not knowingly collect data from minors.\n"
                "- If we find out a minor has shared data, we will delete it promptly.\n\n"
                "Parents can contact Info@Webutsav.com to request deletion of their child’s information.",
          ),

          const SizedBox(height: 20),
          Center(
            child: Text(
              "Last Updated: June 2025",
              style: _contentStyle().copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: _titleStyle()),
        children: [Text(content, style: _contentStyle())],
      ),
    );
  }
}
