import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tenant.dart';

class TenantService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 获取当前用户的所有租户
  Future<List<Tenant>> getUserTenants() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      final response = await _supabase
          .from('tenant')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<Tenant> tenants = (response as List)
          .map((json) => Tenant.fromJson(json))
          .toList();

      return tenants;
    } catch (e) {
      throw Exception('获取租户列表失败: $e');
    }
  }

  // 根据ID获取单个租户
  Future<Tenant> getTenantById(String tenantId) async {
    try {
      final response = await _supabase
          .from('tenant')
          .select()
          .eq('id', tenantId)
          .single();

      return Tenant.fromJson(response);
    } catch (e) {
      throw Exception('获取租户信息失败: $e');
    }
  }

  // 创建新租户
  Future<Tenant> createTenant({
    required String name,
    required String address,
    required String contactName,
    required String contactPhone,
    required String contactEmail,
    String description = '',
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      final now = DateTime.now();
      final response = await _supabase.from('tenant').insert({
        'name': name,
        'address': address,
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'contact_email': contactEmail,
        'description': description,
        'user_id': userId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      }).select().single();

      return Tenant.fromJson(response);
    } catch (e) {
      throw Exception('创建租户失败: $e');
    }
  }

  // 更新租户信息
  Future<Tenant> updateTenant({
    required String tenantId,
    String? name,
    String? address,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? description,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (address != null) updateData['address'] = address;
      if (contactName != null) updateData['contact_name'] = contactName;
      if (contactPhone != null) updateData['contact_phone'] = contactPhone;
      if (contactEmail != null) updateData['contact_email'] = contactEmail;
      if (description != null) updateData['description'] = description;

      final response = await _supabase
          .from('tenant')
          .update(updateData)
          .eq('id', tenantId)
          .select()
          .single();

      return Tenant.fromJson(response);
    } catch (e) {
      throw Exception('更新租户失败: $e');
    }
  }

  // 删除租户
  Future<void> deleteTenant(String tenantId) async {
    try {
      await _supabase.from('tenant').delete().eq('id', tenantId);
    } catch (e) {
      throw Exception('删除租户失败: $e');
    }
  }

  // 搜索租户
  Future<List<Tenant>> searchTenants(String query) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      final response = await _supabase
          .from('tenant')
          .select()
          .eq('user_id', userId)
          .or('name.ilike.%$query%,address.ilike.%$query%,contact_name.ilike.%$query%')
          .order('created_at', ascending: false);

      final List<Tenant> tenants = (response as List)
          .map((json) => Tenant.fromJson(json))
          .toList();

      return tenants;
    } catch (e) {
      throw Exception('搜索租户失败: $e');
    }
  }
}