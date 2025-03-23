import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/invoices_screen.dart';
import '../screens/customers_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/items_screen.dart';
import '../screens/expenses_screen.dart';
import '../screens/basic_invoice_form.dart';
import '../screens/customer_form_screen.dart';
import '../screens/customer_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';
import '../screens/indian_gst_settings_screen.dart';
import '../screens/language_settings_screen.dart';
import '../screens/upi_settings_screen.dart';
import '../screens/gst_return_filing_screen.dart'; // Import GST Return Filing screen

class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/';
  static const String invoices = '/invoices';
  static const String customers = '/customers';
  static const String reports = '/reports';
  static const String items = '/items';
  static const String expenses = '/expenses';
  static const String settings = '/settings';
  static const String indianGstSettings = '/indian_gst_settings';
  static const String languageSettings = '/language_settings';
  static const String upiSettings = '/upi_settings';
  static const String gstReturnFiling = '/gst_return_filing'; // Add GST Return Filing route
  static const String createInvoice = '/invoices/create';
  static const String editInvoice = '/invoices/edit';
  static const String createCustomer = '/customers/create';
  static const String editCustomer = '/customers/edit';
  static const String customerDetail = '/customers/detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments if available
    final args = settings.arguments;

    switch (settings.name) {
      case login:
        return _createRoute(const LoginScreen());
      case dashboard:
        return _createRoute(const DashboardScreen());
      case invoices:
        return _createRoute(const InvoicesScreen());
      case customers:
        return _createRoute(const CustomersScreen());
      case reports:
        return _createRoute(const ReportsScreen());
      case items:
        return _createRoute(const ItemsScreen());
      case expenses:
        return _createRoute(const ExpensesScreen());
      case settings:
        return _createRoute(const SettingsScreen());
      case indianGstSettings:
        return _createRoute(const IndianGSTSettingsScreen());
      case languageSettings:
        return _createRoute(const LanguageSettingsScreen());
      case upiSettings:
        return _createRoute(const UpiSettingsScreen());
      case gstReturnFiling: // Add GST Return Filing case
        return _createRoute(const GstReturnFilingScreen());
      case createInvoice:
        return _createRoute(const BasicInvoiceForm());
      case editInvoice:
        // For future implementation
        return _createRoute(const BasicInvoiceForm());
      case createCustomer:
        return _createRoute(const CustomerFormScreen(isEditing: false));
      case editCustomer:
        // Get customer ID from arguments
        final customerId = args as String?;
        return _createRoute(CustomerFormScreen(isEditing: true, customerId: customerId));
      case customerDetail:
        // Get customer ID from arguments
        final customerId = args as String?;
        return _createRoute(CustomerDetailScreen(customerId: customerId ?? ''));
      default:
        return _createRoute(const DashboardScreen());
    }
  }

  // Custom page transition
  static Route<dynamic> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
