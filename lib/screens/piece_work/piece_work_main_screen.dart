import 'package:flutter/material.dart';
import 'package:xintai_flutter/screens/piece_work/piece_work_entry_screen.dart';
import 'package:xintai_flutter/screens/piece_work/piece_work_monthly_view_screen.dart';

class PieceWorkMainScreen extends StatelessWidget {
  const PieceWorkMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('计件工资管理')),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '功能选择',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFunctionCard(
                    context,
                    title: '录入计件',
                    subtitle: '记录员工每日计件数据',
                    icon: Icons.add_circle_outline,
                    color: const Color(0xFF10B981),
                    onTap: () => _navigateToEntry(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFunctionCard(
                    context,
                    title: '月度视图',
                    subtitle: '查看月度统计和报表',
                    icon: Icons.calendar_month,
                    color: const Color(0xFF3B82F6),
                    onTap: () => _navigateToMonthlyView(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
              SizedBox(width: 8),
              Text(
                '使用说明',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('• 录入计件：记录员工每天完成的工作件数和质量评分'),
          const SizedBox(height: 4),
          _buildInfoItem('• 单价设置：系统会根据员工类型和工作类型自动匹配单价'),
          const SizedBox(height: 4),
          _buildInfoItem('• 月度视图：查看月度汇总数据，包括总工资、总件数等统计'),
          const SizedBox(height: 4),
          _buildInfoItem('• 数据分析：支持按员工、工作类型等多维度分析'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF6B7280),
        height: 1.4,
      ),
    );
  }

  void _navigateToEntry(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PieceWorkEntryScreen()),
    );
  }

  void _navigateToMonthlyView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PieceWorkMonthlyViewScreen(),
      ),
    );
  }
}
