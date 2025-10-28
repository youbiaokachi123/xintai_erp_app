import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:xintai_flutter/models/monthly_piece_summary.dart';
import 'package:xintai_flutter/models/employee.dart';
import 'package:xintai_flutter/service/piece_work_service.dart';
import 'package:xintai_flutter/service/employee_service.dart';
import 'package:xintai_flutter/service/tenant_state_service.dart';
import 'package:xintai_flutter/screens/piece_work/piece_work_entry_screen.dart';
import 'package:xintai_flutter/widgets/message_dialog.dart';
import 'package:intl/intl.dart';

class PieceWorkMonthlyViewScreen extends StatefulWidget {
  const PieceWorkMonthlyViewScreen({super.key});

  @override
  State<PieceWorkMonthlyViewScreen> createState() =>
      _PieceWorkMonthlyViewScreenState();
}

class _PieceWorkMonthlyViewScreenState
    extends State<PieceWorkMonthlyViewScreen> {
  final PieceWorkService _pieceWorkService = PieceWorkService();
  final EmployeeService _employeeService = EmployeeService();
  final TenantStateService _tenantService = TenantStateService.instance;

  DateTime _selectedMonth = DateTime.now();
  String? _selectedEmployeeId;
  List<MonthlyPieceSummary> _allSummaries = [];
  List<MonthlyPieceSummary> _filteredSummaries = [];
  List<Employee> _employees = [];
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadEmployees(),
      _loadMonthlyData(),
    ]);
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await _employeeService.getEmployees();
      setState(() {
        _employees = employees.where((e) => e.status == 'active').toList();
      });
    } catch (e) {
      if (mounted) {
        context.showError('加载员工列表失败: $e');
      }
    }
  }

  Future<void> _loadMonthlyData() async {
    if (!_tenantService.hasCurrentTenant) {
      return;
    }

    setState(() => _isLoadingData = true);
    try {
      final summaries = await _pieceWorkService.getMonthlySummaries(
        _selectedMonth.year,
        _selectedMonth.month,
      );
      setState(() {
        _allSummaries = summaries;
        _filterSummaries();
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        context.showError('加载数据失败: $e');
      }
    }
  }

  void _filterSummaries() {
    setState(() {
      _filteredSummaries = _selectedEmployeeId == null
          ? _allSummaries
          : _allSummaries.where((s) => s.employeeId == _selectedEmployeeId).toList();
    });
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
      await _loadMonthlyData();
    }
  }

  void _onEmployeeChanged(String? employeeId) {
    setState(() {
      _selectedEmployeeId = employeeId;
    });
    _filterSummaries();
  }

  void _navigateToEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PieceWorkEntryScreen()),
    );
    if (result == true) {
      await _loadMonthlyData();
    }
  }

  void _showEmployeeDetail(MonthlyPieceSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EmployeeDetailSheet(summary: summary),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('计件工资月视图'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEntry(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选控件
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // 月份选择器
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectMonth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy年MM月').format(_selectedMonth),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF6B7280),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoadingData ? null : _loadMonthlyData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoadingData
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('刷新'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 员工筛选器
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedEmployeeId,
                        decoration: InputDecoration(
                          labelText: '筛选员工',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('全部员工'),
                          ),
                          ..._employees.map((employee) {
                            return DropdownMenuItem<String>(
                              value: employee.id,
                              child: Text(employee.name),
                            );
                          }),
                        ],
                        onChanged: _onEmployeeChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 统计概览
          if (_filteredSummaries.isNotEmpty) _buildStatisticsCard(),
          if (_filteredSummaries.isNotEmpty) const SizedBox(height: 8),

          // 数据表格
          Expanded(
            child: _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : _filteredSummaries.isEmpty
                ? _buildEmptyState()
                : _buildDataTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final totalAmount = _filteredSummaries.fold<double>(
      0,
      (sum, s) => sum + s.totalAmount,
    );
    final totalPieces = _filteredSummaries.fold<int>(
      0,
      (sum, s) => sum + s.totalPieces,
    );
    final totalEmployees = _filteredSummaries.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '总工资',
              '¥${totalAmount.toStringAsFixed(2)}',
              Colors.green,
            ),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _buildStatItem('总件数', totalPieces.toString(), Colors.blue),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _buildStatItem(
              '参与人数',
              totalEmployees.toString(),
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 64, color: const Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            '${DateFormat('yyyy年MM月').format(_selectedMonth)}暂无计件记录',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右上角的 + 按钮添加计件记录',
            style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToEntry(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            ),
            child: const Text('添加记录'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              '计件工资明细表',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
              fixedLeftColumns: 1,
              dataRowHeight: 56,
              headingRowHeight: 48,
              columns: [
                DataColumn2(
                  label: const Text(
                    '员工姓名',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  size: ColumnSize.L,
                  fixedWidth: 120,
                ),
                DataColumn2(
                  label: const Text(
                    '员工类型',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  size: ColumnSize.M,
                  fixedWidth: 100,
                ),
                DataColumn2(
                  label: const Text(
                    '工作天数',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  size: ColumnSize.S,
                  fixedWidth: 80,
                ),
                DataColumn2(
                  label: const Text(
                    '总件数',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  size: ColumnSize.S,
                  fixedWidth: 80,
                ),
                DataColumn2(
                  label: const Text(
                    '平均日件数',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  size: ColumnSize.S,
                  fixedWidth: 100,
                ),
                DataColumn2(
                  label: const Text(
                    '总金额',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  size: ColumnSize.M,
                  fixedWidth: 100,
                ),
                DataColumn2(
                  label: const Text(
                    '平均日工资',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  size: ColumnSize.M,
                  fixedWidth: 100,
                ),
                DataColumn2(
                  label: const Text(
                    '效率评级',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  size: ColumnSize.S,
                  fixedWidth: 80,
                ),
                const DataColumn(
                  label: Text(
                    '操作',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                _filteredSummaries.length,
                (index) => _buildDataRow(_filteredSummaries[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(MonthlyPieceSummary summary) {
    return DataRow2.byIndex(
      index: _filteredSummaries.indexOf(summary),
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    summary.employeeName.isNotEmpty
                        ? summary.employeeName[0]
                        : '?',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary.employeeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(summary.employeeTypeDisplay)),
        DataCell(Text('${summary.workedDays}天')),
        DataCell(Text('${summary.totalPieces}')),
        DataCell(Text(summary.averageDailyPieces.toStringAsFixed(1))),
        DataCell(
          Text(
            '¥${summary.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ),
        DataCell(
          Text(
            '¥${summary.averageDailyAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A90E2),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getEfficiencyColor(summary.efficiencyRating).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              summary.efficiencyRating,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getEfficiencyColor(summary.efficiencyRating),
              ),
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility, color: Color(0xFF6B7280)),
            onPressed: () => _showEmployeeDetail(summary),
          ),
        ),
      ],
    );
  }

  
  Color _getEfficiencyColor(String rating) {
    switch (rating) {
      case '超级高效':
        return const Color(0xFF10B981);
      case '高效':
        return const Color(0xFF3B82F6);
      case '正常':
        return const Color(0xFFF59E0B);
      case '一般':
        return const Color(0xFFFB923C);
      default:
        return const Color(0xFFEF4444);
    }
  }
}

class EmployeeDetailSheet extends StatelessWidget {
  final MonthlyPieceSummary summary;

  const EmployeeDetailSheet({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖拽指示器
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // 员工信息头部
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          summary.employeeName.isNotEmpty
                              ? summary.employeeName[0]
                              : '?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.employeeName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            '${summary.employeeTypeDisplay} • ${summary.monthDisplay}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 统计数据
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDetailStatItem(
                        '总工资',
                        '¥${summary.totalAmount.toStringAsFixed(2)}',
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailStatItem(
                        '总件数',
                        summary.totalPieces.toString(),
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailStatItem(
                        '工作天数',
                        '${summary.workedDays}天',
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 工作详情
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '工作详情',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...summary.workTypeDetails.entries.map((entry) {
                        return _buildWorkTypeCard(entry.key, entry.value);
                      }),
                      const SizedBox(height: 16),
                      // 其他信息
                      _buildInfoCard(
                        '平均日工资',
                        '¥${summary.averageDailyAmount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        '平均日件数',
                        summary.averageDailyPieces.toStringAsFixed(1),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildWorkTypeCard(String workType, DailyWorkSummary workSummary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                workType,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                '¥${workSummary.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat('件数', workSummary.totalPieces.toString()),
              ),
              Expanded(child: _buildMiniStat('天数', '${workSummary.days}天')),
              Expanded(
                child: _buildMiniStat(
                  '日均',
                  workSummary.averageDailyPieces.toStringAsFixed(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
