import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Frequently Asked Questions',
              [
                _buildFAQItem(
                  'How do I create a new label?',
                  'To create a new label, tap the camera icon button on the home screen and capture a photo of food packet back-label, photo should have both ingredients and nutrients.',
                ),
                _buildFAQItem(
                  'How can I edit an existing label?',
                  'No, you cannot edit an existing label. But you can report incorrect information. At the bottom of the product details page, there is a report button.',
                ),
                _buildFAQItem(
                  'My data! if I have logged as anonymously?',
                  'If you logout from the app, your data will be deleted.',
                ),
                _buildFAQItem(
                  'What is NOVA Classification?',
                  'NOVA is a food classification system that categorizes foods according to their level of processing. It helps you understand how processed your food is, from unprocessed (NOVA 1) to ultra-processed (NOVA 4). Tap to learn more.',
                  onTap: () => _launchUrl(
                      'https://en.wikipedia.org/wiki/Nova_classification'),
                ),
                _buildFAQItem(
                  'What is Nutri-Score?',
                  'Nutri-Score is a nutrition label that converts the nutritional value of products into a simple code consisting of 5 letters, from A to E. "A" (green) indicates better nutritional quality while "E" (red) indicates lower nutritional quality. Tap to learn more.',
                  onTap: () =>
                      _launchUrl('https://en.wikipedia.org/wiki/Nutri-Score'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Contact Us',
              [
                _buildContactItem(
                  Icons.email,
                  'Email Support',
                  AppConfig.supportEmailDisplay,
                  () => _launchEmail(AppConfig.supportEmail),
                ),
                _buildContactItem(
                  Icons.web,
                  'Visit Website',
                  'https://experimenter.ai/',
                  () => _launchUrl('https://experimenter.ai/'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer, {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(answer),
                if (onTap != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onTap,
                      child: const Text('Learn more'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  Widget _buildResourceLink(
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
