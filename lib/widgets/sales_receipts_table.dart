import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SalesReceiptsTable extends StatelessWidget {
  const SalesReceiptsTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Sales, Receipts, and Dues',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.info_outline,
                  color: AppColors.textGray,
                  size: 16,
                ),
              ],
            ),
          ),

          // Data table
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.borderGray,
                        width: 1,
                      ),
                    ),
                  ),
                  children: [
                    _buildHeaderCell(''),
                    _buildHeaderCell('Sales'),
                    _buildHeaderCell('Receipts'),
                    _buildHeaderCell('Due'),
                  ],
                ),

                // Data rows
                _buildDataRow('Today', '\$0.00', '\$0.00', '\$0.00'),
                _buildDataRow('This Week', '\$10.00', '\$0.00', '\$10.00'),
                _buildDataRow('This Month', '\$30.00', '\$0.00', '\$30.00'),
                _buildDataRow('This Quarter', '\$120.00', '\$0.00', '\$120.00'),
                _buildDataRow('This Year', '\$240.00', '\$0.00', '\$240.00'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textGray,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textAlign: text.isEmpty ? TextAlign.left : TextAlign.right,
      ),
    );
  }

  TableRow _buildDataRow(String period, String sales, String receipts, String due) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderGray,
            width: 1,
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            period,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        _buildLinkCell(sales),
        _buildLinkCell(receipts),
        _buildLinkCell(due),
      ],
    );
  }

  Widget _buildLinkCell(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        value,
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 14,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}
