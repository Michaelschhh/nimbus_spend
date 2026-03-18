import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  final VoidCallback onAccept;
  const TermsOfServiceScreen({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text("Terms of Service",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
            const SizedBox(height: 8),
            const Text("Please review before continuing",
              style: TextStyle(color: AppColors.textDim, fontSize: 14),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("1. Acceptance of Terms"),
                            _body("By downloading, installing, or using Nimbus Spend (\"the App\"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App."),
                            
                            _sectionTitle("2. Description of Service"),
                            _body("Nimbus Spend is a personal finance tracking application designed to help you monitor expenses, manage budgets, savings, bills, debts, subscriptions, and financial goals. The App provides tools for financial visibility and does not constitute financial advice."),
                            
                            _sectionTitle("3. User Accounts & Data"),
                            _body("All data you enter into Nimbus Spend is stored locally on your device. We do not collect, transmit, or store your personal financial data on external servers. You are solely responsible for backing up your device data. We are not liable for any data loss resulting from device failure, app uninstallation, or any other cause."),
                            
                            _sectionTitle("4. Privacy Policy"),
                            _body("We respect your privacy. Nimbus Spend:\n\n• Stores all financial data locally on your device\n• Does not share personal data with third parties\n• Uses Google AdMob to display advertisements, which may collect anonymous usage data per Google's privacy policy\n• May use anonymous analytics to improve app performance"),
                            
                            _sectionTitle("5. Advertising"),
                            _body("The App displays advertisements through Google AdMob. Ad content is provided by third-party ad networks and is not controlled by Nimbus Spend. You may remove ads through an in-app purchase. Ad removal is a one-time, non-consumable purchase tied to your Google Play account."),
                            
                            _sectionTitle("6. In-App Purchases"),
                            _body("Nimbus Spend offers optional in-app purchases (e.g., ad removal). All purchases are processed through the Google Play Store and are subject to Google's terms. Refund requests must be directed to Google Play support. Purchases are non-transferable between platforms."),
                            
                            _sectionTitle("7. Financial Disclaimer"),
                            _body("Nimbus Spend is a tracking and budgeting tool only. It does not provide investment advice, tax guidance, or professional financial consultation. The \"AI Insight\" feature offers spending awareness suggestions based on simple calculations and should not be considered financial advice. Always consult a qualified financial professional for important financial decisions."),
                            
                            _sectionTitle("8. Intellectual Property"),
                            _body("All content, design, code, graphics, and other intellectual property within Nimbus Spend are owned by the developer and protected by applicable copyright laws. You may not reproduce, modify, distribute, or create derivative works from any part of the App without prior written consent."),
                            
                            _sectionTitle("9. Limitation of Liability"),
                            _body("Nimbus Spend is provided \"as is\" without warranties of any kind. To the maximum extent permitted by law, the developer shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses resulting from your use of the App."),
                            
                            _sectionTitle("10. Changes to Terms"),
                            _body("We reserve the right to modify these terms at any time. Continued use of the App after changes constitutes acceptance of the updated terms. We will make reasonable efforts to notify users of significant changes through app updates."),
                            
                            _sectionTitle("11. Termination"),
                            _body("You may stop using the App at any time by uninstalling it. We reserve the right to suspend or terminate access to the App for violations of these terms."),
                            
                            _sectionTitle("12. Governing Law"),
                            _body("These terms shall be governed by and construed in accordance with applicable local laws. Any disputes arising from these terms or the use of the App shall be resolved through appropriate legal channels."),
                            
                            _sectionTitle("13. Contact"),
                            _body("For questions about these Terms of Service, please contact us through the app's support channels or the developer's page on the Google Play Store."),
                            
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                              ),
                              child: const Text(
                                "Last updated: March 2026\nVersion 1.0",
                                style: TextStyle(color: AppColors.textDim, fontSize: 12, height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: GestureDetector(
                onTap: onAccept,
                child: Container(
                  height: 65,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text("I Accept",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text,
        style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _body(String text) {
    return Text(text,
      style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.6),
    );
  }
}
