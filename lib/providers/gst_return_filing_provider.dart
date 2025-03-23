import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/gst_return_filing_model.dart';
import '../models/invoice_models.dart';
import '../models/indian_invoice_model.dart';

/// Provider to manage GST return filing functionality
class GstReturnFilingProvider extends ChangeNotifier {
  // State variables
  List<GSTR1Return> _gstr1Returns = [];
  List<GSTR3BReturn> _gstr3bReturns = [];
  GSTReturnCalendar? _returnCalendar;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<GSTR1Return> get gstr1Returns => _gstr1Returns;
  List<GSTR3BReturn> get gstr3bReturns => _gstr3bReturns;
  GSTReturnCalendar? get returnCalendar => _returnCalendar;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadGSTReturns();
      await _generateReturnCalendar();
    } catch (e) {
      _errorMessage = 'Error initializing GST return filing: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load GST returns from shared preferences
  Future<void> _loadGSTReturns() async {
    final prefs = await SharedPreferences.getInstance();

    // Load GSTR-1 returns
    final gstr1Json = prefs.getString('gstr1_returns');
    if (gstr1Json != null) {
      final List<dynamic> decodedList = jsonDecode(gstr1Json);
      _gstr1Returns = decodedList.map((json) => GSTR1Return.fromJson(json)).toList();
    } else {
      // Initialize with sample data if no saved data
      _gstr1Returns = _generateSampleGSTR1Returns();
    }

    // Load GSTR-3B returns
    final gstr3bJson = prefs.getString('gstr3b_returns');
    if (gstr3bJson != null) {
      final List<dynamic> decodedList = jsonDecode(gstr3bJson);
      _gstr3bReturns = decodedList.map((json) => GSTR3BReturn.fromJson(json)).toList();
    } else {
      // Initialize with sample data if no saved data
      _gstr3bReturns = _generateSampleGSTR3BReturns();
    }
  }

  // Save GST returns to shared preferences
  Future<void> _saveGSTReturns() async {
    final prefs = await SharedPreferences.getInstance();

    // Save GSTR-1 returns
    final gstr1Json = jsonEncode(_gstr1Returns.map((r) => r.toJson()).toList());
    await prefs.setString('gstr1_returns', gstr1Json);

    // Save GSTR-3B returns
    final gstr3bJson = jsonEncode(_gstr3bReturns.map((r) => r.toJson()).toList());
    await prefs.setString('gstr3b_returns', gstr3bJson);
  }

  // Generate return calendar from existing returns
  Future<void> _generateReturnCalendar() async {
    final now = DateTime.now();

    // Create upcoming returns list
    final List<GSTReturnDue> upcomingReturns = [];

    // Add upcoming GSTR-1 returns
    for (final gstr1 in _gstr1Returns) {
      if (gstr1.status == 'PENDING') {
        upcomingReturns.add(GSTReturnDue(
          returnType: 'GSTR-1',
          financialYear: gstr1.financialYear,
          taxPeriod: gstr1.taxPeriod,
          dueDate: gstr1.dueDate,
          status: gstr1.status,
        ));
      }
    }

    // Add upcoming GSTR-3B returns
    for (final gstr3b in _gstr3bReturns) {
      if (gstr3b.status == 'PENDING') {
        upcomingReturns.add(GSTReturnDue(
          returnType: 'GSTR-3B',
          financialYear: gstr3b.financialYear,
          taxPeriod: gstr3b.taxPeriod,
          dueDate: gstr3b.dueDate,
          status: gstr3b.status,
        ));
      }
    }

    // Create past returns list
    final List<GSTReturnDue> pastReturns = [];

    // Add past GSTR-1 returns
    for (final gstr1 in _gstr1Returns) {
      if (gstr1.status == 'FILED' || gstr1.status == 'LATE') {
        pastReturns.add(GSTReturnDue(
          returnType: 'GSTR-1',
          financialYear: gstr1.financialYear,
          taxPeriod: gstr1.taxPeriod,
          dueDate: gstr1.dueDate,
          status: gstr1.status,
        ));
      }
    }

    // Add past GSTR-3B returns
    for (final gstr3b in _gstr3bReturns) {
      if (gstr3b.status == 'FILED' || gstr3b.status == 'LATE') {
        pastReturns.add(GSTReturnDue(
          returnType: 'GSTR-3B',
          financialYear: gstr3b.financialYear,
          taxPeriod: gstr3b.taxPeriod,
          dueDate: gstr3b.dueDate,
          status: gstr3b.status,
        ));
      }
    }

    // Sort upcoming returns by due date
    upcomingReturns.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // Sort past returns by due date (descending)
    pastReturns.sort((a, b) => b.dueDate.compareTo(a.dueDate));

    // Create return calendar
    _returnCalendar = GSTReturnCalendar(
      upcomingReturns: upcomingReturns,
      pastReturns: pastReturns,
    );
  }

  // Get GSTR-1 return by financial year and tax period
  GSTR1Return? getGSTR1Return(String financialYear, String taxPeriod) {
    try {
      return _gstr1Returns.firstWhere(
        (r) => r.financialYear == financialYear && r.taxPeriod == taxPeriod,
      );
    } catch (e) {
      return null;
    }
  }

  // Get GSTR-3B return by financial year and tax period
  GSTR3BReturn? getGSTR3BReturn(String financialYear, String taxPeriod) {
    try {
      return _gstr3bReturns.firstWhere(
        (r) => r.financialYear == financialYear && r.taxPeriod == taxPeriod,
      );
    } catch (e) {
      return null;
    }
  }

  // Generate GSTR-1 return from invoices
  Future<GSTR1Return?> generateGSTR1(
    List<Invoice> invoices,
    String financialYear,
    String taxPeriod,
    DateTime dueDate,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if return already exists
      final existingReturn = getGSTR1Return(financialYear, taxPeriod);
      if (existingReturn != null) {
        // Return already exists
        _isLoading = false;
        notifyListeners();
        return existingReturn;
      }

      // Filter invoices for the given period
      final periodInvoices = _filterInvoicesForPeriod(invoices, taxPeriod, financialYear);

      // Create sections
      final List<GSTR1Section> sections = [];

      // B2B Section (for business customers with GSTIN)
      final b2bInvoices = periodInvoices
          .where((invoice) => invoice.customerInfo.gstin != null)
          .toList();

      if (b2bInvoices.isNotEmpty) {
        sections.add(GSTR1Section(
          sectionName: 'B2B Invoices',
          sectionCode: 'B2B',
          invoices: _convertToGSTR1Invoices(b2bInvoices, 'B2B'),
        ));
      }

      // B2C Section (for customers without GSTIN)
      final b2cInvoices = periodInvoices
          .where((invoice) => invoice.customerInfo.gstin == null)
          .toList();

      if (b2cInvoices.isNotEmpty) {
        sections.add(GSTR1Section(
          sectionName: 'B2C Invoices',
          sectionCode: 'B2C',
          invoices: _convertToGSTR1Invoices(b2cInvoices, 'B2C'),
        ));
      }

      // Create the GSTR-1 return
      final gstr1Return = GSTR1Return(
        financialYear: financialYear,
        taxPeriod: taxPeriod,
        dueDate: dueDate,
        filingDate: null,
        status: 'PENDING',
        sections: sections,
      );

      // Add to returns list
      _gstr1Returns.add(gstr1Return);

      // Save returns
      await _saveGSTReturns();

      // Update return calendar
      await _generateReturnCalendar();

      _isLoading = false;
      notifyListeners();
      return gstr1Return;
    } catch (e) {
      _errorMessage = 'Error generating GSTR-1 return: $e';
      print(_errorMessage);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Generate GSTR-3B return
  Future<GSTR3BReturn?> generateGSTR3B(
    GSTR1Return gstr1Return,
    GSTR3BData returnData,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if return already exists
      final existingReturn = getGSTR3BReturn(
        gstr1Return.financialYear,
        gstr1Return.taxPeriod,
      );

      if (existingReturn != null) {
        // Return already exists
        _isLoading = false;
        notifyListeners();
        return existingReturn;
      }

      // Create the GSTR-3B return
      final gstr3bReturn = GSTR3BReturn(
        financialYear: gstr1Return.financialYear,
        taxPeriod: gstr1Return.taxPeriod,
        dueDate: gstr1Return.dueDate.add(const Duration(days: 3)), // Usually due 3 days after GSTR-1
        filingDate: null,
        status: 'PENDING',
        returnData: returnData,
      );

      // Add to returns list
      _gstr3bReturns.add(gstr3bReturn);

      // Save returns
      await _saveGSTReturns();

      // Update return calendar
      await _generateReturnCalendar();

      _isLoading = false;
      notifyListeners();
      return gstr3bReturn;
    } catch (e) {
      _errorMessage = 'Error generating GSTR-3B return: $e';
      print(_errorMessage);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Mark a GSTR-1 return as filed
  Future<void> markGSTR1AsFiled(String financialYear, String taxPeriod) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find the return
      final index = _gstr1Returns.indexWhere(
        (r) => r.financialYear == financialYear && r.taxPeriod == taxPeriod,
      );

      if (index != -1) {
        // Update the return
        final updatedReturn = GSTR1Return(
          financialYear: _gstr1Returns[index].financialYear,
          taxPeriod: _gstr1Returns[index].taxPeriod,
          dueDate: _gstr1Returns[index].dueDate,
          filingDate: DateTime.now(),
          status: DateTime.now().isAfter(_gstr1Returns[index].dueDate) ? 'LATE' : 'FILED',
          sections: _gstr1Returns[index].sections,
        );

        // Replace the old return
        _gstr1Returns[index] = updatedReturn;

        // Save returns
        await _saveGSTReturns();

        // Update return calendar
        await _generateReturnCalendar();
      }
    } catch (e) {
      _errorMessage = 'Error marking GSTR-1 as filed: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mark a GSTR-3B return as filed
  Future<void> markGSTR3BAsFiled(String financialYear, String taxPeriod) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find the return
      final index = _gstr3bReturns.indexWhere(
        (r) => r.financialYear == financialYear && r.taxPeriod == taxPeriod,
      );

      if (index != -1) {
        // Update the return
        final updatedReturn = GSTR3BReturn(
          financialYear: _gstr3bReturns[index].financialYear,
          taxPeriod: _gstr3bReturns[index].taxPeriod,
          dueDate: _gstr3bReturns[index].dueDate,
          filingDate: DateTime.now(),
          status: DateTime.now().isAfter(_gstr3bReturns[index].dueDate) ? 'LATE' : 'FILED',
          returnData: _gstr3bReturns[index].returnData,
        );

        // Replace the old return
        _gstr3bReturns[index] = updatedReturn;

        // Save returns
        await _saveGSTReturns();

        // Update return calendar
        await _generateReturnCalendar();
      }
    } catch (e) {
      _errorMessage = 'Error marking GSTR-3B as filed: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Calculate GSTR-3B data from GSTR-1 return
  GSTR3BData calculateGSTR3BData(GSTR1Return gstr1Return) {
    // Calculate outward supplies
    double taxableValueInterstate = 0;
    double igstInterstate = 0;
    double taxableValueIntrastate = 0;
    double cgstIntrastate = 0;
    double sgstIntrastate = 0;
    double taxableValueZeroRated = 0;

    // Calculate inward supplies (example values - in a real app, this would come from purchase invoices)
    double taxableValueRCM = 0;
    double igstRCM = 0;
    double cgstRCM = 0;
    double sgstRCM = 0;

    // Calculate ITC (example values - in a real app, this would come from purchase invoices)
    double igstITC = 0;
    double cgstITC = 0;
    double sgstITC = 0;
    double cessITC = 0;

    // Process all sections in GSTR-1
    for (final section in gstr1Return.sections) {
      for (final invoice in section.invoices) {
        // Inter-state supply (IGST)
        if (invoice.igst > 0) {
          taxableValueInterstate += invoice.taxableValue;
          igstInterstate += invoice.igst;
        }
        // Intra-state supply (CGST + SGST)
        else if (invoice.cgst > 0 || invoice.sgst > 0) {
          taxableValueIntrastate += invoice.taxableValue;
          cgstIntrastate += invoice.cgst;
          sgstIntrastate += invoice.sgst;
        }
        // Zero-rated supply
        else {
          taxableValueZeroRated += invoice.taxableValue;
        }

        // In a real app, you would calculate RCM and ITC from purchase invoices
        // Here we're using dummy values for demonstration
        if (invoice.reverseCharge) {
          taxableValueRCM += invoice.taxableValue * 0.1; // Example: 10% of sales are under RCM
          igstRCM += invoice.igst * 0.1;
          cgstRCM += invoice.cgst * 0.1;
          sgstRCM += invoice.sgst * 0.1;
        }

        // Example ITC calculation (in a real app, this would come from purchase invoices)
        igstITC += invoice.igst * 0.9; // Example: 90% of IGST is eligible for ITC
        cgstITC += invoice.cgst * 0.9; // Example: 90% of CGST is eligible for ITC
        sgstITC += invoice.sgst * 0.9; // Example: 90% of SGST is eligible for ITC
        cessITC += invoice.cess * 0.9; // Example: 90% of Cess is eligible for ITC
      }
    }

    // Create outward supplies
    final outwardSupplies = GSTR3BOutwardSupplies(
      taxableValueInterstate: taxableValueInterstate,
      igstInterstate: igstInterstate,
      taxableValueIntrastate: taxableValueIntrastate,
      cgstIntrastate: cgstIntrastate,
      sgstIntrastate: sgstIntrastate,
      taxableValueZeroRated: taxableValueZeroRated,
    );

    // Create inward supplies
    final inwardSupplies = GSTR3BInwardSupplies(
      taxableValueRCM: taxableValueRCM,
      igstRCM: igstRCM,
      cgstRCM: cgstRCM,
      sgstRCM: sgstRCM,
    );

    // Create ITC details
    final itcDetails = GSTR3BItcDetails(
      igstITC: igstITC,
      cgstITC: cgstITC,
      sgstITC: sgstITC,
      cessITC: cessITC,
    );

    // Calculate interest and late fee (if applicable)
    double interestPayable = 0;
    double lateFee = 0;

    final now = DateTime.now();
    if (now.isAfter(gstr1Return.dueDate)) {
      // Calculate interest at 18% per annum
      final daysLate = now.difference(gstr1Return.dueDate).inDays;
      final totalTax = outwardSupplies.totalTax + inwardSupplies.totalReverseTaxLiability;
      interestPayable = totalTax * 0.18 * (daysLate / 365);

      // Late fee is typically a fixed amount (e.g., ₹100 per day)
      lateFee = 100 * daysLate;
    }

    // Create GSTR-3B data
    return GSTR3BData(
      outwardSupplies: outwardSupplies,
      inwardSupplies: inwardSupplies,
      itcDetails: itcDetails,
      interestPayable: interestPayable,
      lateFee: lateFee,
    );
  }

  // Get the tax period for a given date
  String getTaxPeriodForDate(DateTime date) {
    final format = DateFormat('MMM yyyy');
    return format.format(date);
  }

  // Get the financial year for a given date
  String getFinancialYearForDate(DateTime date) {
    final year = date.year;
    final month = date.month;

    if (month >= 4) {
      // April to December is part of the financial year starting in the current year
      return '$year-${(year + 1).toString().substring(2, 4)}';
    } else {
      // January to March is part of the financial year starting in the previous year
      return '${year - 1}-${year.toString().substring(2, 4)}';
    }
  }

  // Helper Methods

  // Filter invoices for a specific tax period
  List<Invoice> _filterInvoicesForPeriod(
    List<Invoice> invoices,
    String taxPeriod,
    String financialYear,
  ) {
    // Parse the tax period (e.g., "Apr 2023")
    final periodParts = taxPeriod.split(' ');
    final monthName = periodParts[0];
    final yearStr = periodParts[1];

    // Map month name to month number
    final monthMap = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };

    final monthNumber = monthMap[monthName]!;
    final year = int.parse(yearStr);

    // Create start and end dates for the period
    final startDate = DateTime(year, monthNumber, 1);
    final endDate = monthNumber < 12
        ? DateTime(year, monthNumber + 1, 1).subtract(const Duration(days: 1))
        : DateTime(year + 1, 1, 1).subtract(const Duration(days: 1));

    // Filter invoices that fall within the period
    return invoices.where((invoice) {
      return invoice.invoiceDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          invoice.invoiceDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Convert regular invoices to GSTR1Invoice objects
  List<GSTR1Invoice> _convertToGSTR1Invoices(
    List<Invoice> invoices,
    String invoiceType,
  ) {
    return invoices.map((invoice) {
      // Calculate taxable value and taxes
      double taxableValue = 0;
      double cgst = 0;
      double sgst = 0;
      double igst = 0;
      double cess = 0;

      // Get GST details from additional properties (if available)
      final additionalProps = invoice.additionalProperties;
      final gstDetails = additionalProps != null && additionalProps.containsKey('gst_details')
          ? additionalProps['gst_details'] as GSTInvoiceDetails
          : null;

      // If GST details are available, use them
      if (gstDetails != null) {
        // For inter-state supply
        if (gstDetails.isIGST) {
          final totalTax = invoice.calculateTotal() - invoice.calculateSubtotal();
          taxableValue = invoice.calculateSubtotal();
          igst = totalTax;
        }
        // For intra-state supply
        else {
          final totalTax = invoice.calculateTotal() - invoice.calculateSubtotal();
          taxableValue = invoice.calculateSubtotal();
          cgst = totalTax / 2;
          sgst = totalTax / 2;
        }
      }
      // If GST details are not available, calculate based on invoice items
      else {
        for (final item in invoice.items) {
          final itemValue = item.quantity * item.unitPrice;
          final taxRate = item.taxRate;
          final taxAmount = itemValue * (taxRate / 100);

          taxableValue += itemValue;

          // For simplicity, we'll split based on customer and seller state
          if (invoice.customerInfo.address.state != invoice.sellerInfo.address.state) {
            // Inter-state supply (IGST)
            igst += taxAmount;
          } else {
            // Intra-state supply (CGST + SGST)
            cgst += taxAmount / 2;
            sgst += taxAmount / 2;
          }
        }
      }

      // Determine if reverse charge applies
      final isReverseCharge = additionalProps != null &&
          additionalProps.containsKey('reverse_charge') &&
          additionalProps['reverse_charge'] as bool;

      // Get place of supply (state code)
      final placeOfSupply = invoice.customerInfo.address.state.substring(0, 2);

      return GSTR1Invoice(
        invoiceNumber: invoice.invoiceNumber,
        invoiceDate: invoice.invoiceDate,
        customerGstin: invoice.customerInfo.gstin,
        placeOfSupply: placeOfSupply,
        reverseCharge: isReverseCharge ?? false,
        invoiceType: invoiceType,
        taxableValue: taxableValue,
        cgst: cgst,
        sgst: sgst,
        igst: igst,
        cess: cess,
        ecommOperator: null, // Add if e-commerce operator details are available
      );
    }).toList();
  }

  // Generate sample GSTR-1 returns for testing
  List<GSTR1Return> _generateSampleGSTR1Returns() {
    final List<GSTR1Return> sampleReturns = [];
    final now = DateTime.now();

    // Add current month return
    final currentMonth = DateTime(now.year, now.month, 1);
    final currentMonthTaxPeriod = DateFormat('MMM yyyy').format(currentMonth);
    final currentFinancialYear = getFinancialYearForDate(currentMonth);

    // Current month GSTR-1 (typically due on the 11th of next month)
    final currentDueDate = DateTime(
      now.month < 12 ? now.year : now.year + 1,
      now.month < 12 ? now.month + 1 : 1,
      11,
    );

    sampleReturns.add(GSTR1Return(
      financialYear: currentFinancialYear,
      taxPeriod: currentMonthTaxPeriod,
      dueDate: currentDueDate,
      filingDate: null,
      status: 'PENDING',
      sections: [],
    ));

    // Add previous month's return
    final prevMonth = DateTime(
      now.month > 1 ? now.year : now.year - 1,
      now.month > 1 ? now.month - 1 : 12,
      1,
    );
    final prevMonthTaxPeriod = DateFormat('MMM yyyy').format(prevMonth);
    final prevFinancialYear = getFinancialYearForDate(prevMonth);

    // Previous month GSTR-1 (due date has passed)
    final prevDueDate = DateTime(now.year, now.month, 11);

    sampleReturns.add(GSTR1Return(
      financialYear: prevFinancialYear,
      taxPeriod: prevMonthTaxPeriod,
      dueDate: prevDueDate,
      filingDate: prevDueDate.subtract(const Duration(days: 2)),
      status: 'FILED',
      sections: [],
    ));

    return sampleReturns;
  }

  // Generate sample GSTR-3B returns for testing
  List<GSTR3BReturn> _generateSampleGSTR3BReturns() {
    final List<GSTR3BReturn> sampleReturns = [];
    final now = DateTime.now();

    // Add current month return
    final currentMonth = DateTime(now.year, now.month, 1);
    final currentMonthTaxPeriod = DateFormat('MMM yyyy').format(currentMonth);
    final currentFinancialYear = getFinancialYearForDate(currentMonth);

    // Current month GSTR-3B (typically due on the 20th of next month)
    final currentDueDate = DateTime(
      now.month < 12 ? now.year : now.year + 1,
      now.month < 12 ? now.month + 1 : 1,
      20,
    );

    sampleReturns.add(GSTR3BReturn(
      financialYear: currentFinancialYear,
      taxPeriod: currentMonthTaxPeriod,
      dueDate: currentDueDate,
      filingDate: null,
      status: 'PENDING',
      returnData: null,
    ));

    // Add previous month's return
    final prevMonth = DateTime(
      now.month > 1 ? now.year : now.year - 1,
      now.month > 1 ? now.month - 1 : 12,
      1,
    );
    final prevMonthTaxPeriod = DateFormat('MMM yyyy').format(prevMonth);
    final prevFinancialYear = getFinancialYearForDate(prevMonth);

    // Previous month GSTR-3B (due date has passed)
    final prevDueDate = DateTime(now.year, now.month, 20);

    sampleReturns.add(GSTR3BReturn(
      financialYear: prevFinancialYear,
      taxPeriod: prevMonthTaxPeriod,
      dueDate: prevDueDate,
      filingDate: prevDueDate.subtract(const Duration(days: 2)),
      status: 'FILED',
      returnData: null,
    ));

    return sampleReturns;
  }
}
