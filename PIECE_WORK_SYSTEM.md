# 员工计件工资管理系统

## 系统概述

这是一个完整的员工计件工资管理系统，支持不同工种的计件工资计算、月度统计和数据可视化。

## 功能特性

### 📊 数据管理
- **计件单价设置**: 支持为不同员工类型和工作类型设置单价
- **每日记录录入**: 记录员工每天完成的工作件数和质量评分
- **自动金额计算**: 根据件数和单价自动计算总金额

### 👥 员工类型支持
- 包装工
- 烫衣工
- 缝纫工
- 裁剪工
- 质检员
- 一般工人
- 其他

### 📈 统计分析
- **月度汇总**: 按月统计总工资、总件数、工作天数
- **效率评级**: 超级高效、高效、正常、一般、需要提升
- **质量跟踪**: 支持0-100分质量评分系统
- **多维度分析**: 按员工、工作类型等维度分析数据

### 🎨 用户界面
- **现代化设计**: 扁平化设计风格，Material Design规范
- **响应式布局**: 适配不同屏幕尺寸
- **直观操作**: 简单易用的操作流程

## 技术架构

### 📱 前端 (Flutter)
- **状态管理**: StatefulWidget
- **UI框架**: Material Design
- **导航**: Navigator 2.0
- **国际化**: 支持

### 🗄️ 后端 (Supabase)
- **数据库**: PostgreSQL
- **认证**: Supabase Auth
- **实时**: Supabase Realtime
- **存储**: Supabase Storage

### 📋 数据模型

#### PieceWorkRate (计件单价)
- `id`: 唯一标识
- `tenant_id`: 租户ID
- `employee_type`: 员工类型
- `work_type`: 工作类型
- `unit_price`: 单价
- `is_active`: 是否激活

#### DailyPieceRecord (每日记录)
- `id`: 唯一标识
- `employee_id`: 员工ID
- `work_date`: 工作日期
- `work_type`: 工作类型
- `piece_count`: 完成件数
- `unit_price`: 当天单价
- `quality_score`: 质量评分
- `notes`: 备注

#### MonthlyPieceSummary (月度汇总)
- `employee_id`: 员工ID
- `employee_name`: 员工姓名
- `total_pieces`: 总件数
- `total_amount`: 总金额
- `worked_days`: 工作天数
- `work_type_details`: 工作类型详情

## 页面结构

### 📱 主要页面
1. **计件工资主页** (`PieceWorkMainScreen`)
   - 功能选择入口
   - 使用说明

2. **计件录入页** (`PieceWorkEntryScreen`)
   - 选择员工和工作类型
   - 输入件数和质量评分
   - 自动计算金额

3. **月度视图页** (`PieceWorkMonthlyViewScreen`)
   - 月份选择
   - 员工排名
   - 统计图表
   - 详细信息

### 🔧 服务层
- **EmployeeService**: 员工管理
- **PieceWorkService**: 计件工资业务逻辑
- **TenantStateService**: 租户状态管理

### 🎨 组件库
- **MessageDialog**: 统一消息提示组件
- **ServiceGrid**: 服务网格组件
- **通用表单组件**: 输入框、下拉框等

## 数据库设计

### 表结构

#### piece_work_rates (计件单价表)
```sql
CREATE TABLE piece_work_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(id),
    employee_type VARCHAR(50) NOT NULL,
    work_type VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(tenant_id, employee_type, work_type)
);
```

#### daily_piece_records (每日计件记录表)
```sql
CREATE TABLE daily_piece_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(id),
    employee_id UUID NOT NULL REFERENCES employees(id),
    work_date DATE NOT NULL,
    work_type VARCHAR(100) NOT NULL,
    piece_count INTEGER NOT NULL DEFAULT 0,
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) GENERATED ALWAYS AS (piece_count * unit_price) STORED,
    quality_score INTEGER DEFAULT 100,
    notes TEXT,
    recorded_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(tenant_id, employee_id, work_date, work_type)
);
```

## 安装和配置

### 1. 安装依赖
```bash
flutter pub get
```

### 2. 数据库迁移
```sql
-- 运行已创建的迁移脚本
```

### 3. 配置环境变量
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 使用指南

### 1. 设置计件单价
1. 进入计件工资管理
2. 为不同工种设置单价
3. 启用相应的计件标准

### 2. 录入每日数据
1. 选择日期和员工
2. 选择工作类型
3. 输入完成件数
4. 设置质量评分
5. 添加备注（可选）
6. 保存记录

### 3. 查看月度统计
1. 选择查看月份
2. 查看员工排名
3. 分析工作效率
4. 查看详细报表

## 安全性

- **租户隔离**: 每个租户只能访问自己的数据
- **RLS策略**: 行级安全策略保护数据
- **用户认证**: 基于Supabase Auth的用户认证
- **数据验证**: 前后端双重数据验证

## 性能优化

- **索引优化**: 在关键字段上建立索引
- **分页加载**: 大数据量时使用分页
- **缓存策略**: 合理使用缓存提升性能
- **懒加载**: 按需加载数据

## 未来扩展

- [ ] 移动端优化
- [ ] 数据导出功能
- [ ] 高级报表分析
- [ ] 工资批量发放
- [ ] 绩效考核系统
- [ ] 通知推送功能

## 常见问题

### Q: 如何修改历史记录？
A: 在月度视图中点击员工卡片，查看详情后可以编辑或删除记录。

### Q: 质量评分如何影响工资？
A: 目前质量评分主要用于统计分析，未来可以扩展为影响工资系数。

### Q: 支持哪些工作类型？
A: 系统预设了常见的工作类型，也支持自定义工作类型。

---

**注意**: 本系统需要配合正确的租户配置和使用权限才能正常运行。