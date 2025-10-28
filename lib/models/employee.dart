class Employee {
  final String id;
  final String tenantId;
  final String name;
  final String? gender;
  final DateTime? birthDate;
  final String? phone;
  final String? email;
  final String? employeeNumber;
  final String? position;
  final String employeeType;
  final DateTime hireDate;
  final String status;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const Employee({
    required this.id,
    required this.tenantId,
    required this.name,
    this.gender,
    this.birthDate,
    this.phone,
    this.email,
    this.employeeNumber,
    this.position,
    this.employeeType = 'general',
    required this.hireDate,
    this.status = 'active',
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  // 从数据库记录创建员工对象
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as String,
      tenantId: map['tenant_id'] as String,
      name: map['name'] as String,
      gender: map['gender'] as String?,
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'] as String)
          : null,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      employeeNumber: map['employee_number'] as String?,
      position: map['position'] as String?,
      employeeType: map['employee_type'] as String? ?? 'general',
      hireDate: DateTime.parse(map['hire_date'] as String),
      status: map['status'] as String? ?? 'active',
      address: map['address'] as String?,
      emergencyContactName: map['emergency_contact_name'] as String?,
      emergencyContactPhone: map['emergency_contact_phone'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      createdBy: map['created_by'] as String?,
    );
  }

  // 转换为数据库记录
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String().split('T')[0], // 只保留日期部分
      'phone': phone,
      'email': email,
      'employee_number': employeeNumber,
      'position': position,
      'employee_type': employeeType,
      'hire_date': hireDate.toIso8601String().split('T')[0], // 只保留日期部分
      'status': status,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  // 创建新员工的Map（用于插入）
  Map<String, dynamic> toInsertMap() {
    return {
      'tenant_id': tenantId,
      'name': name,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'phone': phone,
      'email': email,
      'employee_number': employeeNumber,
      'position': position,
      'employee_type': employeeType,
      'hire_date': hireDate.toIso8601String().split('T')[0],
      'status': status,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
    };
  }

  // 复制并修改部分属性
  Employee copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? gender,
    DateTime? birthDate,
    String? phone,
    String? email,
    String? employeeNumber,
    String? position,
    String? employeeType,
    DateTime? hireDate,
    String? status,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Employee(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      position: position ?? this.position,
      employeeType: employeeType ?? this.employeeType,
      hireDate: hireDate ?? this.hireDate,
      status: status ?? this.status,
      address: address ?? this.address,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // 计算年龄
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // 获取工作年限
  int get workYears {
    final now = DateTime.now();
    int years = now.year - hireDate.year;
    if (now.month < hireDate.month ||
        (now.month == hireDate.month && now.day < hireDate.day)) {
      years--;
    }
    return years;
  }

  // 获取状态显示文本
  String get statusDisplay {
    switch (status) {
      case 'active':
        return '在职';
      case 'inactive':
        return '休假';
      case 'resigned':
        return '离职';
      default:
        return '未知';
    }
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
    return 'Employee(id: $id, name: $name, employeeNumber: $employeeNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}