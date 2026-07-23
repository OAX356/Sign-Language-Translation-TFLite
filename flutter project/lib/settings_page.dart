import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'app_drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _translationLanguages = [
    'Arabic',
    'French',
    'Spanish',
    'German',
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppSettings.themeMode.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      drawer: const AppDrawer(currentPage: AppPage.settings),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Detection Settings'),

              _buildSliderCard(
                icon: Icons.verified_outlined,
                title: 'Confidence Threshold',
                subtitle:
                    'Default: 65%. This is the recommended value for balanced predictions.',
                value: AppSettings.confidenceThreshold.value,
                min: 0.50,
                max: 0.95,
                divisions: 9,
                displayValue:
                    '${(AppSettings.confidenceThreshold.value * 100).round()}%',
                onChanged: (value) {
                  setState(() {
                    AppSettings.confidenceThreshold.value = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              _buildSwitchCard(
                icon: Icons.format_list_numbered,
                title: 'Show Top 3 Predictions',
                subtitle:
                    'Default: On. Shows the three most likely predicted letters.',
                value: AppSettings.showTopPredictions.value,
                onChanged: (value) {
                  setState(() {
                    AppSettings.showTopPredictions.value = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              _buildSwitchCard(
                icon: Icons.camera_front_outlined,
                title: 'Use Front Camera',
                subtitle:
                    'Default: Off. The app uses the back camera unless this is enabled.',
                value: AppSettings.useFrontCamera.value,
                onChanged: (value) {
                  setState(() {
                    AppSettings.useFrontCamera.value = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              _buildSectionTitle('Translation Settings'),

              _buildDropdownCard(),

              const SizedBox(height: 20),

              _buildSectionTitle('Appearance'),

              _buildSwitchCard(
                icon: isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Default: Off. Turn on to use the dark theme.',
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    AppSettings.themeMode.value = value
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  });
                },
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: _resetSettings,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset to Default'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
        secondary: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.55),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.55),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            displayValue,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.70),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: displayValue,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard() {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.55),
              child: Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Translation Language',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Default: Arabic. Choose the target language for translation.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: AppSettings.translationLanguage.value,
              underline: const SizedBox.shrink(),
              items: _translationLanguages.map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  AppSettings.translationLanguage.value = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      AppSettings.resetToDefault();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings reset to default.')));
  }
}
