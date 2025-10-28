import 'package:flutter/material.dart';
import 'package:xintai_flutter/service/auth_service.dart';
import 'package:xintai_flutter/service/tenant_state_service.dart';
import 'package:xintai_flutter/widgets/service_grid.dart';
import 'package:xintai_flutter/widgets/message_dialog.dart';

import 'customer/customer_list_screen.dart';
import 'employee/employee_list_screen.dart';
import 'salary/salary_list_screen.dart';
import 'tenant_list_screen.dart';
import 'piece_work/piece_work_main_screen.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            // 用户头像
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),

            // 租户信息
            Expanded(
              child: PopupMenuButton<String>(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _tenantStateService.currentTenantName,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                onSelected: (value) async {
                  if (value == 'switch_tenant') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TenantListScreen(),
                      ),
                    );
                  } else if (value == 'logout') {
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
                        context.showInfo('已退出登录');
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'switch_tenant',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz, size: 18),
                        SizedBox(width: 8),
                        Text('切换租户'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 8),
                        Text('退出登录'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 主要内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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


  // 构建服务项目网格
  Widget _buildServiceGrid() {
    final services = [
      ServiceItem(
        name: '员工管理',
        icon: Icons.people,
        color: const Color(0xFF4CAF50),
        onTap: () => _handleServiceTap('员工管理'),
      ),
      ServiceItem(
        name: '客户管理',
        icon: Icons.business,
        color: const Color(0xFF2196F3),
        onTap: () => _handleServiceTap('客户管理'),
      ),
      ServiceItem(
        name: '薪资管理',
        icon: Icons.account_balance_wallet,
        color: const Color(0xFFFF9800),
        onTap: () => _handleServiceTap('薪资管理'),
      ),
      ServiceItem(
        name: '计件工资',
        icon: Icons.work_outline,
        color: const Color(0xFF10B981),
        onTap: () => _handleServiceTap('计件工资'),
      ),
      ServiceItem(
        name: '项目管理',
        icon: Icons.assignment,
        color: const Color(0xFF00BCD4),
        onTap: () => _handleServiceTap('项目管理'),
      ),
      ServiceItem(
        name: '财务管理',
        icon: Icons.attach_money,
        color: const Color(0xFF607D8B),
        onTap: () => _handleServiceTap('财务管理'),
      ),
      ServiceItem(
        name: '库存管理',
        icon: Icons.inventory,
        color: const Color(0xFF795548),
        onTap: () => _handleServiceTap('库存管理'),
      ),
      ServiceItem(
        name: '报表分析',
        icon: Icons.bar_chart,
        color: const Color(0xFF3F51B5),
        onTap: () => _handleServiceTap('报表分析'),
      ),
    ];

    return ServiceGrid(
      services: services,
      crossAxisCount: 4,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: 0.8,
    );
  }

  // 处理服务点击
  void _handleServiceTap(String serviceName) {
    if (!_tenantStateService.hasCurrentTenant) {
      context.showError('请先选择一个租户');
      return;
    }

    switch (serviceName) {
      case '员工管理':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
        );
        break;
      case '客户管理':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CustomerListScreen()),
        );
        break;
      case '薪资管理':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SalaryListScreen()),
        );
        break;
      case '计件工资':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PieceWorkMainScreen()),
        );
        break;
      default:
        context.showInfo('$serviceName功能开发中');
        break;
    }
  }
}
