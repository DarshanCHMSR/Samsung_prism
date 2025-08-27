import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/enhanced_login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/transfer/transfer_screen.dart';
import 'screens/scan/scan_pay_screen.dart';
import 'screens/transactions/transaction_history_screen.dart';
import 'screens/location/location_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/keystroke/keystroke_setup_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/balance_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/location_provider.dart';
import 'providers/keystroke_auth_provider.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SamsungPrismBankingApp());
}

class SamsungPrismBankingApp extends StatelessWidget {
  const SamsungPrismBankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => KeystrokeAuthProvider()),
      ],
      child: MaterialApp(
        title: 'Samsung Prism Banking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primaryBlue,
          scaffoldBackgroundColor: AppColors.backgroundGrey,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/enhanced-login': (context) => const EnhancedLoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
          '/transfer': (context) => const TransferScreen(),
          '/scan-pay': (context) => const ScanPayScreen(),
          '/transactions': (context) => const TransactionHistoryScreen(),
          '/location': (context) => const LocationScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/keystroke-setup': (context) => const KeystrokeSetupScreen(),
        },
      ),
    );
  }
}
