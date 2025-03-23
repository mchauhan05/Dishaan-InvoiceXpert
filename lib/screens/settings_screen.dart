import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/language_provider.dart'; // Add language provider import
import '../utils/translation_extension.dart'; // Add translation extension import
import '../widgets/sidebar.dart';
import '../widgets/app_layout.dart';
import '../constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar
          Sidebar(currentRoute: '/settings'),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Settings content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),

                      // Tabs
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Profile'),
                            Tab(text: 'Organization'),
                            Tab(text: 'Invoice Templates'),
                            Tab(text: 'Preferences'),
                          ],
                          labelColor: AppColors.primaryBlue,
                          unselectedLabelColor: AppColors.textGray,
                          indicatorColor: AppColors.primaryBlue,
                        ),
                      ),

                      // Tab content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Profile tab
                            _buildProfileTab(settingsProvider),

                            // Organization tab
                            _buildOrganizationTab(settingsProvider),

                            // Invoice Templates tab
                            _buildInvoiceTemplatesTab(settingsProvider),

                            // Preferences tab
                            _buildPreferencesTab(settingsProvider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(SettingsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - profile picture
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                            child: Text(
                              'D',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryBlue,
                              side: BorderSide(color: AppColors.borderGray),
                            ),
                            child: const Text('Change Photo'),
                          ),
                        ],
                      ),

                      const SizedBox(width: 48),

                      // Right side - form fields
                      Expanded(
                        child: Column(
                          children: [
                            // Row 1
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'First Name',
                                      hintText: 'Enter your first name',
                                    ),
                                    controller: TextEditingController(text: 'Demo'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Last Name',
                                      hintText: 'Enter your last name',
                                    ),
                                    controller: TextEditingController(text: 'User'),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Row 2
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                hintText: 'Enter your email address',
                              ),
                              controller: TextEditingController(text: 'demo@example.com'),
                            ),

                            const SizedBox(height: 16),

                            // Row 3
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Enter your phone number',
                              ),
                              controller: TextEditingController(text: '+1 (555) 123-4567'),
                            ),

                            const SizedBox(height: 24),

                            // Save button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text('Save Changes'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Change password section
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Password fields
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      hintText: 'Enter your current password',
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      hintText: 'Enter your new password',
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      hintText: 'Confirm your new password',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Update password button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Update Password'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationTab(SettingsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Organization Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 24),

              // Organization fields
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Organization Name',
                  hintText: 'Enter your organization name',
                ),
                controller: TextEditingController(text: 'Demo Organization'),
              ),

              const SizedBox(height: 16),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Business Type',
                  hintText: 'Select your business type',
                ),
                controller: TextEditingController(text: 'Technology'),
              ),

              const SizedBox(height: 16),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Business Address',
                  hintText: 'Enter your business address',
                ),
                controller: TextEditingController(text: '123 Business St, Suite 101, San Francisco, CA 94103'),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Tax ID / EIN',
                        hintText: 'Enter your tax ID',
                      ),
                      controller: TextEditingController(text: '12-3456789'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        hintText: 'Select your currency',
                      ),
                      controller: TextEditingController(text: 'USD ($)'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Save button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Save Organization Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceTemplatesTab(SettingsProvider provider) {
    return GridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisCount: 2,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      childAspectRatio: 0.8,
      children: [
        _buildTemplateCard('Classic', true),
        _buildTemplateCard('Modern', false),
        _buildTemplateCard('Professional', false),
        _buildTemplateCard('Minimalist', false),
      ],
    );
  }

  Widget _buildTemplateCard(String name, bool isSelected) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template preview (mock)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              width: double.infinity,
              child: Center(
                child: Text(
                  '$name Template',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Template info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Select', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab(SettingsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSwitchTile(
                    'Invoice Payment Received',
                    'Get notified when a client pays an invoice',
                    true,
                  ),
                  _buildSwitchTile(
                    'Invoice Due Reminder',
                    'Get notified when an invoice is due soon',
                    true,
                  ),
                  _buildSwitchTile(
                    'Invoice Overdue',
                    'Get notified when an invoice becomes overdue',
                    true,
                  ),
                  _buildSwitchTile(
                    'New Client Signs Up',
                    'Get notified when a new client creates an account',
                    false,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Default Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Default Payment Terms',
                            hintText: 'Select default payment terms',
                          ),
                          controller: TextEditingController(text: 'Net 30'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Default Tax Rate',
                            hintText: 'Enter default tax rate',
                          ),
                          controller: TextEditingController(text: '7.25%'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Invoice Prefix',
                            hintText: 'Enter invoice prefix',
                          ),
                          controller: TextEditingController(text: 'INV-'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Next Invoice Number',
                            hintText: 'Enter next invoice number',
                          ),
                          controller: TextEditingController(text: '1001'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Save Settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Regional Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add Language Settings ListTile
                  ListTile(
                    title: Text(
                      context.tr('language_settings'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    subtitle: Text(
                      context.tr('language_settings_description_short'),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                      ),
                    ),
                    trailing: Consumer<LanguageProvider>(
                      builder: (context, languageProvider, _) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              languageProvider.currentLanguage.localName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textGray,
                            ),
                          ],
                        );
                      }
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/language_settings');
                    },
                  ),

                  Divider(),

                  // Add UPI Payment Settings ListTile
                  ListTile(
                    title: Text(
                      context.tr('upi_payment_settings'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    subtitle: Text(
                      context.tr('upi_payment_settings_description'),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textGray,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/upi_settings');
                    },
                  ),

                  Divider(),

                  ListTile(
                    title: Text(
                      context.tr('indian_gst_settings'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    subtitle: Text(
                      context.tr('indian_gst_settings_description'),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textGray,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/indian_gst_settings');
                    },
                  ),

                  Divider(),

                  ListTile(
                    title: Text(
                      context.tr('currency_format'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    subtitle: Text(
                      context.tr('currency_format_description'),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textGray,
                    ),
                    onTap: () {
                      // This would navigate to currency settings in a real app
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool initialValue) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textGray,
        ),
      ),
      value: initialValue,
      onChanged: (value) {
        // This would update the settings provider in a real app
      },
      activeColor: AppColors.primaryBlue,
    );
  }
}
