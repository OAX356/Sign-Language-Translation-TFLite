import 'package:flutter/material.dart';
import 'app_drawer.dart';

class AslGuidePage extends StatelessWidget {
  const AslGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ASL Guide'), centerTitle: true),
      drawer: const AppDrawer(currentPage: AppPage.guide),
      body: SafeArea(
        child: Column(
          children: [
            // Page title and short instruction
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  const Text(
                    'American Sign Language Letters',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                   Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: Colors.orange.shade700,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Use two fingers to zoom in or out. Drag to move around the guide.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                ],
              ),
            ),

            // Zoomable image area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: InteractiveViewer(
                    minScale: 1.2,
                    maxScale: 5.0,
                    boundaryMargin: const EdgeInsets.all(80),
                    child: Center(
                      child: Image.asset(
                        'assets/images/final ASL.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
