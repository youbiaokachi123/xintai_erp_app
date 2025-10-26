import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../service/tenant_service.dart';

class TenantDetailScreen extends StatefulWidget {
  final Tenant tenant;

  const TenantDetailScreen({
    super.key,
    required this.tenant,
  });

  @override
  State<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> {
  final TenantService _tenantService = TenantService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _contactEmailController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;
  bool _isDeleting = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _isEditing = widget.tenant.id.isEmpty; // 新建租户时自动进入编辑模式
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.tenant.name);
    _addressController = TextEditingController(text: widget.tenant.address);
    _contactNameController = TextEditingController(text: widget.tenant.contactName);
    _contactPhoneController = TextEditingController(text: widget.tenant.contactPhone);
    _contactEmailController = TextEditingController(text: widget.tenant.contactEmail);
    _descriptionController = TextEditingController(text: widget.tenant.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveTenant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.tenant.id.isEmpty) {
        // 创建新租户
        await _tenantService.createTenant(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          contactName: _contactNameController.text.trim(),
          contactPhone: _contactPhoneController.text.trim(),
          contactEmail: _contactEmailController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        _showSuccessMessage('租户创建成功');
      } else {
        // 更新现有租户
        await _tenantService.updateTenant(
          tenantId: widget.tenant.id,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          contactName: _contactNameController.text.trim(),
          contactPhone: _contactPhoneController.text.trim(),
          contactEmail: _contactEmailController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        _showSuccessMessage('租户信息更新成功');
      }

      setState(() => _isEditing = false);
      Navigator.pop(context, true); // 返回并刷新列表
    } catch (e) {
      _showErrorMessage('保存失败');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTenant() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除租户"${widget.tenant.name}"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      try {
        await _tenantService.deleteTenant(widget.tenant.id);
        _showSuccessMessage('租户删除成功');
        Navigator.pop(context, true); // 返回并刷新列表
      } catch (e) {
        _showErrorMessage('删除失败');
      } finally {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = widget.tenant.id.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: Text(
          isCreating ? '新增租户' : _isEditing ? '编辑租户' : '租户详情',
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (!isCreating)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: const Color(0xFF00BCD4),
              ),
              onPressed: () {
                setState(() => _isEditing = !_isEditing);
                if (!_isEditing) {
                  // 取消编辑时恢复原始数据
                  _initializeControllers();
                }
              },
            ),
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _saveTenant,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
                      ),
                    )
                  : const Text(
                      '保存',
                      style: TextStyle(
                        color: Color(0xFF00BCD4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          if (!_isEditing && !isCreating)
            _isDeleting
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFFF6B6B)),
                    onPressed: _deleteTenant,
                  ),
        ],
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('基本信息'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: '租户名称',
                      hint: '请输入租户名称',
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入租户名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: '地址',
                      hint: '请输入详细地址',
                      enabled: _isEditing,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入地址';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: '备注',
                      hint: '请输入备注信息（可选）',
                      enabled: _isEditing,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 32),
                    _buildSectionTitle('联系人信息'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _contactNameController,
                      label: '联系人姓名',
                      hint: '请输入联系人姓名',
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入联系人姓名';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _contactPhoneController,
                      label: '联系电话',
                      hint: '请输入联系电话',
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入联系电话';
                        }
                        final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
                        if (!phoneRegex.hasMatch(value.trim())) {
                          return '请输入有效的手机号码';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _contactEmailController,
                      label: '联系邮箱',
                      hint: '请输入联系邮箱',
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入联系邮箱';
                        }
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return '请输入有效的邮箱地址';
                        }
                        return null;
                      },
                    ),

                    if (isCreating) ...[
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _isLoading ? null : _saveTenant,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('创建租户'),
                      ),
                    ],

                    if (!isCreating && !_isEditing) ...[
                      const SizedBox(height: 32),
                      _buildInfoCard('创建时间', _formatDate(widget.tenant.createdAt)),
                      const SizedBox(height: 8),
                      _buildInfoCard('更新时间', _formatDate(widget.tenant.updatedAt)),
                    ],
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
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: !enabled,
        fillColor: enabled ? Colors.white : const Color(0xFFF3F4F6),
      ),
      validator: enabled ? validator : null,
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E8ED)),
      ),
      child: Row(
        children: [
          Text(
            '$label：',
            style: const TextStyle(
              color: Color(0xFF657786),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}