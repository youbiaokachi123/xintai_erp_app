class DailyPieceRecord {
  final String id;
  final String tenantId;
  final String employeeId;
  final DateTime workDate;
  final String workType;
  final int pieceCount;
  final double unitPrice;
  final double totalAmount;
  final String? notes;
  final String? recordedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyPieceRecord({
    required this.id,
    required this.tenantId,
    required this.employeeId,
    required this.workDate,
    required this.workType,
    required this.pieceCount,
    required this.unitPrice,
    required this.totalAmount,
    this.notes,
    this.recordedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从数据库记录创建对象
  factory DailyPieceRecord.fromMap(Map<String, dynamic> map) {
    return DailyPieceRecord(
      id: map['id'] as String,
      tenantId: map['tenant_id'] as String,
      employeeId: map['employee_id'] as String,
      workDate: DateTime.parse(map['work_date'] as String),
      workType: map['work_type'] as String,
      pieceCount: map['piece_count'] as int,
      unitPrice: double.parse(map['unit_price'].toString()),
      totalAmount: double.parse(map['total_amount'].toString()),
      notes: map['notes'] as String?,
      recordedBy: map['recorded_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // 转换为数据库记录
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'employee_id': employeeId,
      'work_date': workDate.toIso8601String().split('T')[0], // 只保留日期部分
      'work_type': workType,
      'piece_count': pieceCount,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'notes': notes,
      'recorded_by': recordedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 创建新记录的Map（用于插入）
  Map<String, dynamic> toInsertMap() {
    return {
      'tenant_id': tenantId,
      'employee_id': employeeId,
      'work_date': workDate.toIso8601String().split('T')[0],
      'work_type': workType,
      'piece_count': pieceCount,
      'unit_price': unitPrice,
      'notes': notes,
      'recorded_by': recordedBy,
    };
  }

  // 复制并修改部分属性
  DailyPieceRecord copyWith({
    String? id,
    String? tenantId,
    String? employeeId,
    DateTime? workDate,
    String? workType,
    int? pieceCount,
    double? unitPrice,
    double? totalAmount,
    String? notes,
    String? recordedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyPieceRecord(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      employeeId: employeeId ?? this.employeeId,
      workDate: workDate ?? this.workDate,
      workType: workType ?? this.workType,
      pieceCount: pieceCount ?? this.pieceCount,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      recordedBy: recordedBy ?? this.recordedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DailyPieceRecord(id: $id, workDate: $workDate, workType: $workType, pieceCount: $pieceCount, totalAmount: ¥$totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyPieceRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}