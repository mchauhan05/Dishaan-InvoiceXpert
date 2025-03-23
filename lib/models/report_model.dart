import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Enum for report types
enum ReportType {
  sales,
  customers,
  products,
  taxes,
  expenses,
  profit,
  timeTracking,
  custom
}

/// Enum for report time periods
enum ReportPeriod {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisQuarter,
  lastQuarter,
  thisYear,
  lastYear,
  custom
}

/// Enum for chart types
enum ChartType {
  bar,
  line,
  pie,
  stacked,
  area,
  none
}

/// Class for report configuration
class ReportConfig {
  final ReportType type;
  final ReportPeriod period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final ChartType chartType;
  final bool showTotals;
  final bool showComparison;
  final ReportPeriod? comparisonPeriod;
  final bool includeSubtotals;
  final bool includeTaxes;
  final String currencyCode;
  final List<String> groupBy;
  final List<String> filterBy;
  final Map<String, dynamic> additionalParams;

  ReportConfig({
    required this.type,
    required this.period,
    this.customStartDate,
    this.customEndDate,
    this.chartType = ChartType.bar,
    this.showTotals = true,
    this.showComparison = false,
    this.comparisonPeriod,
    this.includeSubtotals = true,
    this.includeTaxes = true,
    this.currencyCode = 'USD',
    this.groupBy = const ['month'],
    this.filterBy = const [],
    this.additionalParams = const {},
  });

  /// Convert ReportConfig to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'period': period.index,
      'customStartDate': customStartDate?.toIso8601String(),
      'customEndDate': customEndDate?.toIso8601String(),
      'chartType': chartType.index,
      'showTotals': showTotals,
      'showComparison': showComparison,
      'comparisonPeriod': comparisonPeriod?.index,
      'includeSubtotals': includeSubtotals,
      'includeTaxes': includeTaxes,
      'currencyCode': currencyCode,
      'groupBy': groupBy,
      'filterBy': filterBy,
      'additionalParams': additionalParams,
    };
  }

  /// Create ReportConfig from JSON
  factory ReportConfig.fromJson(Map<String, dynamic> json) {
    return ReportConfig(
      type: ReportType.values[json['type']],
      period: ReportPeriod.values[json['period']],
      customStartDate: json['customStartDate'] != null
          ? DateTime.parse(json['customStartDate'])
          : null,
      customEndDate: json['customEndDate'] != null
          ? DateTime.parse(json['customEndDate'])
          : null,
      chartType: ChartType.values[json['chartType']],
      showTotals: json['showTotals'],
      showComparison: json['showComparison'],
      comparisonPeriod: json['comparisonPeriod'] != null
          ? ReportPeriod.values[json['comparisonPeriod']]
          : null,
      includeSubtotals: json['includeSubtotals'],
      includeTaxes: json['includeTaxes'],
      currencyCode: json['currencyCode'],
      groupBy: List<String>.from(json['groupBy']),
      filterBy: List<String>.from(json['filterBy']),
      additionalParams: json['additionalParams'],
    );
  }

  /// Get a copy with updated fields
  ReportConfig copyWith({
    ReportType? type,
    ReportPeriod? period,
    DateTime? customStartDate,
    DateTime? customEndDate,
    ChartType? chartType,
    bool? showTotals,
    bool? showComparison,
    ReportPeriod? comparisonPeriod,
    bool? includeSubtotals,
    bool? includeTaxes,
    String? currencyCode,
    List<String>? groupBy,
    List<String>? filterBy,
    Map<String, dynamic>? additionalParams,
  }) {
    return ReportConfig(
      type: type ?? this.type,
      period: period ?? this.period,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      chartType: chartType ?? this.chartType,
      showTotals: showTotals ?? this.showTotals,
      showComparison: showComparison ?? this.showComparison,
      comparisonPeriod: comparisonPeriod ?? this.comparisonPeriod,
      includeSubtotals: includeSubtotals ?? this.includeSubtotals,
      includeTaxes: includeTaxes ?? this.includeTaxes,
      currencyCode: currencyCode ?? this.currencyCode,
      groupBy: groupBy ?? this.groupBy,
      filterBy: filterBy ?? this.filterBy,
      additionalParams: additionalParams ?? this.additionalParams,
    );
  }

  /// Get date range based on period
  DateTimeRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case ReportPeriod.today:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
        );

      case ReportPeriod.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: yesterday,
          end: yesterday.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
        );

      case ReportPeriod.thisWeek:
        // Calculate start of week (Sunday)
        final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
        return DateTimeRange(
          start: startOfWeek,
          end: now,
        );

      case ReportPeriod.lastWeek:
        // Calculate start of last week (Sunday)
        final startOfThisWeek = today.subtract(Duration(days: today.weekday % 7));
        final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
        return DateTimeRange(
          start: startOfLastWeek,
          end: startOfLastWeek.add(const Duration(days: 7)).subtract(const Duration(seconds: 1)),
        );

      case ReportPeriod.thisMonth:
        return DateTimeRange(
          start: DateTime(today.year, today.month, 1),
          end: now,
        );

      case ReportPeriod.lastMonth:
        final lastMonth = today.month == 1
            ? DateTime(today.year - 1, 12, 1)
            : DateTime(today.year, today.month - 1, 1);
        final endOfLastMonth = DateTime(today.year, today.month, 1)
            .subtract(const Duration(seconds: 1));
        return DateTimeRange(
          start: lastMonth,
          end: endOfLastMonth,
        );

      case ReportPeriod.thisQuarter:
        final currentQuarter = (today.month - 1) ~/ 3;
        final startOfQuarter = DateTime(today.year, currentQuarter * 3 + 1, 1);
        return DateTimeRange(
          start: startOfQuarter,
          end: now,
        );

      case ReportPeriod.lastQuarter:
        final currentQuarter = (today.month - 1) ~/ 3;
        final lastQuarter = currentQuarter > 0 ? currentQuarter - 1 : 3;
        final yearOfLastQuarter = lastQuarter == 3 ? today.year - 1 : today.year;

        final startOfLastQuarter = DateTime(yearOfLastQuarter, lastQuarter * 3 + 1, 1);
        final endOfLastQuarter = DateTime(
          lastQuarter == 3 ? today.year : today.year,
          lastQuarter == 3 ? 1 : (lastQuarter + 1) * 3 + 1,
          1,
        ).subtract(const Duration(seconds: 1));

        return DateTimeRange(
          start: startOfLastQuarter,
          end: endOfLastQuarter,
        );

      case ReportPeriod.thisYear:
        return DateTimeRange(
          start: DateTime(today.year, 1, 1),
          end: now,
        );

      case ReportPeriod.lastYear:
        return DateTimeRange(
          start: DateTime(today.year - 1, 1, 1),
          end: DateTime(today.year, 1, 1).subtract(const Duration(seconds: 1)),
        );

      case ReportPeriod.custom:
        if (customStartDate != null && customEndDate != null) {
          return DateTimeRange(
            start: customStartDate!,
            end: customEndDate!,
          );
        }
        // Default to thisMonth if custom dates are not provided
        return DateTimeRange(
          start: DateTime(today.year, today.month, 1),
          end: now,
        );
    }
  }

  /// Get formatted period name
  String getPeriodName() {
    switch (period) {
      case ReportPeriod.today:
        return 'Today';
      case ReportPeriod.yesterday:
        return 'Yesterday';
      case ReportPeriod.thisWeek:
        return 'This Week';
      case ReportPeriod.lastWeek:
        return 'Last Week';
      case ReportPeriod.thisMonth:
        return 'This Month';
      case ReportPeriod.lastMonth:
        return 'Last Month';
      case ReportPeriod.thisQuarter:
        return 'This Quarter';
      case ReportPeriod.lastQuarter:
        return 'Last Quarter';
      case ReportPeriod.thisYear:
        return 'This Year';
      case ReportPeriod.lastYear:
        return 'Last Year';
      case ReportPeriod.custom:
        if (customStartDate != null && customEndDate != null) {
          final formatter = DateFormat('MMM d, yyyy');
          return '${formatter.format(customStartDate!)} - ${formatter.format(customEndDate!)}';
        }
        return 'Custom Period';
    }
  }
}

/// Class for a data point in a report
class ReportDataPoint {
  final String label;
  final double value;
  final double? comparisonValue;
  final Map<String, dynamic> metadata;
  final Color? color;

  ReportDataPoint({
    required this.label,
    required this.value,
    this.comparisonValue,
    this.metadata = const {},
    this.color,
  });

  /// Calculate percentage change if comparison value exists
  double? get percentageChange {
    if (comparisonValue == null || comparisonValue == 0) return null;
    return ((value - comparisonValue!) / comparisonValue!) * 100;
  }

  /// Get formatted percentage change
  String? get formattedPercentageChange {
    final change = percentageChange;
    if (change == null) return null;

    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }

  /// Convert ReportDataPoint to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'comparisonValue': comparisonValue,
      'metadata': metadata,
      'color': color?.value,
    };
  }

  /// Create ReportDataPoint from JSON
  factory ReportDataPoint.fromJson(Map<String, dynamic> json) {
    return ReportDataPoint(
      label: json['label'],
      value: json['value'],
      comparisonValue: json['comparisonValue'],
      metadata: json['metadata'] ?? {},
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }
}

/// Class for a data series in a report
class ReportDataSeries {
  final String name;
  final List<ReportDataPoint> data;
  final Color? color;

  ReportDataSeries({
    required this.name,
    required this.data,
    this.color,
  });

  /// Get total value of the series
  double get total => data.fold(0, (sum, point) => sum + point.value);

  /// Get average value of the series
  double get average => data.isEmpty ? 0 : total / data.length;

  /// Convert ReportDataSeries to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'data': data.map((point) => point.toJson()).toList(),
      'color': color?.value,
    };
  }

  /// Create ReportDataSeries from JSON
  factory ReportDataSeries.fromJson(Map<String, dynamic> json) {
    return ReportDataSeries(
      name: json['name'],
      data: (json['data'] as List)
          .map((pointJson) => ReportDataPoint.fromJson(pointJson))
          .toList(),
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }
}

/// Main class for a Report
class Report {
  final String id;
  final String title;
  final ReportConfig config;
  final List<ReportDataSeries> series;
  final DateTime generatedAt;
  final Map<String, dynamic> summary;
  final Map<String, dynamic> metadata;

  Report({
    required this.id,
    required this.title,
    required this.config,
    required this.series,
    required this.generatedAt,
    this.summary = const {},
    this.metadata = const {},
  });

  /// Get total value of the report
  double get total => series.fold(0, (sum, series) => sum + series.total);

  /// Convert Report to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'config': config.toJson(),
      'series': series.map((s) => s.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
      'summary': summary,
      'metadata': metadata,
    };
  }

  /// Create Report from JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
      config: ReportConfig.fromJson(json['config']),
      series: (json['series'] as List)
          .map((seriesJson) => ReportDataSeries.fromJson(seriesJson))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt']),
      summary: json['summary'] ?? {},
      metadata: json['metadata'] ?? {},
    );
  }

  /// Serialize Report to JSON string
  String serialize() {
    return jsonEncode(toJson());
  }

  /// Deserialize Report from JSON string
  static Report deserialize(String jsonString) {
    final json = jsonDecode(jsonString);
    return Report.fromJson(json);
  }
}

/// Class for customer insights
class CustomerInsights {
  final String customerId;
  final String customerName;
  final double totalSpent;
  final int invoiceCount;
  final double averageInvoiceValue;
  final DateTime firstPurchaseDate;
  final DateTime lastPurchaseDate;
  final double lifetimeValue;
  final int daysSinceLastPurchase;
  final String? mostPurchasedCategory;
  final double? mostPurchasedCategoryPercentage;
  final String segment;

  CustomerInsights({
    required this.customerId,
    required this.customerName,
    required this.totalSpent,
    required this.invoiceCount,
    required this.averageInvoiceValue,
    required this.firstPurchaseDate,
    required this.lastPurchaseDate,
    required this.lifetimeValue,
    required this.daysSinceLastPurchase,
    this.mostPurchasedCategory,
    this.mostPurchasedCategoryPercentage,
    required this.segment,
  });

  /// Convert CustomerInsights to JSON
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'totalSpent': totalSpent,
      'invoiceCount': invoiceCount,
      'averageInvoiceValue': averageInvoiceValue,
      'firstPurchaseDate': firstPurchaseDate.toIso8601String(),
      'lastPurchaseDate': lastPurchaseDate.toIso8601String(),
      'lifetimeValue': lifetimeValue,
      'daysSinceLastPurchase': daysSinceLastPurchase,
      'mostPurchasedCategory': mostPurchasedCategory,
      'mostPurchasedCategoryPercentage': mostPurchasedCategoryPercentage,
      'segment': segment,
    };
  }

  /// Create CustomerInsights from JSON
  factory CustomerInsights.fromJson(Map<String, dynamic> json) {
    return CustomerInsights(
      customerId: json['customerId'],
      customerName: json['customerName'],
      totalSpent: json['totalSpent'],
      invoiceCount: json['invoiceCount'],
      averageInvoiceValue: json['averageInvoiceValue'],
      firstPurchaseDate: DateTime.parse(json['firstPurchaseDate']),
      lastPurchaseDate: DateTime.parse(json['lastPurchaseDate']),
      lifetimeValue: json['lifetimeValue'],
      daysSinceLastPurchase: json['daysSinceLastPurchase'],
      mostPurchasedCategory: json['mostPurchasedCategory'],
      mostPurchasedCategoryPercentage: json['mostPurchasedCategoryPercentage'],
      segment: json['segment'],
    );
  }
}

/// Class for tax summary
class TaxSummary {
  final String taxName;
  final double taxRate;
  final double taxableAmount;
  final double taxAmount;
  final String? jurisdiction;
  final String? category;

  TaxSummary({
    required this.taxName,
    required this.taxRate,
    required this.taxableAmount,
    required this.taxAmount,
    this.jurisdiction,
    this.category,
  });

  /// Convert TaxSummary to JSON
  Map<String, dynamic> toJson() {
    return {
      'taxName': taxName,
      'taxRate': taxRate,
      'taxableAmount': taxableAmount,
      'taxAmount': taxAmount,
      'jurisdiction': jurisdiction,
      'category': category,
    };
  }

  /// Create TaxSummary from JSON
  factory TaxSummary.fromJson(Map<String, dynamic> json) {
    return TaxSummary(
      taxName: json['taxName'],
      taxRate: json['taxRate'],
      taxableAmount: json['taxableAmount'],
      taxAmount: json['taxAmount'],
      jurisdiction: json['jurisdiction'],
      category: json['category'],
    );
  }
}
