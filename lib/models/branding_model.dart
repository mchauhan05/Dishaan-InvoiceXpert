import 'package:flutter/material.dart';

/// Brand colors class
class BrandColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color text;
  final Color background;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  BrandColors({
    required this.primary,
    required this.secondary,
    this.accent = const Color(0xFF5C6BC0),
    this.text = const Color(0xFF333333),
    this.background = const Color(0xFFF5F5F5),
    this.success = const Color(0xFF4CAF50),
    this.warning = const Color(0xFFFFC107),
    this.error = const Color(0xFFF44336),
    this.info = const Color(0xFF2196F3),
  });

  /// Convert to JSON (as hex strings)
  Map<String, dynamic> toJson() {
    return {
      'primary': primary.value.toRadixString(16),
      'secondary': secondary.value.toRadixString(16),
      'accent': accent.value.toRadixString(16),
      'text': text.value.toRadixString(16),
      'background': background.value.toRadixString(16),
      'success': success.value.toRadixString(16),
      'warning': warning.value.toRadixString(16),
      'error': error.value.toRadixString(16),
      'info': info.value.toRadixString(16),
    };
  }

  /// Create from JSON
  factory BrandColors.fromJson(Map<String, dynamic> json) {
    return BrandColors(
      primary: Color(int.parse(json['primary'], radix: 16)),
      secondary: Color(int.parse(json['secondary'], radix: 16)),
      accent: json['accent'] != null
        ? Color(int.parse(json['accent'], radix: 16))
        : const Color(0xFF5C6BC0),
      text: json['text'] != null
        ? Color(int.parse(json['text'], radix: 16))
        : const Color(0xFF333333),
      background: json['background'] != null
        ? Color(int.parse(json['background'], radix: 16))
        : const Color(0xFFF5F5F5),
      success: json['success'] != null
        ? Color(int.parse(json['success'], radix: 16))
        : const Color(0xFF4CAF50),
      warning: json['warning'] != null
        ? Color(int.parse(json['warning'], radix: 16))
        : const Color(0xFFFFC107),
      error: json['error'] != null
        ? Color(int.parse(json['error'], radix: 16))
        : const Color(0xFFF44336),
      info: json['info'] != null
        ? Color(int.parse(json['info'], radix: 16))
        : const Color(0xFF2196F3),
    );
  }

  /// Create a copy with updated fields
  BrandColors copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? text,
    Color? background,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return BrandColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      text: text ?? this.text,
      background: background ?? this.background,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  /// Default brand colors
  factory BrandColors.defaultColors() {
    return BrandColors(
      primary: const Color(0xFF2196F3),    // Blue
      secondary: const Color(0xFF4CAF50),  // Green
    );
  }

  /// Blue theme
  factory BrandColors.blue() {
    return BrandColors(
      primary: const Color(0xFF1976D2),    // Blue
      secondary: const Color(0xFF64B5F6),  // Light Blue
    );
  }

  /// Green theme
  factory BrandColors.green() {
    return BrandColors(
      primary: const Color(0xFF388E3C),    // Green
      secondary: const Color(0xFF81C784),  // Light Green
    );
  }

  /// Orange theme
  factory BrandColors.orange() {
    return BrandColors(
      primary: const Color(0xFFE64A19),    // Deep Orange
      secondary: const Color(0xFFFF8A65),  // Light Orange
    );
  }

  /// Purple theme
  factory BrandColors.purple() {
    return BrandColors(
      primary: const Color(0xFF7B1FA2),    // Purple
      secondary: const Color(0xFFBA68C8),  // Light Purple
    );
  }

  /// Red theme
  factory BrandColors.red() {
    return BrandColors(
      primary: const Color(0xFFC62828),    // Red
      secondary: const Color(0xFFEF5350),  // Light Red
    );
  }

  /// Indian flag theme
  factory BrandColors.indianFlag() {
    return BrandColors(
      primary: const Color(0xFFFF9933),    // Saffron
      secondary: const Color(0xFF138808),  // Green
      accent: const Color(0xFF000080),     // Navy Blue (Ashoka Chakra)
    );
  }
}

/// Logo configuration
class LogoConfig {
  final String? logoUrl;
  final double width;
  final double height;
  final String? alternateText;
  final bool showInHeader;
  final bool showInInvoice;
  final bool showInReports;
  final String? customLogoPath; // For locally stored logo

  LogoConfig({
    this.logoUrl,
    this.width = 180,
    this.height = 60,
    this.alternateText,
    this.showInHeader = true,
    this.showInInvoice = true,
    this.showInReports = true,
    this.customLogoPath,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'logoUrl': logoUrl,
      'width': width,
      'height': height,
      'alternateText': alternateText,
      'showInHeader': showInHeader,
      'showInInvoice': showInInvoice,
      'showInReports': showInReports,
      'customLogoPath': customLogoPath,
    };
  }

  /// Create from JSON
  factory LogoConfig.fromJson(Map<String, dynamic> json) {
    return LogoConfig(
      logoUrl: json['logoUrl'],
      width: json['width'] ?? 180,
      height: json['height'] ?? 60,
      alternateText: json['alternateText'],
      showInHeader: json['showInHeader'] ?? true,
      showInInvoice: json['showInInvoice'] ?? true,
      showInReports: json['showInReports'] ?? true,
      customLogoPath: json['customLogoPath'],
    );
  }

  /// Create a copy with updated fields
  LogoConfig copyWith({
    String? logoUrl,
    double? width,
    double? height,
    String? alternateText,
    bool? showInHeader,
    bool? showInInvoice,
    bool? showInReports,
    String? customLogoPath,
  }) {
    return LogoConfig(
      logoUrl: logoUrl ?? this.logoUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      alternateText: alternateText ?? this.alternateText,
      showInHeader: showInHeader ?? this.showInHeader,
      showInInvoice: showInInvoice ?? this.showInInvoice,
      showInReports: showInReports ?? this.showInReports,
      customLogoPath: customLogoPath ?? this.customLogoPath,
    );
  }
}

/// Font configuration
class FontConfig {
  final String fontFamily;
  final double titleFontSize;
  final double headingFontSize;
  final double bodyFontSize;
  final double smallFontSize;
  final FontWeight titleFontWeight;
  final FontWeight headingFontWeight;
  final FontWeight bodyFontWeight;

  FontConfig({
    this.fontFamily = 'Roboto',
    this.titleFontSize = 24,
    this.headingFontSize = 18,
    this.bodyFontSize = 14,
    this.smallFontSize = 12,
    this.titleFontWeight = FontWeight.bold,
    this.headingFontWeight = FontWeight.bold,
    this.bodyFontWeight = FontWeight.normal,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'titleFontSize': titleFontSize,
      'headingFontSize': headingFontSize,
      'bodyFontSize': bodyFontSize,
      'smallFontSize': smallFontSize,
      'titleFontWeight': titleFontWeight.index,
      'headingFontWeight': headingFontWeight.index,
      'bodyFontWeight': bodyFontWeight.index,
    };
  }

  /// Create from JSON
  factory FontConfig.fromJson(Map<String, dynamic> json) {
    return FontConfig(
      fontFamily: json['fontFamily'] ?? 'Roboto',
      titleFontSize: json['titleFontSize'] ?? 24,
      headingFontSize: json['headingFontSize'] ?? 18,
      bodyFontSize: json['bodyFontSize'] ?? 14,
      smallFontSize: json['smallFontSize'] ?? 12,
      titleFontWeight: FontWeight.values[json['titleFontWeight'] ?? 7], // 7 = FontWeight.bold
      headingFontWeight: FontWeight.values[json['headingFontWeight'] ?? 7],
      bodyFontWeight: FontWeight.values[json['bodyFontWeight'] ?? 4], // 4 = FontWeight.normal
    );
  }

  /// Create a copy with updated fields
  FontConfig copyWith({
    String? fontFamily,
    double? titleFontSize,
    double? headingFontSize,
    double? bodyFontSize,
    double? smallFontSize,
    FontWeight? titleFontWeight,
    FontWeight? headingFontWeight,
    FontWeight? bodyFontWeight,
  }) {
    return FontConfig(
      fontFamily: fontFamily ?? this.fontFamily,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      headingFontSize: headingFontSize ?? this.headingFontSize,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
      smallFontSize: smallFontSize ?? this.smallFontSize,
      titleFontWeight: titleFontWeight ?? this.titleFontWeight,
      headingFontWeight: headingFontWeight ?? this.headingFontWeight,
      bodyFontWeight: bodyFontWeight ?? this.bodyFontWeight,
    );
  }

  /// Get common font family presets
  static List<String> getCommonFontFamilies() {
    return [
      'Roboto',
      'Lato',
      'Open Sans',
      'Montserrat',
      'Poppins',
      'Noto Sans',
      'Raleway',
      'Source Sans Pro',
      'Ubuntu',
      'Merriweather',
      'Playfair Display',
    ];
  }
}

/// Invoice template styles
class InvoiceTemplate {
  final String id;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final bool hasHeader;
  final bool hasFooter;
  final bool hasWatermark;
  final bool hasBorders;
  final String colorScheme; // 'color', 'monochrome', 'minimalist'
  final String layout; // 'classic', 'modern', 'compact'

  InvoiceTemplate({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailUrl,
    this.hasHeader = true,
    this.hasFooter = true,
    this.hasWatermark = false,
    this.hasBorders = true,
    this.colorScheme = 'color',
    this.layout = 'classic',
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'hasHeader': hasHeader,
      'hasFooter': hasFooter,
      'hasWatermark': hasWatermark,
      'hasBorders': hasBorders,
      'colorScheme': colorScheme,
      'layout': layout,
    };
  }

  /// Create from JSON
  factory InvoiceTemplate.fromJson(Map<String, dynamic> json) {
    return InvoiceTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      hasHeader: json['hasHeader'] ?? true,
      hasFooter: json['hasFooter'] ?? true,
      hasWatermark: json['hasWatermark'] ?? false,
      hasBorders: json['hasBorders'] ?? true,
      colorScheme: json['colorScheme'] ?? 'color',
      layout: json['layout'] ?? 'classic',
    );
  }

  /// Create a copy with updated fields
  InvoiceTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? thumbnailUrl,
    bool? hasHeader,
    bool? hasFooter,
    bool? hasWatermark,
    bool? hasBorders,
    String? colorScheme,
    String? layout,
  }) {
    return InvoiceTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      hasHeader: hasHeader ?? this.hasHeader,
      hasFooter: hasFooter ?? this.hasFooter,
      hasWatermark: hasWatermark ?? this.hasWatermark,
      hasBorders: hasBorders ?? this.hasBorders,
      colorScheme: colorScheme ?? this.colorScheme,
      layout: layout ?? this.layout,
    );
  }

  /// Get default templates
  static List<InvoiceTemplate> getDefaultTemplates() {
    return [
      InvoiceTemplate(
        id: 'classic',
        name: 'Classic',
        description: 'Traditional invoice layout with a professional design',
        colorScheme: 'color',
        layout: 'classic',
      ),
      InvoiceTemplate(
        id: 'modern',
        name: 'Modern',
        description: 'Contemporary design with clean lines and visual hierarchy',
        colorScheme: 'color',
        layout: 'modern',
      ),
      InvoiceTemplate(
        id: 'minimal',
        name: 'Minimal',
        description: 'Simple, clean design focusing on essential information',
        colorScheme: 'monochrome',
        layout: 'compact',
        hasBorders: false,
      ),
      InvoiceTemplate(
        id: 'professional',
        name: 'Professional',
        description: 'Sophisticated design with attention to detail',
        colorScheme: 'color',
        layout: 'classic',
        hasFooter: true,
        hasWatermark: true,
      ),
      InvoiceTemplate(
        id: 'indian',
        name: 'Indian',
        description: 'Design optimized for Indian GST compliance',
        colorScheme: 'color',
        layout: 'classic',
        hasFooter: true,
        hasHeader: true,
      ),
    ];
  }
}

/// Comprehensive branding settings
class BrandingSettings {
  final BrandColors colors;
  final LogoConfig logoConfig;
  final FontConfig fontConfig;
  final InvoiceTemplate selectedInvoiceTemplate;
  final List<InvoiceTemplate> availableTemplates;
  final String? customCss; // For advanced customization

  BrandingSettings({
    required this.colors,
    required this.logoConfig,
    required this.fontConfig,
    required this.selectedInvoiceTemplate,
    required this.availableTemplates,
    this.customCss,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'colors': colors.toJson(),
      'logoConfig': logoConfig.toJson(),
      'fontConfig': fontConfig.toJson(),
      'selectedInvoiceTemplate': selectedInvoiceTemplate.toJson(),
      'availableTemplates': availableTemplates.map((template) => template.toJson()).toList(),
      'customCss': customCss,
    };
  }

  /// Create from JSON
  factory BrandingSettings.fromJson(Map<String, dynamic> json) {
    return BrandingSettings(
      colors: BrandColors.fromJson(json['colors']),
      logoConfig: LogoConfig.fromJson(json['logoConfig']),
      fontConfig: FontConfig.fromJson(json['fontConfig']),
      selectedInvoiceTemplate: InvoiceTemplate.fromJson(json['selectedInvoiceTemplate']),
      availableTemplates: (json['availableTemplates'] as List)
          .map((template) => InvoiceTemplate.fromJson(template))
          .toList(),
      customCss: json['customCss'],
    );
  }

  /// Create a copy with updated fields
  BrandingSettings copyWith({
    BrandColors? colors,
    LogoConfig? logoConfig,
    FontConfig? fontConfig,
    InvoiceTemplate? selectedInvoiceTemplate,
    List<InvoiceTemplate>? availableTemplates,
    String? customCss,
  }) {
    return BrandingSettings(
      colors: colors ?? this.colors,
      logoConfig: logoConfig ?? this.logoConfig,
      fontConfig: fontConfig ?? this.fontConfig,
      selectedInvoiceTemplate: selectedInvoiceTemplate ?? this.selectedInvoiceTemplate,
      availableTemplates: availableTemplates ?? this.availableTemplates,
      customCss: customCss ?? this.customCss,
    );
  }

  /// Create default branding settings
  factory BrandingSettings.defaults() {
    return BrandingSettings(
      colors: BrandColors.defaultColors(),
      logoConfig: LogoConfig(),
      fontConfig: FontConfig(),
      selectedInvoiceTemplate: InvoiceTemplate.getDefaultTemplates().first,
      availableTemplates: InvoiceTemplate.getDefaultTemplates(),
    );
  }

  /// Create Indian-themed branding settings
  factory BrandingSettings.indianTheme() {
    return BrandingSettings(
      colors: BrandColors.indianFlag(),
      logoConfig: LogoConfig(),
      fontConfig: FontConfig(
        fontFamily: 'Poppins',
      ),
      selectedInvoiceTemplate: InvoiceTemplate.getDefaultTemplates()
          .firstWhere((template) => template.id == 'indian'),
      availableTemplates: InvoiceTemplate.getDefaultTemplates(),
    );
  }
}
