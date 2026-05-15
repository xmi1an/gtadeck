import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../services/onboarding_service.dart';
import 'connection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    final onboardingService = OnboardingService();
    await onboardingService.setOnboardingComplete();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ConnectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildPage1(),
                  _buildPage2Windows(),
                  _buildPage3Server(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videogame_asset,
            size: 100,
            color: AppColors.gtaGreen,
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to GTADeck',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.gtaGreen,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Control GTA V from your phone with custom shortcuts and macros',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.gtaGreen.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                _buildRequirement(Icons.computer, 'PC with GTA V'),
                const SizedBox(height: 12),
                _buildRequirement(Icons.wifi, 'Same WiFi Network'),
                const SizedBox(height: 12),
                _buildRequirement(Icons.code, 'Desktop Companion App'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2Windows() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Icon(
              Icons.laptop_windows,
              size: 80,
              color: AppColors.gtaGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Step 1: Find Your PC\'s IP Address',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.gtaGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildInstructionCard(
            '1',
            'Open Command Prompt',
            'Press Win + R, type "cmd" and press Enter',
            Icons.keyboard,
          ),
          const SizedBox(height: 16),
          _buildInstructionCard(
            '2',
            'Run ipconfig command',
            'Type "ipconfig" and press Enter',
            Icons.terminal,
          ),
          const SizedBox(height: 16),
          _buildInstructionCard(
            '3',
            'Find IPv4 Address',
            'Look for "IPv4 Address" under your WiFi adapter\nIt looks like: 192.168.1.100',
            Icons.search,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.gtaGreen.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.warningYellow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Tip',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.warningYellow,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your IP usually starts with:\n• 192.168.x.x (most common)\n• 10.0.x.x\n• 172.16.x.x',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3Server() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Icon(
              Icons.dns,
              size: 80,
              color: AppColors.gtaGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Step 2: Start Desktop Server',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.gtaGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildInstructionCard(
            '1',
            'Download Desktop Companion',
            'Get the server app from the GTADeck repository',
            Icons.download,
          ),
          const SizedBox(height: 16),
          _buildInstructionCard(
            '2',
            'Install Dependencies',
            'Run: pip install websockets pynput pygetwindow',
            Icons.install_desktop,
          ),
          const SizedBox(height: 16),
          _buildInstructionCard(
            '3',
            'Start the Server',
            'Run: python server.py\nServer will start on port 8080',
            Icons.play_arrow,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.dangerRed.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: AppColors.dangerRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Important',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.dangerRed,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Make sure GTA V is running\n• Both devices must be on the same WiFi\n• Disable firewall for port 8080 if needed',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.gtaGreen.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to Connect?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.gtaGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your PC\'s IP address in the format:\n192.168.1.100',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gtaGreen, size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildInstructionCard(
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gtaGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gtaGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.darkBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.gtaGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.gtaGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.gtaGreen
                      : AppColors.gtaGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.gtaGreen),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('BACK'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                flex: _currentPage == 0 ? 1 : 2,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gtaGreen,
                    foregroundColor: AppColors.darkBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _currentPage == 2 ? 'GET STARTED' : 'NEXT',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_currentPage == 0) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _finish,
              child: Text(
                'Skip Tutorial',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
