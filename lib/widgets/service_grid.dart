import 'package:flutter/material.dart';

/// 服务项目数据模型
class ServiceItem {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ServiceItem({
    required this.name,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

/// 服务宫格组件
class ServiceGrid extends StatelessWidget {
  final List<ServiceItem> services;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const ServiceGrid({
    super.key,
    required this.services,
    this.crossAxisCount = 4,
    this.crossAxisSpacing = 6.0,
    this.mainAxisSpacing = 6.0,
    this.childAspectRatio = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _ServiceItemWidget(service: service);
      },
    );
  }
}

/// 单个服务项目组件
class _ServiceItemWidget extends StatelessWidget {
  final ServiceItem service;

  const _ServiceItemWidget({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: service.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: service.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              service.icon,
              size: 28,
              color: service.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.name,
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
    );
  }
}