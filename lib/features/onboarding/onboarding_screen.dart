import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data class for each onboarding page.
class _PageData {
  const _PageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientBegin,
    required this.gradientEnd,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color gradientBegin;
  final Color gradientEnd;
}

/// Category item for the interests page.
class _CategoryItem {
  const _CategoryItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Premium onboarding experience — Pixel/iOS inspired.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Set<int> _selectedCategories = {};

  static const _pages = <_PageData>[
    _PageData(
      icon: Icons.shield_outlined,
      title: 'Protect Yourself',
      subtitle:
          'Instantly detect manipulation, hidden fees,\nand red flags in any text.',
      gradientBegin: Color(0xFF0D9488),
      gradientEnd: Color(0xFF115E59),
    ),
    _PageData(
      icon: Icons.search_rounded,
      title: 'Decode Anything',
      subtitle:
          'Contracts, messages, medical bills —\ntranslated to plain English.',
      gradientBegin: Color(0xFF0F766E),
      gradientEnd: Color(0xFF134E4A),
    ),
    _PageData(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Respond Confidently',
      subtitle:
          'Get AI-crafted responses and take\ncontrol of every conversation.',
      gradientBegin: Color(0xFF115E59),
      gradientEnd: Color(0xFF0C4A42),
    ),
  ];

  static const _categories = <_CategoryItem>[
    _CategoryItem(icon: Icons.work_outline_rounded, label: 'Work'),
    _CategoryItem(icon: Icons.local_hospital_outlined, label: 'Medical'),
    _CategoryItem(icon: Icons.gavel_rounded, label: 'Legal'),
    _CategoryItem(icon: Icons.chat_outlined, label: 'Messages'),
    _CategoryItem(icon: Icons.email_outlined, label: 'Email'),
    _CategoryItem(icon: Icons.account_balance_outlined, label: 'Finance'),
    _CategoryItem(icon: Icons.home_outlined, label: 'Housing'),
    _CategoryItem(icon: Icons.people_outline_rounded, label: 'Relationships'),
    _CategoryItem(icon: Icons.phone_android_rounded, label: 'Social Media'),
  ];

  int get _totalPages => _pages.length + 1; // 3 info + 1 categories

  bool get _isLastPage => _currentPage == _totalPages - 1;

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      context.go('/home');
    }
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _toggleCategory(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedCategories.contains(index)) {
        _selectedCategories.remove(index);
      } else {
        _selectedCategories.add(index);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Transparent status bar with white icons
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _currentPage < _pages.length
                    ? [
                        _pages[_currentPage].gradientBegin,
                        _pages[_currentPage].gradientEnd,
                      ]
                    : [const Color(0xFF0D9488), const Color(0xFF0C4A42)],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar: Skip
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withAlpha(179),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _totalPages,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    onPageChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      if (index < _pages.length) {
                        return _buildInfoPage(_pages[index]);
                      }
                      return _buildCategoriesPage();
                    },
                  ),
                ),

                // Dot indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withAlpha(77),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Continue / Get Started button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0D9488),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _isLastPage ? 'Get Started' : 'Continue',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPage(_PageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glass circle with icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(31),
              border: Border.all(
                color: Colors.white.withAlpha(51),
                width: 1.5,
              ),
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitle,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withAlpha(179),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose what matters\nto you',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'We will personalize your experience',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // 3x3 grid of categories
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategories.contains(index);

              return GestureDetector(
                onTap: () => _toggleCategory(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withAlpha(46)
                        : Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withAlpha(128)
                          : Colors.white.withAlpha(31),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: 32,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.label,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // Checkmark
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
