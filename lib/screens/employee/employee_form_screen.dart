import 'package:flutter/material.dart';
import 'package:xintai_flutter/models/employee.dart';
import 'package:xintai_flutter/service/employee_service.dart';
import 'package:xintai_flutter/service/tenant_state_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final EmployeeService _employeeService = EmployeeService();
  final TenantStateService _tenantService = TenantStateService.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _employeeNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _positionController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactPhoneController;

  String? _selectedGender;
  DateTime? _birthDate;
  DateTime? _hireDate;
  String _selectedStatus = 'active';

  bool _isLoading = false;

  final List<String> _genders = ['男', '女', '其他'];
  final List<Map<String, String>> _statusOptions = [
    {'value': 'active', 'label': '在职'},
    {'value': 'inactive', 'label': '休假'},
    {'value': 'resigned', 'label': '离职'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.employee != null) {
      _populateFields();
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _employeeNumberController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _positionController = TextEditingController();
    _addressController = TextEditingController();
    _emergencyContactNameController = TextEditingController();
    _emergencyContactPhoneController = TextEditingController();

    // 设置默认入职时间为今天
    if (widget.employee == null) {
      _hireDate = DateTime.now();
    }
  }

  void _populateFields() {
    final employee = widget.employee!;
    _nameController.text = employee.name;
    _employeeNumberController.text = employee.employeeNumber ?? '';
    _phoneController.text = employee.phone ?? '';
    _emailController.text = employee.email ?? '';
    _positionController.text = employee.position ?? '';
    _addressController.text = employee.address ?? '';
    _emergencyContactNameController.text = employee.emergencyContactName ?? '';
    _emergencyContactPhoneController.text = employee.emergencyContactPhone ?? '';
    _selectedGender = employee.gender;
    _birthDate = employee.birthDate;
    _hireDate = employee.hireDate;
    _selectedStatus = employee.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_tenantService.hasCurrentTenant) {
      _showError('请先选择租户');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      if (widget.employee == null) {
        // 创建新员工
        await _employeeService.createEmployee(
          name: _nameController.text.trim(),
          gender: _selectedGender,
          birthDate: _birthDate,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          employeeNumber: _employeeNumberController.text.trim().isEmpty ? null : _employeeNumberController.text.trim(),
          position: _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
          hireDate: _hireDate!,
          status: _selectedStatus,
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          emergencyContactName: _emergencyContactNameController.text.trim().isEmpty ? null : _emergencyContactNameController.text.trim(),
          emergencyContactPhone: _emergencyContactPhoneController.text.trim().isEmpty ? null : _emergencyContactPhoneController.text.trim(),
        );
        _showSuccess('员工创建成功');
      } else {
        // 更新现有员工
        await _employeeService.updateEmployee(
          id: widget.employee!.id,
          name: _nameController.text.trim(),
          gender: _selectedGender,
          birthDate: _birthDate,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          employeeNumber: _employeeNumberController.text.trim().isEmpty ? null : _employeeNumberController.text.trim(),
          position: _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
          hireDate: _hireDate!,
          status: _selectedStatus,
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          emergencyContactName: _emergencyContactNameController.text.trim().isEmpty ? null : _emergencyContactNameController.text.trim(),
          emergencyContactPhone: _emergencyContactPhoneController.text.trim().isEmpty ? null : _emergencyContactPhoneController.text.trim(),
        );
        _showSuccess('员工信息更新成功');
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isBirthDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate ? _birthDate ?? DateTime.now() : _hireDate ?? DateTime.now(),
      firstDate: isBirthDate ? DateTime(1900) : DateTime(2000),
      lastDate: isBirthDate ? DateTime.now() : DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
        } else {
          _hireDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.employee != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          isEditing ? '编辑员工' : '添加员工',
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF666666)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEmployee,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '保存',
                    style: TextStyle(
                      color: Color(0xFF4A90E2),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本信息
              _buildSectionTitle('基本信息'),
              const SizedBox(height: 12),
              _buildBasicInfoSection(),

              const SizedBox(height: 24),

              // 工作信息
              _buildSectionTitle('工作信息'),
              const SizedBox(height: 12),
              _buildWorkInfoSection(),

              const SizedBox(height: 24),

              // 联系信息
              _buildSectionTitle('联系信息'),
              const SizedBox(height: 12),
              _buildContactInfoSection(),

              const SizedBox(height: 24),

              // 紧急联系人
              _buildSectionTitle('紧急联系人'),
              const SizedBox(height: 12),
              _buildEmergencyContactSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          _buildTextField(
            controller: _nameController,
            label: '姓名',
            hintText: '请输入员工姓名',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入员工姓名';
              }
              if (value.trim().length < 2) {
                return '员工姓名至少需要2个字符';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: '性别',
            value: _selectedGender,
            items: _genders,
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: '出生日期',
            date: _birthDate,
            onTap: () => _selectDate(context, isBirthDate: true),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _employeeNumberController,
            label: '员工编号',
            hintText: '请输入员工编号',
          ),
        ],
      ),
    );
  }

  Widget _buildWorkInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          _buildTextField(
            controller: _positionController,
            label: '职位',
            hintText: '请输入职位名称',
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: '入职时间',
            date: _hireDate,
            onTap: () => _selectDate(context, isBirthDate: false),
            validator: (value) {
              if (_hireDate == null) {
                return '请选择入职时间';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: '状态',
            value: _statusOptions.firstWhere((option) => option['value'] == _selectedStatus, orElse: () => _statusOptions[0])['label'],
            items: _statusOptions.map((option) => option['label'] as String).toList(),
            onChanged: (value) {
              if (value != null) {
                final status = _statusOptions.firstWhere(
                  (option) => option['label'] == value,
                  orElse: () => _statusOptions[0],
                );
                setState(() {
                  _selectedStatus = status['value'] ?? 'active';
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          _buildTextField(
            controller: _phoneController,
            label: '手机号码',
            hintText: '请输入手机号码',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
                if (!phoneRegex.hasMatch(value.trim())) {
                  return '请输入有效的手机号码';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: '邮箱',
            hintText: '请输入邮箱地址',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return '请输入有效的邮箱地址';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: '地址',
            hintText: '请输入详细地址',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          _buildTextField(
            controller: _emergencyContactNameController,
            label: '紧急联系人姓名',
            hintText: '请输入紧急联系人姓名',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emergencyContactPhoneController,
            label: '紧急联系人电话',
            hintText: '请输入紧急联系人电话',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
                if (!phoneRegex.hasMatch(value.trim())) {
                  return '请输入有效的手机号码';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                '请选择$label',
                style: const TextStyle(color: Color(0xFF9CA3AF)),
              ),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    String? Function(String?)? validator,
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Row(
              children: [
                Text(
                  date != null
                      ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                      : '请选择日期',
                  style: TextStyle(
                    color: date != null ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}