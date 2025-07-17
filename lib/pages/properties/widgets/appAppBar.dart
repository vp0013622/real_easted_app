import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/pages/properties/widgets/addNewPropertyButton.dart';
import 'package:provider/provider.dart';
import 'package:inhabit_realties/controllers/favoriteProperty/favoritePropertyController.dart';

class AppAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onToggleFavorites;
  final bool showFavoritesOnly;
  
  const AppAppBar({
    super.key, 
    this.onToggleFavorites,
    this.showFavoritesOnly = false,
  });

  @override
  State<AppAppBar> createState() => _AppAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppAppBarState extends State<AppAppBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return AppBar(
      backgroundColor: cardColor,
      iconTheme: IconThemeData(color: textColor),
      actions: [
        //AnimatedSearchBar(),
        IconButton(
          onPressed: widget.onToggleFavorites,
          icon: Icon(
            widget.showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
            color: widget.showFavoritesOnly ? Colors.red : textColor,
          ),
          tooltip: 'Show Favorites Only',
        ),
        const Padding(
          padding: EdgeInsets.only(right: 20),
          child: AddNewPropertyButton(),
        ),
      ],
    );
  }
}
