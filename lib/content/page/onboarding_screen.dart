import 'package:flutter/material.dart';
import 'package:plant_care/content/page/login.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLeaving = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      lottieAsset: 'asset/plant1.json',
      title: 'Smart Watering',
      subtitle: 'Never Forget Again',
      description:
          'Set custom watering schedules and get timely reminders to keep every plant perfectly hydrated.',
      bgTop: Color(0xFF1B4332),
      bgBottom: Color(0xFF2D6A4F),
      accentColor: Color(0xFF52B788),
    ),
    _OnboardingData(
      lottieAsset: 'asset/plant2.json',
      title: 'Identify Plants',
      subtitle: 'Discover & Learn',
      description:
          'Snap a photo of any plant and our AI instantly tells you exactly what it is.',
      bgTop: Color(0xFF1A3A2A),
      bgBottom: Color(0xFF40916C),
      accentColor: Color(0xFF74C69D),
    ),
    _OnboardingData(
      lottieAsset: 'asset/plant3.json',
      title: 'Expert Tips',
      subtitle: 'Grow with Confidence',
      description:
          'Access curated plant care guides and build your green thumb with expert advice.',
      bgTop: Color(0xFF081C15),
      bgBottom: Color(0xFF52B788),
      accentColor: Color(0xFFB7E4C7),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _fadeController.reset();
    setState(() => _currentPage = index);
    _fadeController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  // ── Transition to login ───────────────────────────────────────────────────
  void _navigateToLogin() {
    // Mark as leaving so PageView stops rendering Lottie animations,
    // freeing the raster thread for the route transition.
    setState(() => _isLeaving = true);
    _fadeController.stop();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a, b) => const LoginPage(),
        transitionsBuilder: (context, a, b, child) =>
            FadeTransition(opacity: a, child: child),
        // Keep it short so the heavy LoginPage gradient doesn't compete
        // with the outgoing Lottie frame.
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [page.bgTop, page.bgBottom],
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.accentColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.35,
            left: -40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.accentColor.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (_, index) => _OnboardingPage(
              data: _pages[index],
              fadeAnim: index == _currentPage
                  ? _fadeAnim
                  : const AlwaysStoppedAnimation(1.0),
              animate: !_isLeaving,
            ),
          ),

          // Skip
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 8),
                child: TextButton(
                  onPressed: _navigateToLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),

          // Bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomPanel(
              pages: _pages,
              currentPage: _currentPage,
              onNext: _nextPage,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.fadeAnim,
    required this.animate,
  });

  final _OnboardingData data;
  final Animation<double> fadeAnim;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          FadeTransition(
            opacity: fadeAnim,
            child: SizedBox(
              width: 260,
              height: 260,
              child: Lottie.asset(
                data.lottieAsset,
                fit: BoxFit.contain,
                repeat: true,
                // Stop animating when we're transitioning away — frees the
                // raster thread so the route transition is smooth.
                animate: animate,
              ),
            ),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: fadeAnim,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: data.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: data.accentColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    data.subtitle.toUpperCase(),
                    style: TextStyle(
                      color: data.accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  data.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 16,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.pages,
    required this.currentPage,
    required this.onNext,
  });

  final List<_OnboardingData> pages;
  final int currentPage;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final page = pages[currentPage];
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == i ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage == i
                        ? const Color(0xFF2D6A4F)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentPage + 1} / ${pages.length}',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        page.title,
                        style: const TextStyle(
                          color: Color(0xFF1B4332),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onNext,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D6A4F),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2D6A4F,
                          ).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      currentPage == pages.length - 1
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.lottieAsset,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bgTop,
    required this.bgBottom,
    required this.accentColor,
  });

  final String lottieAsset;
  final String title;
  final String subtitle;
  final String description;
  final Color bgTop;
  final Color bgBottom;
  final Color accentColor;
}
