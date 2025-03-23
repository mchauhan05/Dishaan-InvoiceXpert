import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/branding_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/eway_bill_provider.dart';
import 'providers/gst_return_filing_provider.dart'; // Add GST Return Filing provider import
import 'providers/gst_return_provider.dart';
import 'providers/indian_gst_provider.dart';
import 'providers/indian_payment_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/language_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tax_provider.dart';
import 'providers/upi_payment_provider.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const DishaanInvoiceXpert());
}

class DishaanInvoiceXpert extends StatelessWidget {
  const DishaanInvoiceXpert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TaxProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => BrandingProvider()),
        ChangeNotifierProvider(create: (_) => IndianGSTProvider()),

        // Add our new Indian feature providers
        ChangeNotifierProvider(create: (_) => IndianPaymentProvider()),
        ChangeNotifierProvider(create: (_) => EwayBillProvider()),
        ChangeNotifierProvider(create: (_) => GstReturnProvider()),

        // Add the language provider
        ChangeNotifierProvider(create: (_) => LanguageProvider()..initialize()),

        // Add the UPI payment provider
        ChangeNotifierProvider(create: (_) => UpiPaymentProvider()),

        // Add the GST return filing provider
        ChangeNotifierProvider(
            create: (_) => GstReturnFilingProvider()..initialize()),
      ],
      child: Consumer2<BrandingProvider, LanguageProvider>(
        builder: (context, brandingProvider, languageProvider, child) {
          final brandingSettings = brandingProvider.brandingSettings;
          final brandColors = brandingSettings.colors;

          return MaterialApp(
            title: 'Dishaan Invoice Xpert',
            debugShowCheckedModeBanner: false,
            locale: Locale(languageProvider.currentLanguage.code),
            theme: ThemeData(
              primaryColor: Color(int.parse(
                  brandColors.primary.value.toRadixString(16),
                  radix: 16)),
              scaffoldBackgroundColor: Color(int.parse(
                  brandColors.background.value.toRadixString(16),
                  radix: 16)),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: Color(int.parse(
                    brandColors.primary.value.toRadixString(16),
                    radix: 16)),
                secondary: Color(int.parse(
                    brandColors.secondary.value.toRadixString(16),
                    radix: 16)),
                background: Color(int.parse(
                    brandColors.background.value.toRadixString(16),
                    radix: 16)),
              ),
              textTheme: GoogleFonts.getTextTheme(
                brandingSettings.fontConfig.fontFamily,
                Theme.of(context).textTheme.apply(
                      bodyColor: Color(int.parse(
                          brandColors.text.value.toRadixString(16),
                          radix: 16)),
                      displayColor: Color(int.parse(
                          brandColors.text.value.toRadixString(16),
                          radix: 16)),
                    ),
              ),

              appBarTheme: AppBarTheme(
                backgroundColor: Color(int.parse(
                    brandColors.primary.value.toRadixString(16),
                    radix: 16)),
                foregroundColor: Colors.white,
              ),
              // Add tab theme
              tabBarTheme: TabBarTheme(
                labelColor: Color(int.parse(
                    brandColors.primary.value.toRadixString(16),
                    radix: 16)),
                unselectedLabelColor: AppColors.textGray,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(int.parse(
                          brandColors.primary.value.toRadixString(16),
                          radix: 16)),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              // Add button theme
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(int.parse(
                      brandColors.primary.value.toRadixString(16),
                      radix: 16)),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Add input decoration theme
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.borderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                      color: Color(int.parse(
                          brandColors.primary.value.toRadixString(16),
                          radix: 16))),
                ),
                hintStyle: TextStyle(color: AppColors.textGray),
              ),
            ),
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.dashboard,
          );
        },
      ),
    );
  }
}
