import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/pages/widgets/appSpinner.dart';

class PageContainer extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final bool isLoading;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? drawer;
  final bool useSafeArea;
  final ScrollPhysics? physics;
  final EdgeInsets? contentPadding;
  final bool showAppBar;

  const PageContainer({
    super.key,
    this.title,
    required this.children,
    this.isLoading = false,
    this.floatingActionButton,
    this.actions,
    this.centerTitle = false,
    this.drawer,
    this.useSafeArea = true,
    this.physics = const BouncingScrollPhysics(),
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 20,
    ),
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;

    Widget content =
        isLoading
            ? const Center(child: AppSpinner())
            : ListView(
              physics: physics,
              padding: contentPadding,
              children: children,
            );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar:
          showAppBar
              ? AppBar(
                title: title != null ? Text(title!) : null,
                backgroundColor: cardColor,
                elevation: 0,
                centerTitle: centerTitle,
                actions: actions,
              )
              : null,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          content,
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: AppSpinner()),
            ),
        ],
      ),
    );
  }
}
