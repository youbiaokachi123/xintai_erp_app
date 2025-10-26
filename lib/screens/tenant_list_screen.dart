import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../service/tenant_service.dart';
import 'tenant_detail_screen.dart';

class TenantListScreen extends StatefulWidget {
  const TenantListScreen({super.key});

  @override
  State<TenantListScreen> createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen> {
  final TenantService _tenantService = TenantService();
  final TextEditingController _searchController = TextEditingController();
  List<Tenant> _tenants = [];
  List<Tenant> _filteredTenants = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTenants();
    _searchController.addListener(_filterTenants);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTenants);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTenants() async {
    setState(() => _isLoading = true);
    try {
      final tenants = await _tenantService.getUserTenants();
      setState(() {
        _tenants = tenants;
        _filteredTenants = tenants;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorMessage('加载租户列表失败');
      }
    }
  }

  void _filterTenants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTenants = _tenants;
      } else {
        _filteredTenants = _tenants.where((tenant) {
          return tenant.name.toLowerCase().contains(query) ||
              tenant.address.toLowerCase().contains(query) ||
              tenant.contactName.toLowerCase().contains(query);
        }).toList();
      }
    });
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

  void _navigateToDetail(Tenant tenant) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TenantDetailScreen(tenant: tenant),
      ),
    );

    if (result == true) {
      _loadTenants(); // 刷新列表
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          '租户管理',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF00BCD4)),
            onPressed: () => _navigateToDetail(Tenant(
              id: '',
              name: '',
              address: '',
              contactName: '',
              contactPhone: '',
              contactEmail: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextField(
          //     controller: _searchController,
          //     decoration: const InputDecoration(
          //       labelText: '搜索租户',
          //       hintText: '请输入租户名称或地址',
          //       prefixIcon: Icon(Icons.search),
          //       suffixIcon: Icon(Icons.clear),
          //     ),
          //   ),
          // ),

          // 租户列表
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredTenants.isEmpty
                    ? _buildEmptyState()
                    : _buildTenantList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isEmpty
                ? Icons.business
                : Icons.search_off,
            size: 64,
            color: const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? '暂无租户数据'
                : '未找到匹配的租户',
            style: const TextStyle(
              color: Color(0xFF657786),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchController.text.isEmpty)
            Text(
              '点击右上角 + 按钮添加第一个租户',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTenantList() {
    return RefreshIndicator(
      onRefresh: _loadTenants,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredTenants.length,
        itemBuilder: (context, index) {
          final tenant = _filteredTenants[index];
          return _buildTenantCard(tenant);
        },
      ),
    );
  }

  Widget _buildTenantCard(Tenant tenant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFE1E8ED),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetail(tenant),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tenant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tenant.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF657786),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tenant.contactName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF657786),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tenant.contactPhone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF657786),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tenant.contactEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}