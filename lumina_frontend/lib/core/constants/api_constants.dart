class ApiConstants {
  const ApiConstants._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://lumina-058e.onrender.com',
  );

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const login = '/auth/login';
  static const signup = '/auth/signup';
  static const logout = '/auth/logout';
  static const verifyOtp = '/auth/signup/verify-otp';
  static const resendOtp = '/auth/signup/resend-otp';
  static const refreshToken = '/auth/refresh-token';
  static const forgotPassword = '/auth/forgot-password';
  static const resendForgotPasswordOtp = '/auth/forgot-password/resend-otp';
  static const resetPassword = '/auth/reset-password';
  // Session restore — uses the user profile endpoint
  static const me = '/users/profile';

  // ── Articles ─────────────────────────────────────────────────────────────
  static const articles = '/articles';
  static const articlesPreferences = '/articles/preferences';
  static const articlesByCategory = '/articles/category';
  static const myArticles = '/articles/me';

  // ── Categories ────────────────────────────────────────────────────────────
  static const categories = '/categories';

  // ── Preferences ───────────────────────────────────────────────────────────
  static const preferences = '/preferences';
  static const preferencesStatus = '/preferences/status';

  // ── Users / Profile ───────────────────────────────────────────────────────
  static const profile = '/users/profile';
  static const changePassword = '/users/change-password';

  // ── Uploads ───────────────────────────────────────────────────────────────
  static const presignedUploads = '/uploads/presigned-url';

  // ── Reactions ─────────────────────────────────────────────────────────────
  static const reactArticle = '/reactions/articles/react';
  static const blockArticle = '/reactions/articles/block';
}
