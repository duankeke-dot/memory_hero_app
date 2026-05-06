import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/training_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../config/routes.dart';

/// 家长控制台 - 数据看板
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trainingProvider = context.watch<TrainingProvider>();
    final childProvider = context.watch<ChildProfileProvider>();
    final stats = trainingProvider.getStats();
    final child = childProvider.currentChild;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '训练进度',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  child?.name ?? '宝贝',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // 总览卡片
            Row(
              children: [
                Expanded(child: _buildOverviewCard('总训练', '${stats.totalSessions}', '次', Icons.play_circle_outline)),
                SizedBox(width: 12.w),
                Expanded(child: _buildOverviewCard('总时长', '${stats.totalMinutes}', '分钟', Icons.timer)),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Row(
              children: [
                Expanded(child: _buildOverviewCard('平均正确率', '${(stats.avgAccuracy * 100).toInt()}%', '', Icons.check_circle_outline)),
                SizedBox(width: 12.w),
                Expanded(child: _buildOverviewCard('连续天数', '${trainingProvider.consecutiveDays}', '天', Icons.local_fire_department)),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // 能力雷达图
            const Text(
              '能力评估',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Container(
              height: 300.h,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child?.assessment != null
                  ? _buildRadarChart(child!.assessment)
                  : const Center(child: Text('暂无评估数据')),
            ),
            
            SizedBox(height: 24.h),
            
            // 训练类型分布
            const Text(
              '训练分布',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Container(
              height: 200.h,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildBarChart(stats),
            ),
            
            SizedBox(height: 24.h),
            
            // 最近记录
            const Text(
              '最近训练记录',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 12.h),
            
            _buildRecentRecords(trainingProvider),
            
            SizedBox(height: 24.h),
            
            // 导出报告按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.progressReport),
                icon: const Icon(Icons.file_download),
                label: const Text('导出详细报告'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewCard(String label, String value, String unit, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 24),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRadarChart(assessment) {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 5,
        ticksStyle: FlTickData(
          showLabels: false,
          tickColor: Colors.grey[300]!,
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          checkToShowHorizontalLine: (value) => value == 100,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          ),
        ),
        dataSets: [
          RadarDataSet(
            fillColor: AppTheme.primaryColor.withOpacity(0.3),
            borderColor: AppTheme.primaryColor,
            borderWidth: 2,
            entryRadius: 4,
            dataEntries: assessment.radarData
                .map((e) => RadarEntry(value: e['value'].toDouble()))
                .toList(),
          ),
        ],
        radarBorderData: const BorderSide(color: Colors.grey, width: 1),
        titlePositionPercentageOffset: 0.1,
        getTitle: (index, angle) {
          return RadarChartTitle(
            text: assessment.radarData[index]['name'],
            angle: angle,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          );
        },
      ),
    );
  }
  
  Widget _buildBarChart(stats) {
    final total = stats.readingCount + stats.memoryCount + stats.focusCount;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: total > 0 ? total * 1.2 : 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['阅读', '记忆', '专注'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    titles[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(toY: stats.readingCount.toDouble(), color: AppTheme.primaryColor, width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(toY: stats.memoryCount.toDouble(), color: AppTheme.accentColor, width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(toY: stats.focusCount.toDouble(), color: AppTheme.warningColor, width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildRecentRecords(TrainingProvider provider) {
    final records = provider.records.take(5).toList();
    
    if (records.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Center(
          child: Text('暂无训练记录', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final record = records[index];
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getTypeIcon(record.trainingType),
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.moduleName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _formatDate(record.startTime),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${record.accuracyPercent}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getAccuracyColor(record.accuracy),
                    ),
                  ),
                  Text(
                    '${record.durationSeconds ~/ 60}分钟',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  IconData _getTypeIcon(trainingType) {
    switch (trainingType) {
      case TrainingType.reading:
        return Icons.menu_book;
      case TrainingType.memory:
        return Icons.psychology;
      case TrainingType.focus:
        return Icons.target;
      case TrainingType.sensory:
        return Icons.run_circle;
    }
  }
  
  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return AppTheme.successColor;
    if (accuracy >= 0.6) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
