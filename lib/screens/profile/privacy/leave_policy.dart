import 'package:flutter/material.dart';
import 'package:managify_hr/theme/colors.dart';

class LeavePolicyScreen extends StatelessWidget {
  const LeavePolicyScreen({Key? key}) : super(key: key);

  // Text styles
  TextStyle _titleStyle() => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColor.textPrimary,
    letterSpacing: -0.2,
  );

  TextStyle _contentStyle() => const TextStyle(
    fontSize: 15,
    color: AppColor.textSecondary,
    height: 1.7,
    letterSpacing: 0.1,
  );

  TextStyle _headerStyle() => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColor.textPrimary,
    letterSpacing: -0.5,
  );

  TextStyle _subHeaderStyle() => const TextStyle(
    fontSize: 16,
    color: AppColor.textSecondary,
    height: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 40,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColor.indigo,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Padding(
                padding: const EdgeInsets.only(left: 50),
                child: const Text(
                  'Leave Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColor.white,
                  ),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColor.indigo, AppColor.primaryLight],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 120,
                      left: -30,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
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
                      color: AppColor.white,
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
                                color: AppColor.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.policy_rounded,
                                color: AppColor.accentColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Employee Leave Policy',
                                style: _headerStyle(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Comprehensive guidelines for leave management to ensure transparency and effective workforce management.',
                          style: _subHeaderStyle(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Policy Sections
                  _buildSection(
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    title: "1. Purpose",
                    content:
                    "This policy outlines the types, eligibility, application process, and approval workflow for employee leave to ensure transparency and effective workforce management. It serves as a comprehensive guide for both employees and managers to understand the leave management system.",
                  ),

                  _buildSection(
                    icon: Icons.assignment_outlined,
                    iconColor: const Color(0xFF2196F3),
                    title: "2. Leave Application Guidelines",
                    content:
                    "Application Timeline:\n"
                        "• Casual Leave (CL) / Earned Leave (EL): Apply at least 2 days in advance\n"
                        "• Sick Leave (SL): Apply immediately or on the same day for emergencies\n\n"
                        "Required Documentation:\n"
                        "• Medical certificate for Sick Leave exceeding 3 days\n"
                        "• Birth certificate and medical documents for Maternity/Paternity Leave\n"
                        "• Supporting documents as required by company policy\n\n"
                        "Approval Process:\n"
                        "• All leave applications must be submitted through the HRM system\n"
                        "• Manager or Reporting Officer approval is mandatory\n"
                        "• Applications without proper documentation may be rejected",
                  ),

                  _buildSection(
                    icon: Icons.verified_outlined,
                    iconColor: const Color(0xFF9C27B0),
                    title: "3. Leave Approval Workflow",
                    content:
                    "Step 1: Application Submission\n"
                        "• Employee submits leave request through HRM system\n"
                        "• All required fields and documents must be provided\n\n"
                        "Step 2: Manager Review\n"
                        "• Reporting Manager reviews the application\n"
                        "• Manager approves or rejects based on business requirements\n"
                        "• Feedback provided for rejected applications\n\n"
                        "Step 3: HR Processing\n"
                        "• HR Department receives notification of approval\n"
                        "• Leave balance is updated in the system\n"
                        "• Employee receives confirmation notification",
                  ),

                  _buildSection(
                    icon: Icons.rule_outlined,
                    iconColor: const Color(0xFFFF5722),
                    title: "4. Rules and Conditions",
                    content:
                    "Leave Balance Management:\n"
                        "• Unused Earned Leave can be carried forward to the next year\n"
                        "• Annual encashment of unused EL is available as per company policy\n\n"
                        "Attendance Policies:\n"
                        "• Absence without prior approval will be marked as Loss of Pay (LOP)\n"
                        "• Half-day leaves are permitted only for Casual and Sick Leave\n"
                        "• Minimum half-day duration applies to all leave types\n\n"
                        "Disciplinary Actions:\n"
                        "• Repeated unapproved absences may lead to disciplinary action\n"
                        "• Falsification of leave documents is subject to serious consequences\n"
                        "• Managers reserve the right to verify leave documentation",
                  ),

                  _buildSection(
                    icon: Icons.calendar_today_outlined,
                    iconColor: const Color(0xFF607D8B),
                    title: "5. Leave Types and Entitlements",
                    content:
                    "Casual Leave (CL):\n"
                        "• 12 days per year for general purposes\n"
                        "• Cannot be carried forward to next year\n"
                        "• Advance application required (2 days minimum)\n\n"
                        "Sick Leave (SL):\n"
                        "• 12 days per year for medical purposes\n"
                        "• Medical certificate required for extended periods\n"
                        "• Emergency applications accepted\n\n"
                        "Earned Leave (EL):\n"
                        "• 21 days per year, can be carried forward\n"
                        "• Encashment available at year-end\n"
                        "• Planning and advance approval recommended\n\n"
                        "Special Leave:\n"
                        "• Maternity Leave: 26 weeks (as per law)\n"
                        "• Paternity Leave: 15 days\n"
                        "• Bereavement Leave: 5 days",
                  ),

                  const SizedBox(height: 32),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.indigo.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColor.indigo.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.support_agent_rounded,
                          color: AppColor.indigo,
                          size: 24,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Need Help?",
                          style: _contentStyle().copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColor.indigo,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "For any queries regarding leave policy, please contact HR Department",
                          textAlign: TextAlign.center,
                          style: _contentStyle().copyWith(
                            fontSize: 14,
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
        color: AppColor.white,
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
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          title: Text(title, style: _titleStyle()),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content,
                style: _contentStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}