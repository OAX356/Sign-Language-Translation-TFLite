import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), centerTitle: true),
      drawer: const AppDrawer(currentPage: AppPage.about),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(context),

              const SizedBox(height: 18),

              _buildInfoCard(
                context: context,
                icon: Icons.info_outline,
                title: 'Project Overview',
                text:
                    'This application is designed to help recognize American Sign Language letters using a mobile camera. The app detects hand signs, predicts the corresponding letter, builds text from selected letters, speaks the text aloud, and can translate the final sentence.',
              ),

              const SizedBox(height: 14),

              _buildInfoCard(
                context: context,
                icon: Icons.camera_alt_outlined,
                title: 'How It Works',
                text:
                    'The user shows one hand clearly to the camera. The application detects hand landmarks, sends them to a trained machine learning model, and displays the predicted ASL letter with a confidence value.',
              ),

              const SizedBox(height: 14),

              _buildInfoCard(
                context: context,
                icon: Icons.psychology_alt_outlined,
                title: 'Artificial Intelligence',
                text:
                    'The prediction system uses a TensorFlow Lite model trained to classify ASL hand signs. The model works on-device, which allows the app to perform recognition directly on the phone.',
              ),

              const SizedBox(height: 14),

              _buildInfoCard(
                context: context,
                icon: Icons.front_hand_outlined,
                title: 'MediaPipe Hand Landmarks',
                text:
                    'MediaPipe is used to detect important hand landmark points. These landmarks help the model focus on hand structure instead of the full camera background.',
              ),

              const SizedBox(height: 14),

              _buildInfoCard(
                context: context,
                icon: Icons.record_voice_over_outlined,
                title: 'Text and Speech',
                text:
                    'After detecting letters, the user can add them to a text box. The application supports special signs such as Space and Delete. The completed text can also be converted into speech.',
              ),

              const SizedBox(height: 14),

              _buildInfoCard(
                context: context,
                icon: Icons.translate,
                title: 'Translation',
                text:
                    'The app includes a translation feature that can translate the completed text. Some translation models may require an internet connection the first time they are downloaded.',
              ),

              const SizedBox(height: 14),

              _buildInfoCard(
                context: context,
                icon: Icons.school_outlined,
                title: 'Purpose',
                text:
                    'This project was developed as a graduation project to demonstrate the use of computer vision, machine learning, Flutter, and mobile application development in an assistive technology context.',
              ),

              const SizedBox(height: 20),

              _buildTeamCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.50),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sign_language,
            size: 72,
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.65),
          ),
          const SizedBox(height: 14),
          const Text(
            'ASL Translator',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'A mobile application for recognizing American Sign Language letters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String text,
    required BuildContext context,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.45),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.groups_outlined, color: Colors.indigo),
                SizedBox(width: 10),
                Text(
                  'Project Team',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.02),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.60),
                ),
              ),
              child: const Text(
                'Team Members:\n'
                '- Omar Adnan Ahmed\n'
                '- Abdullah Moatazbellah Samir\n'
                '- Omar Abdulaziz Alsaadi\n\n'
                'Supervisor:\n'
                '- Dr. Riadh Bin Mohammad Ksantini',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
