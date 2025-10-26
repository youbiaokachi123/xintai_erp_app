import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 获取当前用户
  User? get currentUser => _supabase.auth.currentUser;

  // 监听认证状态变化
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // 注册新用户
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // 登录
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 登出
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 发送密码重置邮件
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // 检查用户是否已登录
  bool isLoggedIn() {
    return currentUser != null;
  }
}
