import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final listOfOBDetails = [
      {
        "image": isDark? 'assets/images/dark_dashboard.png' : 'assets/images/light_dashboard.png',
        "title": 'Stunning dashboard',
        "description": 'Easy to track details regarding to the leads, employee performance, and progress.',
      },
      {
        "image": isDark? 'assets/images/dark_status_updated.png' : 'assets/images/light_status_updated.png',
        "title": 'Update status',
        "description": 'Efficiently manage current status of the leads',
      },
      {
        "image": isDark? 'assets/images/dark_task.png' : 'assets/images/light_task.png',
        "title": 'Task management',
        "description": 'Simplest way to manage tasks',
      },
      {
        "image": isDark? 'assets/images/dark_visit.png' : 'assets/images/light_visit.png',
        "title": 'Visit schedules',
        "description": 'Easy way to create schedules and planning',
      }
    ];
    return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          body: SafeArea(
            child: Column(
              children: [
                Flexible(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: listOfOBDetails.length,
                      onPageChanged: (index) {
                        setState(() {
                          _pageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) => OnBoardContent(
                        isDark: isDark,
                        textTheme: textTheme,
                        image: listOfOBDetails[index]['image']!,
                        title: listOfOBDetails[index]['title']!,
                        description: listOfOBDetails[index]['description']!,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      ...List.generate(
                        listOfOBDetails.length,
                        (index) => Padding(
                          padding: const EdgeInsets.all(4),
                          child: DotIndicator(
                            isDark: isDark,
                            isActive: index == _pageIndex,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(35),
                        shadowColor: isDark ? AppColors.lightPrimary : AppColors.darkPrimary,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: InkWell(
                            onTap: () async {
                              if (_pageIndex < listOfOBDetails.length - 1) {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              } else {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool('onboarding_seen', true);
                                Navigator.pushReplacementNamed(context, '/home');
                              }
                            },
                            child: const Icon(
                              CupertinoIcons.arrow_right,
                              color: AppColors.darkWhiteText,
                            ),
                          ),
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
}

class DotIndicator extends StatelessWidget {
  final bool isDark;
  final bool isActive;

  const DotIndicator({
    super.key,
    required this.isDark,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isActive ? 10 : 5,
      width: isActive ? 10 : 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isActive ? 5 : 2.5),
        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
      ),
    );
  }
}

class OnBoardContent extends StatelessWidget {
  final bool isDark;
  final TextTheme textTheme;
  final String image;
  final String title;
  final String description;

  const OnBoardContent({
      super.key,
      required this.isDark,
      required this.textTheme,
      required this.image,
      required this.title,
      required this.description
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Image.asset(
            image,
            height: 250,
          ),
        ),
        Flexible(
          child: Text(
            title,
            style: textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: Text(
            description,
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
