import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/theme.dart';
import 'package:inhabit_realties/pages/auth/login_page.dart';
import 'package:inhabit_realties/pages/auth/logout_page.dart';
import 'package:inhabit_realties/pages/auth/register_page.dart';
import 'package:inhabit_realties/pages/auth/change_password_page.dart';
import 'package:inhabit_realties/pages/error/noInternet.dart';
import 'package:inhabit_realties/pages/error/serverError.dart';
import 'package:inhabit_realties/pages/main_layout.dart';
import 'package:inhabit_realties/pages/onboarding_page.dart';
import 'package:inhabit_realties/pages/profile/profile_page.dart';
import 'package:inhabit_realties/pages/properties/addProperty_page.dart';
import 'package:inhabit_realties/pages/properties/properties_page.dart';
import 'package:inhabit_realties/pages/splash_page.dart';
import 'package:inhabit_realties/pages/users/editUser_page.dart';
import 'package:inhabit_realties/pages/users/users_page.dart';
import 'package:inhabit_realties/pages/documents/user_documents_page.dart';
import 'package:inhabit_realties/pages/documents/all_documents_page.dart';
import 'package:inhabit_realties/pages/documents/user_documents_detail_page.dart';
import 'package:inhabit_realties/pages/leads/assigned_leads_page.dart';
import 'package:inhabit_realties/pages/reports/reports_page.dart';
import 'package:inhabit_realties/pages/settings/settings_page.dart';
import 'package:inhabit_realties/pages/profile/activity_details_page.dart';
import 'package:inhabit_realties/pages/properties/favorite_properties_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:inhabit_realties/controllers/favoriteProperty/favoritePropertyController.dart';
import 'package:inhabit_realties/providers/theme_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritePropertyController()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Initialize theme when the app starts
          WidgetsBinding.instance.addPostFrameCallback((_) {
            themeProvider.initializeTheme();
          });

          return MaterialApp(
            title: "Inhabit Realties",
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.currentTheme == 'dark'
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashPage(),
              '/error/noInternet': (context) => const NoInternet(),
              '/error/serverError': (context) => const ServerError(),
              '/onboarding': (context) => const OnboardingPage(),
              '/home': (context) => MainLayout(
                    onToggleTheme: () {
                      final newTheme = themeProvider.currentTheme == 'dark'
                          ? 'light'
                          : 'dark';
                      themeProvider.updateTheme(newTheme);
                    },
                  ),
              '/users': (context) => const UsersPage(),
              '/users/edit': (context) => const EditUserPage(),
              '/auth/login': (context) => const LoginPage(),
              '/auth/logout': (context) => const LogoutPage(),
              '/auth/register': (context) => const RegisterPage(),
              '/auth/change_password': (context) => const ChangePasswordPage(),
              '/profile': (context) => const ProfilePage(),
              '/properties': (context) => const PropertiesPage(),
              '/addNewProperty': (context) => const AddPropertyPage(),
              '/documents': (context) => const UserDocumentsPage(),
              '/documents/all': (context) => const AllDocumentsPage(),
              '/leads/assigned': (context) => const AssignedLeadsPage(),
              '/reports': (context) => const ReportsPage(),
              '/settings': (context) => const SettingsPage(),
              '/favorite_properties': (context) =>
                  const FavoritePropertiesPage(),
              '/activity_details': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                return ActivityDetailsPage(
                  title: args['title'],
                  count: args['count'],
                );
              },
            },
          );
        },
      ),
    );
  }
}
