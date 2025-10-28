class PieceWorkRate {
  final String id;
  final String tenantId;
  final String employeeType;
  final String workType;
  final double unitPrice;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PieceWorkRate({
    required this.id,
    required this.tenantId,
    required this.employeeType,
    required this.workType,
    required this.unitPrice,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从数据库记录创建对象
  factory PieceWorkRate.fromMap(Map<String, dynamic> map) {
    return PieceWorkRate(
      id: map['id'] as String,
      tenantId: map['tenant_id'] as String,
      employeeType: map['employee_type'] as String,
      workType: map['work_type'] as String,
      unitPrice: double.parse(map['unit_price'].toString()),
      description: map['description'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // 转换为数据库记录
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'employee_type': employeeType,
      'work_type': workType,
      'unit_price': unitPrice,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 创建新记录的Map（用于插入）
  Map<String, dynamic> toInsertMap() {
    return {
      'tenant_id': tenantId,
      'employee_type': employeeType,
      'work_type': workType,
      'unit_price': unitPrice,
      'description': description,
      'is_active': isActive,
    };
  }

  // 复制并修改部分属性
  PieceWorkRate copyWith({
    String? id,
    String? tenantId,
    String? employeeType,
    String? workType,
    double? unitPrice,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PieceWorkRate(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      employeeType: employeeType ?? this.employeeType,
      workType: workType ?? this.workType,
      unitPrice: unitPrice ?? this.unitPrice,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 获取员工类型显示文本
  String get employeeTypeDisplay {
    switch (employeeType) {
      case 'general':
        return '一般工人';
      case 'packager':
        return '包装工';
      case 'ironer':
        return '烫衣工';
      case 'seamstress':
        return '缝纫工';
      case 'cutter':
        return '裁剪工';
      case 'quality_inspector':
        return '质检员';
      case 'other':
        return '其他';
      default:
        return '一般工人';
    }
  }

  @override
  String toString() {
    return 'PieceWorkRate(id: $id, employeeType: $employeeType, workType: $workType, unitPrice: ¥$unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PieceWorkRate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}