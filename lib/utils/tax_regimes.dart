import '../models/tax_model.dart';

/// Class containing tax regimes for different countries
class TaxRegimes {
  /// Get taxes for a specific country
  static List<Tax> getTaxesForCountry(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'IN':
        return getIndianTaxes();
      case 'US':
        return getUSTaxes();
      case 'CA':
        return getCanadianTaxes();
      case 'GB':
        return getUKTaxes();
      case 'AU':
        return getAustralianTaxes();
      default:
        return [];
    }
  }

  /// Get Indian GST taxes
  static List<Tax> getIndianTaxes() {
    return [
      // Standard GST rates
      Tax(
        id: 'in_gst_0',
        name: 'GST 0%',
        type: TaxType.gst,
        rate: 0.0,
        jurisdiction: 'IN',
        description: 'GST exempt items',
        isActive: true,
      ),
      Tax(
        id: 'in_gst_5',
        name: 'GST 5%',
        type: TaxType.gst,
        rate: 5.0,
        jurisdiction: 'IN',
        description: 'Essential items like edible oil, sugar, spices, etc.',
        isActive: true,
      ),
      Tax(
        id: 'in_gst_12',
        name: 'GST 12%',
        type: TaxType.gst,
        rate: 12.0,
        jurisdiction: 'IN',
        description: 'Items like apparel above ₹1000, processed foods, etc.',
        isActive: true,
      ),
      Tax(
        id: 'in_gst_18',
        name: 'GST 18%',
        type: TaxType.gst,
        rate: 18.0,
        jurisdiction: 'IN',
        description: 'Most items like computers, industrial intermediaries',
        isActive: true,
      ),
      Tax(
        id: 'in_gst_28',
        name: 'GST 28%',
        type: TaxType.gst,
        rate: 28.0,
        jurisdiction: 'IN',
        description: 'Luxury items, tobacco products, automobiles, etc.',
        isActive: true,
      ),

      // IGST for interstate transactions
      Tax(
        id: 'in_igst_5',
        name: 'IGST 5%',
        type: TaxType.gst,
        rate: 5.0,
        jurisdiction: 'IN',
        registrationNumber: 'IGST',
        description: 'Interstate GST 5%',
        isActive: true,
      ),
      Tax(
        id: 'in_igst_12',
        name: 'IGST 12%',
        type: TaxType.gst,
        rate: 12.0,
        jurisdiction: 'IN',
        registrationNumber: 'IGST',
        description: 'Interstate GST 12%',
        isActive: true,
      ),
      Tax(
        id: 'in_igst_18',
        name: 'IGST 18%',
        type: TaxType.gst,
        rate: 18.0,
        jurisdiction: 'IN',
        registrationNumber: 'IGST',
        description: 'Interstate GST 18%',
        isActive: true,
      ),
      Tax(
        id: 'in_igst_28',
        name: 'IGST 28%',
        type: TaxType.gst,
        rate: 28.0,
        jurisdiction: 'IN',
        registrationNumber: 'IGST',
        description: 'Interstate GST 28%',
        isActive: true,
      ),

      // CGST (Central GST) - Split portion of GST
      Tax(
        id: 'in_cgst_2.5',
        name: 'CGST 2.5%',
        type: TaxType.gst,
        rate: 2.5,
        jurisdiction: 'IN',
        registrationNumber: 'CGST',
        description: 'Central GST 2.5% (part of 5% GST)',
        isActive: true,
      ),
      Tax(
        id: 'in_cgst_6',
        name: 'CGST 6%',
        type: TaxType.gst,
        rate: 6.0,
        jurisdiction: 'IN',
        registrationNumber: 'CGST',
        description: 'Central GST 6% (part of 12% GST)',
        isActive: true,
      ),
      Tax(
        id: 'in_cgst_9',
        name: 'CGST 9%',
        type: TaxType.gst,
        rate: 9.0,
        jurisdiction: 'IN',
        registrationNumber: 'CGST',
        description: 'Central GST 9% (part of 18% GST)',
        isActive: true,
      ),
      Tax(
        id: 'in_cgst_14',
        name: 'CGST 14%',
        type: TaxType.gst,
        rate: 14.0,
        jurisdiction: 'IN',
        registrationNumber: 'CGST',
        description: 'Central GST 14% (part of 28% GST)',
        isActive: true,
      ),

      // SGST (State GST) - Split portion of GST
      Tax(
        id: 'in_sgst_2.5',
        name: 'SGST 2.5%',
        type: TaxType.gst,
        rate: 2.5,
        jurisdiction: 'IN',
        registrationNumber: 'SGST',
        description: 'State GST 2.5% (part of 5% GST)',
        isActive: true,
      ),
      Tax(
        id: 'in_sgst_6',
        name: 'SGST 6%',
        type: TaxType.gst,
        rate: 6.0,
        jurisdiction: 'IN',
        registrationNumber: 'SGST',
        description: 'State GST 6% (part of 12% GST)',
        isActive: true,
      ),
      Tax(
        id: 'in_sgst_9',
        name: 'SGST 9%',
        type: TaxType.gst,
        rate: 9.0,
        jurisdiction: 'IN',
        registrationNumber: 'SGST',
        description: 'State GST 9% (part of 18% GST)',
        isActive: true,
      ),
      Tax(
        id: 'in_sgst_14',
        name: 'SGST 14%',
        type: TaxType.gst,
        rate: 14.0,
        jurisdiction: 'IN',
        registrationNumber: 'SGST',
        description: 'State GST 14% (part of 28% GST)',
        isActive: true,
      ),
    ];
  }

  /// Get US taxes
  static List<Tax> getUSTaxes() {
    return [
      Tax(
        id: 'us_sales_tax',
        name: 'Sales Tax',
        type: TaxType.salesTax,
        rate: 0.0, // Different in each state and locality
        jurisdiction: 'US',
        description: 'Standard sales tax, varies by state and locality',
        isActive: true,
      ),
    ];
  }

  /// Get Canadian taxes
  static List<Tax> getCanadianTaxes() {
    return [
      Tax(
        id: 'ca_gst',
        name: 'GST',
        type: TaxType.gst,
        rate: 5.0,
        jurisdiction: 'CA',
        description: 'Goods and Services Tax',
        isActive: true,
      ),
      Tax(
        id: 'ca_hst',
        name: 'HST',
        type: TaxType.gst,
        rate: 13.0,
        jurisdiction: 'CA',
        description: 'Harmonized Sales Tax (Ontario)',
        isActive: true,
      ),
    ];
  }

  /// Get UK taxes
  static List<Tax> getUKTaxes() {
    return [
      Tax(
        id: 'gb_vat_standard',
        name: 'VAT Standard',
        type: TaxType.vat,
        rate: 20.0,
        jurisdiction: 'GB',
        description: 'Standard VAT rate',
        isActive: true,
      ),
      Tax(
        id: 'gb_vat_reduced',
        name: 'VAT Reduced',
        type: TaxType.vat,
        rate: 5.0,
        jurisdiction: 'GB',
        description: 'Reduced VAT rate',
        isActive: true,
      ),
      Tax(
        id: 'gb_vat_zero',
        name: 'VAT Zero',
        type: TaxType.vat,
        rate: 0.0,
        jurisdiction: 'GB',
        description: 'Zero-rated VAT',
        isActive: true,
      ),
    ];
  }

  /// Get Australian taxes
  static List<Tax> getAustralianTaxes() {
    return [
      Tax(
        id: 'au_gst',
        name: 'GST',
        type: TaxType.gst,
        rate: 10.0,
        jurisdiction: 'AU',
        description: 'Goods and Services Tax',
        isActive: true,
      ),
    ];
  }

  /// Get tax jurisdictions for India
  static List<TaxJurisdiction> getIndianJurisdictions() {
    final List<TaxJurisdiction> jurisdictions = [];
    final List<String> states = [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
      'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
      'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
      'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
      'Delhi', 'Chandigarh', 'Jammu and Kashmir'
    ];

    // Create a jurisdiction for each state
    for (final state in states) {
      jurisdictions.add(
        TaxJurisdiction(
          id: 'in_${state.toLowerCase().replaceAll(' ', '_')}',
          name: state,
          countryCode: 'IN',
          stateOrProvince: state,
          taxes: getIndianTaxes(),
          isActive: true,
        ),
      );
    }

    return jurisdictions;
  }
}
