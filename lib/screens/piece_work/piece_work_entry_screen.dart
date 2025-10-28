import 'package:flutter/material.dart';
import 'package:xintai_flutter/models/employee.dart';
import 'package:xintai_flutter/models/daily_piece_record.dart';
import 'package:xintai_flutter/service/employee_service.dart';
import 'package:xintai_flutter/service/piece_work_service.dart';
import 'package:xintai_flutter/widgets/message_dialog.dart';

class PieceWorkEntryScreen extends StatefulWidget {
  final DailyPieceRecord? record;

  const PieceWorkEntryScreen({super.key, this.record});

  @override
  State<PieceWorkEntryScreen> createState() => _PieceWorkEntryScreenState();
}

class _PieceWorkEntryScreenState extends State<PieceWorkEntryScreen> {
  final EmployeeService _employeeService = EmployeeService();
  final PieceWorkService _pieceWorkService = PieceWorkService();
  final _formKey = GlobalKey<FormState>();

  // 表单字段
  Employee? _selectedEmployee;
  DateTime _selectedDate = DateTime.now();
  String? _workType;
  int _pieceCount = 0;
  double _unitPrice = 0.0;
  final _notesController = TextEditingController();

  // 数据
  List<Employee> _employees = [];
  bool _isLoading = false;
  bool _isLoadingEmployees = false;

  
  @override
  void initState() {
    super.initState();
    _initializeData();
    if (widget.record != null) {
      _populateFields();
    }
  }

  void _initializeData() async {
    await _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoadingEmployees = true);
    try {
      final employees = await _employeeService.getEmployees();
      setState(() {
        _employees = employees.where((e) => e.status == 'active').toList();
        _isLoadingEmployees = false;
      });
    } catch (e) {
      setState(() => _isLoadingEmployees = false);
      context.showError('加载员工列表失败: $e');
    }
  }

  void _populateFields() {
    final record = widget.record!;

    // 找到对应的员工
    _selectedEmployee = _employees.firstWhere(
      (e) => e.id == record.employeeId,
      orElse: () => _employees.isNotEmpty
          ? _employees.first
          : Employee(
              id: '',
              tenantId: '',
              name: '未知员工',
              hireDate: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );

    _selectedDate = record.workDate;
    _workType = record.workType;
    _pieceCount = record.pieceCount;
    _unitPrice = record.unitPrice;
    _notesController.text = record.notes ?? '';
  }

  void _onEmployeeChanged(Employee? employee) {
    setState(() {
      _selectedEmployee = employee;
      _workType = employee?.employeeType;
    });
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEmployee == null || _workType == null) {
      context.showError('请选择员工');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _pieceWorkService.upsertDailyPieceRecord(
        employeeId: _selectedEmployee!.id,
        workDate: _selectedDate,
        workType: _workType!,
        pieceCount: _pieceCount,
        unitPrice: _unitPrice,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        context.showSuccess('计件记录保存成功');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        context.showError('保存失败: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.record == null ? '录入计件记录' : '编辑计件记录')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 员工选择
              _buildSectionCard([
                _buildDropdownField<Employee>(
                  label: '选择员工',
                  value: _selectedEmployee,
                  items: _employees,
                  itemLabel: (employee) => employee.name,
                  onChanged: _onEmployeeChanged,
                  isLoading: _isLoadingEmployees,
                  validator: (value) => value == null ? '请选择员工' : null,
                ),
              ]),
              const SizedBox(height: 16),

              // 工作信息
              _buildSectionCard([
                _buildDateField(
                  label: '工作日期',
                  date: _selectedDate,
                  onChanged: (date) => setState(() => _selectedDate = date),
                ),
                const SizedBox(height: 16),
                _buildInfoField(
                  label: '工作类型',
                  value: _workType ?? '请选择员工',
                ),
              ]),
              const SizedBox(height: 16),

              // 数量和金额
              _buildSectionCard([
                _buildNumberField(
                  label: '完成件数',
                  value: _pieceCount.toDouble(),
                  onChanged: (value) =>
                      setState(() => _pieceCount = value.toInt()),
                  validator: (value) {
                    if (value == null || value <= 0) {
                      return '请输入有效的件数';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildNumberField(
                  label: '单价 (元/件)',
                  value: _unitPrice,
                  onChanged: (value) => setState(() => _unitPrice = value),
                  validator: (value) {
                    if (value == null || value <= 0) {
                      return '请输入有效的单价';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '总金额：',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        '¥${(_pieceCount * _unitPrice).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // 备注
              _buildSectionCard([
                _buildTextField(
                  controller: _notesController,
                  label: '备注',
                  hintText: '请输入备注信息（可选）',
                  maxLines: 3,
                ),
              ]),
              const SizedBox(height: 24),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '保存记录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          )
        else
          DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
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
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator,
          ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required void Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              onChanged(selectedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, color: Color(0xFF6B7280)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required double value,
    required void Function(double) onChanged,
    String? Function(double?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.toString(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
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
          validator: (textValue) {
            if (textValue == null || textValue.isEmpty) {
              return '请输入数值';
            }
            final numValue = double.tryParse(textValue);
            return validator?.call(numValue);
          },
          onChanged: (textValue) {
            final numValue = double.tryParse(textValue);
            if (numValue != null) {
              onChanged(numValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
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
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }
}
