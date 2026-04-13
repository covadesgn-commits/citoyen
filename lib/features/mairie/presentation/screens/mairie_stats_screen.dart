import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/stat_card.dart';

class MairieStatsScreen extends StatefulWidget {
  const MairieStatsScreen({super.key});

  @override
  State<MairieStatsScreen> createState() => _MairieStatsScreenState();
}

class _MairieStatsScreenState extends State<MairieStatsScreen> {
  String _selectedPeriod = 'Cette semaine';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodFilter(),
            const SizedBox(height: 32),
            _buildKeyMetrics(),
            const SizedBox(height: 32),
            const Text(
              'Signalements traités',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildBarChart(),
            const SizedBox(height: 32),
            const Text(
              'Répartition par gravité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildPieChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
          items: ['Aujourd\'hui', 'Cette semaine', 'Ce mois', 'Cette année']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedPeriod = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return const Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Nouveaux',
            value: '45',
            icon: Icons.add_circle_outline,
            trend: '+12%',
            isPositive: false,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Résolus',
            value: '38',
            icon: Icons.check_circle_outline,
            trend: '+5%',
            isPositive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12);
                  String text;
                  switch (value.toInt()) {
                    case 0: text = 'Lun'; break;
                    case 1: text = 'Mar'; break;
                    case 2: text = 'Mer'; break;
                    case 3: text = 'Jeu'; break;
                    case 4: text = 'Ven'; break;
                    case 5: text = 'Sam'; break;
                    case 6: text = 'Dim'; break;
                    default: text = ''; break;
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            _buildBarGroup(0, 8),
            _buildBarGroup(1, 10),
            _buildBarGroup(2, 14),
            _buildBarGroup(3, 15),
            _buildBarGroup(4, 13),
            _buildBarGroup(5, 10),
            _buildBarGroup(6, 6),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: AppColors.error,
                    value: 20,
                    title: '20%',
                    radius: 40,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: 45,
                    title: '45%',
                    radius: 40,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: AppColors.success,
                    value: 35,
                    title: '35%',
                    radius: 40,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIndicator(AppColors.error, 'Haute'),
                const SizedBox(height: 12),
                _buildIndicator(Colors.orange, 'Moyenne'),
                const SizedBox(height: 12),
                _buildIndicator(AppColors.success, 'Faible'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
