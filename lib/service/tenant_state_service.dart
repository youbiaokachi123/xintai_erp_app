import 'package:flutter/material.dart';
import '../models/tenant.dart';

class TenantStateService extends ChangeNotifier {
  static TenantStateService? _instance;

  // 单例模式
  static TenantStateService get instance {
    _instance ??= TenantStateService._();
    return _instance!;
  }

  TenantStateService._();

  Tenant? _currentTenant;

  // 获取当前租户
  Tenant? get currentTenant => _currentTenant;

  // 设置当前租户
  void setCurrentTenant(Tenant tenant) {
    _currentTenant = tenant;
    notifyListeners();
  }

  // 清除当前租户
  void clearCurrentTenant() {
    _currentTenant = null;
    notifyListeners();
  }

  // 检查是否有当前租户
  bool get hasCurrentTenant => _currentTenant != null;

  // 获取当前租户ID
  String? get currentTenantId => _currentTenant?.id;

  // 获取当前租户名称
  String get currentTenantName => _currentTenant?.name ?? '未选择租户';
}