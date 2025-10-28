class MonthlyPieceSummary {
  final String employeeId;
  final String employeeName;
  final String employeeType;
  final int year;
  final int month;
  final int totalDays; // 当月天数
  final int workedDays; // 工作天数
  final int totalPieces; // 总件数
  final double totalAmount; // 总金额
  final Map<String, DailyWorkSummary> workTypeDetails; // 按工作类型分组的详情

  const MonthlyPieceSummary({
    required this.employeeId,
    required this.employeeName,
    required this.employeeType,
    required this.year,
    required this.month,
    required this.totalDays,
    required this.workedDays,
    required this.totalPieces,
    required this.totalAmount,
    required this.workTypeDetails,
  });

  // 获取月度显示文本
  String get monthDisplay => '$year年${month.toString().padLeft(2, '0')}月';

  // 获取平均日工资
  double get averageDailyAmount => workedDays > 0 ? totalAmount / workedDays : 0;

  // 获取平均日件数
  double get averageDailyPieces => workedDays > 0 ? totalPieces / workedDays : 0;

  // 获取效率评级
  String get efficiencyRating {
    final avgPieces = averageDailyPieces;
    if (avgPieces >= 100) return '超级高效';
    if (avgPieces >= 80) return '高效';
    if (avgPieces >= 60) return '正常';
    if (avgPieces >= 40) return '一般';
    return '需要提升';
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
    return 'MonthlyPieceSummary(employee: $employeeName, month: $monthDisplay, totalAmount: ¥$totalAmount, totalPieces: $totalPieces)';
  }
}

class DailyWorkSummary {
  final String workType;
  final int totalPieces;
  final double totalAmount;
  final int days; // 从事该工作的天数

  const DailyWorkSummary({
    required this.workType,
    required this.totalPieces,
    required this.totalAmount,
    required this.days,
  });

  // 获取平均每天件数
  double get averageDailyPieces => days > 0 ? totalPieces / days : 0;

  // 获取平均每天金额
  double get averageDailyAmount => days > 0 ? totalAmount / days : 0;
}