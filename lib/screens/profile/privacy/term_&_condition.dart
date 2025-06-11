import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  // Color scheme
  static const Color primaryColor = Color(0xFF7C3AED); // Purple
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color accentColor = Color(0xFF06B6D4); // Cyan
  static const Color borderColor = Color(0xFFE2E8F0);

  // Text styles
  TextStyle _titleStyle() => const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.2,
  );

  TextStyle _contentStyle() => const TextStyle(
    fontSize: 15,
    color: textSecondary,
    height: 1.7,
    letterSpacing: 0.1,
  );

  TextStyle _headerStyle() => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  TextStyle _subHeaderStyle() =>
      const TextStyle(fontSize: 16, color: textSecondary, height: 1.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 4,
            centerTitle: true,
            title: const Text(
              'Terms & Conditions',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.article_rounded,
                                color: accentColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Terms of Service',
                                style: _headerStyle(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Please read these terms carefully as they govern your use of our services and outline your rights and responsibilities.',
                          style: _subHeaderStyle(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms Sections
                  _buildSection(
                    icon: Icons.delete_forever_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: "1. Data Retention and Deletion",
                    content:
                        "We retain your personal data only for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required by law or to defend legal claims.\n\n"
                        "When data is no longer needed:\n"
                        "• We securely delete or anonymize it to prevent unauthorized access\n"
                        "• You can request deletion of your personal information (see \"Your Rights and Choices\")\n"
                        "• Automated deletion processes ensure compliance with retention policies\n"
                        "• Backup systems are also purged according to our retention schedule",
                  ),

                  _buildSection(
                    icon: Icons.verified_user_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: "2. Your Rights and Choices",
                    content:
                        "Depending on your location and applicable data protection laws, you may have the following rights:\n\n"
                        "• Access: Request details about the personal information we hold about you\n"
                        "• Correction: Request corrections to inaccurate or incomplete data\n"
                        "• Deletion: Request deletion of your personal data\n"
                        "• Restriction: Request restrictions on data processing\n"
                        "• Objection: Object to processing for marketing or legitimate interests\n"
                        "• Data portability: Request transfer of your data to another organization\n\n"
                        "To exercise your rights, contact us at Info@Webutsav.com or call 8766922792.",
                  ),

                  _buildSection(
                    icon: Icons.cookie_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: "3. Cookies and Tracking Technologies",
                    content:
                        "Our websites and apps may use cookies, web beacons, and similar tracking technologies to:\n\n"
                        "• Enhance user experience by remembering preferences and settings\n"
                        "• Analyze usage patterns to improve services\n"
                        "• Serve relevant advertising (with consent where required)\n"
                        "• Enable social media features and functionality\n"
                        "• Provide security features and fraud prevention\n\n"
                        "You can control cookie preferences via browser settings or app permissions. Disabling cookies may impact functionality.",
                  ),

                  _buildSection(
                    icon: Icons.security_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    title: "4. Data Security Measures",
                    content:
                        "We implement appropriate security measures to protect your data:\n\n"
                        "• Encryption: SSL/TLS for secure transmission and AES encryption for data at rest\n"
                        "• Access controls: Multi-factor authentication and role-based access limited to authorized personnel\n"
                        "• Regular security assessments, penetration testing, and system updates\n"
                        "• Employee training on confidentiality, data protection, and security best practices\n"
                        "• Incident response procedures and breach notification protocols\n\n"
                        "While we strive to protect your data, no system is fully secure. Please safeguard your credentials and report suspicious activity immediately.",
                  ),

                  _buildSection(
                    icon: Icons.child_care_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    title: "5. Policy for Minors",
                    content:
                        "Our services are not intended for children under 18 years of age.\n\n"
                        "• We do not knowingly collect personal information from minors without parental consent\n"
                        "• If we discover that a minor has provided personal information, we will delete it promptly\n"
                        "• Parents and guardians have the right to review, modify, or delete their child's information\n"
                        "• We comply with applicable children's privacy laws including COPPA\n\n"
                        "Parents can contact Info@Webutsav.com to request deletion of their child's information or to report any concerns.",
                  ),

                  const SizedBox(height: 32),

                  // Contact Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.05),
                          accentColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.support_agent_rounded,
                              color: primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Need Help?",
                              style: _titleStyle().copyWith(
                                color: primaryColor,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Contact us for any questions about these terms",
                          style: _contentStyle(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildContactButton(
                              icon: Icons.email_rounded,
                              label: "Email Us",
                              color: accentColor,
                            ),
                            _buildContactButton(
                              icon: Icons.phone_rounded,
                              label: "Call Us",
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: textPrimary.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.update_rounded,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Last Updated: June 2025",
                          style: _contentStyle().copyWith(
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Effective from June 9, 2025",
                          style: _contentStyle().copyWith(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            childrenPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(title, style: _titleStyle()),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(content, style: _contentStyle()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
