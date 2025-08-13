import 'package:flutter/material.dart';
import 'package:flutter_web_willbefore/core/constants/app_colors.dart';

import '../../../../models/dashboard_models.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final List<ChartData> data;
  final ChartType chartType;
  final List<String> timeFilters;
  final String selectedFilter;
  final Function(String)? onFilterChanged;

  const ChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.chartType,
    this.timeFilters = const ['Day', 'Week', 'Month'],
    this.selectedFilter = 'Month',
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  // color: AppColors.,
                ),
              ),
              if (timeFilters.isNotEmpty)
                Row(
                  children: timeFilters.map((filter) {
                    final isSelected = filter == selectedFilter;
                    return GestureDetector(
                      onTap: () => onFilterChanged?.call(filter),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLaurel
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            // color: isSelected ? AppColors.primaryLaurel : AppTheme.borderColor,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            // color: isSelected ? Colors.white : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.area:
        return _buildAreaChart();
    }
  }

  Widget _buildLineChart() {
    if (data.isEmpty) return const SizedBox();

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: LineChartPainter(data: data, maxValue: maxValue),
    );
  }

  Widget _buildBarChart() {
    if (data.isEmpty) return const SizedBox();

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final height = (item.value / maxValue) * 160;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 24,
              height: height,
              decoration: BoxDecoration(
                // color: AppColors.primaryLaurel,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 12,
                // color: AppTheme.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAreaChart() {
    if (data.isEmpty) return const SizedBox();

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: AreaChartPainter(data: data, maxValue: maxValue),
    );
  }
}

enum ChartType { line, bar, area }

class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double maxValue;

  LineChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i].value / maxValue) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw points
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.orange);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AreaChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double maxValue;

  AreaChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ..color = AppColors.primaryLaurel.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      // ..color = AppColors.primaryLaurel
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final strokePath = Path();

    // Start from bottom left
    path.moveTo(0, size.height);

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i].value / maxValue) * size.height;

      path.lineTo(x, y);

      if (i == 0) {
        strokePath.moveTo(x, y);
      } else {
        strokePath.lineTo(x, y);
      }
    }

    // Close the path to bottom right
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
