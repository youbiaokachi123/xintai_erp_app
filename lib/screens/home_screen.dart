import 'package:flutter/material.dart';
import 'package:xintai_flutter/service/auth_service.dart';
import 'package:xintai_flutter/service/tenant_state_service.dart';

import 'customer/customer_list_screen.dart';
import 'employee/employee_list_screen.dart';
import 'salary/salary_list_screen.dart';
import 'tenant_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final TenantStateService _tenantStateService = TenantStateService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      // 跳转到租户选择页面
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TenantListScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          _tenantStateService.currentTenantName,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: const Color(0xFF666666),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          // 通知功能
                        },
                        iconSize: 24,
                        color: const Color(0xFF666666),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('确认退出'),
                              content: const Text('您确定要退出登录吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('退出'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await _authService.signOut();
                            _tenantStateService.clearCurrentTenant();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已退出登录')),
                              );
                            }
                          }
                        },
                        iconSize: 24,
                        color: const Color(0xFF666666),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 主要内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 欢迎区域
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '您好',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '您正在使用 ${_tenantStateService.currentTenantName}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          if (!_tenantStateService.hasCurrentTenant) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '请先选择一个租户',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 一键服务按钮
                    _buildQuickServiceButtons(),

                    const SizedBox(height: 24),

                    // 服务项目标题
                    const Text(
                      '服务项目',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 服务项目网格
                    _buildServiceGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建一键服务按钮
  Widget _buildQuickServiceButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickServiceButton(
            '一键呼叫',
            Icons.call,
            const Color(0xFF4CAF50),
            () => _handleQuickService('呼叫'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickServiceButton(
            '一键报修',
            Icons.build,
            const Color(0xFFFF9800),
            () => _handleQuickService('报修'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickServiceButton(
            '一键报警',
            Icons.warning,
            const Color(0xFFF44336),
            () => _handleQuickService('报警'),
          ),
        ),
      ],
    );
  }

  // 构建单个一键服务按钮
  Widget _buildQuickServiceButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        if (!_tenantStateService.hasCurrentTenant) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请先选择一个租户'),
              backgroundColor: Color(0xFFFF6B6B),
            ),
          );
          return;
        }
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 构建服务项目网格
  Widget _buildServiceGrid() {
    final services = [
      {'name': '员工管理', 'icon': Icons.people, 'color': const Color(0xFF4CAF50)},
      {'name': '客户管理', 'icon': Icons.business, 'color': const Color(0xFF2196F3)},
      {'name': '薪资管理', 'icon': Icons.account_balance_wallet, 'color': const Color(0xFFFF9800)},
      {'name': '考勤管理', 'icon': Icons.schedule, 'color': const Color(0xFF9C27B0)},
      {'name': '项目管理', 'icon': Icons.assignment, 'color': const Color(0xFF00BCD4)},
      {'name': '财务管理', 'icon': Icons.attach_money, 'color': const Color(0xFF607D8B)},
      {'name': '库存管理', 'icon': Icons.inventory, 'color': const Color(0xFF795548)},
      {'name': '报表分析', 'icon': Icons.bar_chart, 'color': const Color(0xFF3F51B5)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceItem(
          service['name'] as String,
          service['icon'] as IconData,
          service['color'] as Color,
        );
      },
    );
  }

  // 构建单个服务项目
  Widget _buildServiceItem(String name, IconData icon, Color color) {
    return InkWell(
      onTap: () => _handleServiceTap(name),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 处理一键服务
  void _handleQuickService(String serviceType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$serviceType服务'),
        content: Text('您确认要使用$serviceType服务吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$serviceType服务已触发')),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  // 处理服务点击
  void _handleServiceTap(String serviceName) {
    if (!_tenantStateService.hasCurrentTenant) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先选择一个租户'),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
      return;
    }

    switch (serviceName) {
      case '员工管理':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmployeeListScreen(),
          ),
        );
        break;
      case '客户管理':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerListScreen(),
          ),
        );
        break;
      case '薪资管理':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SalaryListScreen(),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$serviceName功能开发中')),
        );
        break;
    }
  }

}