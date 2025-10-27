import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';
import 'tenant_state_service.dart';

class EmployeeService {
  static final EmployeeService _instance = EmployeeService._internal();
  factory EmployeeService() => _instance;
  EmployeeService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final TenantStateService _tenantService = TenantStateService.instance;

  /// 获取当前租户的所有员工
  Future<List<Employee>> getEmployees() async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      final response = await _supabase
          .from('employees')
          .select()
          .eq('tenant_id', _tenantService.currentTenantId!)
          .order('created_at', ascending: false);

      return (response as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => Employee.fromMap(json))
          .toList();
    } catch (e) {
      throw Exception('获取员工列表失败: $e');
    }
  }

  /// 根据ID获取员工信息
  Future<Employee> getEmployeeById(String id) async {
    try {
      final response = await _supabase
          .from('employees')
          .select()
          .eq('id', id)
          .single();

      return Employee.fromMap(response);
    } catch (e) {
      throw Exception('获取员工信息失败: $e');
    }
  }

  /// 创建新员工
  Future<Employee> createEmployee({
    required String name,
    String? gender,
    DateTime? birthDate,
    String? phone,
    String? email,
    String? employeeNumber,
    String? department,
    String? position,
    required DateTime hireDate,
    double? salary,
    String status = 'active',
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      // 检查员工编号是否已存在
      if (employeeNumber != null && employeeNumber.isNotEmpty) {
        final existing = await _supabase
            .from('employees')
            .select('id')
            .eq('employee_number', employeeNumber)
            .maybeSingle();

        if (existing != null && existing['id'] != null) {
          throw Exception('员工编号已存在');
        }
      }

      final employeeData = {
        'tenant_id': _tenantService.currentTenantId!,
        'name': name,
        'gender': gender,
        'birth_date': birthDate?.toIso8601String().split('T')[0],
        'phone': phone,
        'email': email,
        'employee_number': employeeNumber,
        'department': department,
        'position': position,
        'hire_date': hireDate.toIso8601String().split('T')[0],
        'salary': salary,
        'status': status,
        'address': address,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'created_by': _supabase.auth.currentUser?.id,
      };

      final response = await _supabase
          .from('employees')
          .insert(employeeData)
          .select()
          .single();

      return Employee.fromMap(response);
    } catch (e) {
      throw Exception('创建员工失败: $e');
    }
  }

  /// 更新员工信息
  Future<Employee> updateEmployee({
    required String id,
    String? name,
    String? gender,
    DateTime? birthDate,
    String? phone,
    String? email,
    String? employeeNumber,
    String? department,
    String? position,
    DateTime? hireDate,
    double? salary,
    String? status,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      // 检查员工编号是否已被其他员工使用
      if (employeeNumber != null && employeeNumber.isNotEmpty) {
        final existing = await _supabase
            .from('employees')
            .select('id')
            .eq('employee_number', employeeNumber)
            .neq('id', id)
            .maybeSingle();

        if (existing != null && existing['id'] != null) {
          throw Exception('员工编号已被其他员工使用');
        }
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (gender != null) updateData['gender'] = gender;
      if (birthDate != null) updateData['birth_date'] = birthDate.toIso8601String().split('T')[0];
      if (phone != null) updateData['phone'] = phone;
      if (email != null) updateData['email'] = email;
      if (employeeNumber != null) updateData['employee_number'] = employeeNumber;
      if (department != null) updateData['department'] = department;
      if (position != null) updateData['position'] = position;
      if (hireDate != null) updateData['hire_date'] = hireDate.toIso8601String().split('T')[0];
      if (salary != null) updateData['salary'] = salary;
      if (status != null) updateData['status'] = status;
      if (address != null) updateData['address'] = address;
      if (emergencyContactName != null) updateData['emergency_contact_name'] = emergencyContactName;
      if (emergencyContactPhone != null) updateData['emergency_contact_phone'] = emergencyContactPhone;

      final response = await _supabase
          .from('employees')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return Employee.fromMap(response);
    } catch (e) {
      throw Exception('更新员工信息失败: $e');
    }
  }

  /// 删除员工
  Future<void> deleteEmployee(String id) async {
    try {
      await _supabase
          .from('employees')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('删除员工失败: $e');
    }
  }

  /// 搜索员工
  Future<List<Employee>> searchEmployees(String query) async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      if (query.trim().isEmpty) {
        return getEmployees();
      }

      final response = await _supabase
          .from('employees')
          .select()
          .eq('tenant_id', _tenantService.currentTenantId!)
          .or('name.ilike.%$query%,employee_number.ilike.%$query%,phone.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => Employee.fromMap(json))
          .toList();
    } catch (e) {
      throw Exception('搜索员工失败: $e');
    }
  }

  /// 根据部门筛选员工
  Future<List<Employee>> getEmployeesByDepartment(String department) async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      final response = await _supabase
          .from('employees')
          .select()
          .eq('tenant_id', _tenantService.currentTenantId!)
          .eq('department', department)
          .order('created_at', ascending: false);

      return (response as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => Employee.fromMap(json))
          .toList();
    } catch (e) {
      throw Exception('获取部门员工失败: $e');
    }
  }

  /// 根据状态筛选员工
  Future<List<Employee>> getEmployeesByStatus(String status) async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      final response = await _supabase
          .from('employees')
          .select()
          .eq('tenant_id', _tenantService.currentTenantId!)
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => Employee.fromMap(json))
          .toList();
    } catch (e) {
      throw Exception('获取指定状态员工失败: $e');
    }
  }

  /// 获取员工统计信息
  Future<Map<String, int>> getEmployeeStats() async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      final response = await _supabase
          .from('employees')
          .select('status')
          .eq('tenant_id', _tenantService.currentTenantId!);

      final stats = <String, int>{
        'active': 0,
        'inactive': 0,
        'resigned': 0,
        'total': 0,
      };

      for (final employee in response as List) {
        if (employee is Map<String, dynamic>) {
          final status = employee['status'] as String? ?? 'active';
          stats[status] = (stats[status] ?? 0) + 1;
          stats['total'] = (stats['total'] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('获取员工统计信息失败: $e');
    }
  }
}