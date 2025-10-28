import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/piece_work_rate.dart';
import '../models/daily_piece_record.dart';
import '../models/monthly_piece_summary.dart';
import '../models/employee.dart';
import 'tenant_state_service.dart';

class PieceWorkService {
  static final PieceWorkService _instance = PieceWorkService._internal();
  factory PieceWorkService() => _instance;
  PieceWorkService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final TenantStateService _tenantService = TenantStateService.instance;

  /// 获取当前租户的所有计件单价设置
  Future<List<PieceWorkRate>> getPieceWorkRates() async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      final response = await _supabase
          .from('piece_work_rates')
          .select()
          .eq('tenant_id', _tenantService.currentTenantId!)
          .eq('is_active', true)
          .order('employee_type', ascending: true);

      return (response as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => PieceWorkRate.fromMap(json))
          .toList();
    } catch (e) {
      throw Exception('获取计件单价设置失败: $e');
    }
  }

  /// 根据员工类型和工作类型获取单价
  Future<PieceWorkRate?> getPieceWorkRate(String employeeType, String workType) async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      final response = await _supabase
          .from('piece_work_rates')
          .select()
          .eq('tenant_id', _tenantService.currentTenantId!)
          .eq('employee_type', employeeType)
          .eq('work_type', workType)
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        return PieceWorkRate.fromMap(response as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('获取计件单价失败: $e');
    }
  }

  /// 创建或更新计件单价设置
  Future<PieceWorkRate> upsertPieceWorkRate({
    required String employeeType,
    required String workType,
    required double unitPrice,
    String? description,
  }) async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      final rateData = {
        'tenant_id': _tenantService.currentTenantId!,
        'employee_type': employeeType,
        'work_type': workType,
        'unit_price': unitPrice,
        'description': description,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 检查是否已存在相同的设置
      final existing = await getPieceWorkRate(employeeType, workType);

      if (existing != null) {
        // 更新现有记录
        final response = await _supabase
            .from('piece_work_rates')
            .update(rateData)
            .eq('id', existing.id)
            .select()
            .single();

        return PieceWorkRate.fromMap(response as Map<String, dynamic>);
      } else {
        // 创建新记录
        rateData['created_at'] = DateTime.now().toIso8601String();

        final response = await _supabase
            .from('piece_work_rates')
            .insert(rateData)
            .select()
            .single();

        return PieceWorkRate.fromMap(response as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('保存计件单价失败: $e');
    }
  }

  /// 删除计件单价设置（软删除，设置为不活跃）
  Future<void> deletePieceWorkRate(String rateId) async {
    try {
      await _supabase
          .from('piece_work_rates')
          .update({'is_active': false})
          .eq('id', rateId);
    } catch (e) {
      throw Exception('删除计件单价失败: $e');
    }
  }

  /// 获取员工的每日计件记录
  Future<List<DailyPieceRecord>> getDailyPieceRecords({
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      var query = _supabase
          .from('daily_piece_records')
          .select()
          .eq('tenant_id', _tenantService.currentTenantId!);

      if (employeeId != null) {
        query = query.eq('employee_id', employeeId);
      }

      if (startDate != null) {
        query = query.gte('work_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('work_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('work_date', ascending: false);

      return (response as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => DailyPieceRecord.fromMap(json))
          .toList();
    } catch (e) {
      throw Exception('获取计件记录失败: $e');
    }
  }

  /// 创建或更新每日计件记录
  Future<DailyPieceRecord> upsertDailyPieceRecord({
    required String employeeId,
    required DateTime workDate,
    required String workType,
    required int pieceCount,
    required double unitPrice,
    String? notes,
  }) async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      final recordData = {
        'tenant_id': _tenantService.currentTenantId!,
        'employee_id': employeeId,
        'work_date': workDate.toIso8601String().split('T')[0],
        'work_type': workType,
        'piece_count': pieceCount,
        'unit_price': unitPrice,
        'notes': notes,
        'recorded_by': _supabase.auth.currentUser?.id,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 检查是否已存在相同的记录
      final existing = await _supabase
          .from('daily_piece_records')
          .select()
          .eq('tenant_id', _tenantService.currentTenantId!)
          .eq('employee_id', employeeId)
          .eq('work_date', workDate.toIso8601String().split('T')[0])
          .eq('work_type', workType)
          .maybeSingle();

      if (existing != null) {
        // 更新现有记录
        final response = await _supabase
            .from('daily_piece_records')
            .update(recordData)
            .eq('id', existing['id'])
            .select()
            .single();

        return DailyPieceRecord.fromMap(response as Map<String, dynamic>);
      } else {
        // 创建新记录
        recordData['created_at'] = DateTime.now().toIso8601String();

        final response = await _supabase
            .from('daily_piece_records')
            .insert(recordData)
            .select()
            .single();

        return DailyPieceRecord.fromMap(response as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('保存计件记录失败: $e');
    }
  }

  /// 删除每日计件记录
  Future<void> deleteDailyPieceRecord(String recordId) async {
    try {
      await _supabase
          .from('daily_piece_records')
          .delete()
          .eq('id', recordId);
    } catch (e) {
      throw Exception('删除计件记录失败: $e');
    }
  }

  /// 获取员工月度统计
  Future<List<MonthlyPieceSummary>> getMonthlySummaries(int year, int month) async {
    try {
      if (!_tenantService.hasCurrentTenant) {
        throw Exception('请先选择租户');
      }

      // 获取该月所有计件记录
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0); // 当月最后一天

      final records = await getDailyPieceRecords(
        startDate: startDate,
        endDate: endDate,
      );

      // 按员工分组统计
      final Map<String, List<DailyPieceRecord>> employeeRecords = {};
      for (final record in records) {
        employeeRecords.putIfAbsent(record.employeeId, () => []).add(record);
      }

      // 获取员工信息
      final employeeIds = employeeRecords.keys.toList();
      final employeesResponse = await _supabase
          .from('employees')
          .select()
          .eq('tenant_id', _tenantService.currentTenantId!)
          .inFilter('id', employeeIds);

      final Map<String, Employee> employees = {};
      for (final emp in employeesResponse) {
        employees[emp['id'] as String] = Employee.fromMap(emp as Map<String, dynamic>);
      }

      // 生成月度总结
      final List<MonthlyPieceSummary> summaries = [];
      final totalDaysInMonth = endDate.day;

      for (final entry in employeeRecords.entries) {
        final employeeId = entry.key;
        final employeeRecords = entry.value;
        final employee = employees[employeeId];

        if (employee == null) continue;

        // 计算统计数据
        final workedDays = employeeRecords.map((r) => r.workDate).toSet().length;
        final totalPieces = employeeRecords.fold<int>(0, (sum, r) => sum + r.pieceCount);
        final totalAmount = employeeRecords.fold<double>(0, (sum, r) => sum + r.totalAmount);

        // 按工作类型分组
        final Map<String, List<DailyPieceRecord>> workTypeRecords = {};
        for (final record in employeeRecords) {
          workTypeRecords.putIfAbsent(record.workType, () => []).add(record);
        }

        final Map<String, DailyWorkSummary> workTypeDetails = {};
        for (final workTypeEntry in workTypeRecords.entries) {
          final workType = workTypeEntry.key;
          final records = workTypeEntry.value;

          final typeTotalPieces = records.fold<int>(0, (sum, r) => sum + r.pieceCount);
          final typeTotalAmount = records.fold<double>(0, (sum, r) => sum + r.totalAmount);
          final typeDays = records.length;

          workTypeDetails[workType] = DailyWorkSummary(
            workType: workType,
            totalPieces: typeTotalPieces,
            totalAmount: typeTotalAmount,
            days: typeDays,
          );
        }

        summaries.add(MonthlyPieceSummary(
          employeeId: employeeId,
          employeeName: employee.name,
          employeeType: employee.employeeType,
          year: year,
          month: month,
          totalDays: totalDaysInMonth,
          workedDays: workedDays,
          totalPieces: totalPieces,
          totalAmount: totalAmount,
          workTypeDetails: workTypeDetails,
        ));
      }

      // 按总金额排序
      summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      return summaries;
    } catch (e) {
      throw Exception('获取月度统计失败: $e');
    }
  }
}