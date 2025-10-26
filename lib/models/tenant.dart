class Tenant {
  final String id;
  final String name;
  final String address;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tenant({
    required this.id,
    required this.name,
    required this.address,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // 从JSON创建对象
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      contactName: json['contact_name'] as String,
      contactPhone: json['contact_phone'] as String,
      contactEmail: json['contact_email'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // 创建副本（用于更新）
  Tenant copyWith({
    String? id,
    String? name,
    String? address,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Tenant(id: $id, name: $name, address: $address)';
  }
}