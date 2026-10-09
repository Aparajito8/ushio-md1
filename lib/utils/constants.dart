// ============================================================================
// 应用常量配置
//
// 集中管理应用的所有常量，包括：
// - 应用信息
// - 颜色配置
// - 尺寸规范
// - 预设主题
// ============================================================================

import 'package:flutter/material.dart';

/// 夜间主题配色方案
///
/// 定义单个夜间主题的所有颜色属性
class DarkThemeScheme {
  final String name;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;

  const DarkThemeScheme({
    required this.name,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
  });
}

/// 浅色主题配色方案
///
/// 定义单个浅色主题的所有颜色属性
class LightThemeScheme {
  final String name;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;

  const LightThemeScheme({
    required this.name,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
  });
}

/// 字体选项
///
/// 定义可选字体的显示名称和字体族名称
class FontOption {
  final String name; // 显示名称（中文）
  final String fontFamily; // 字体族名称
  final bool needDownload; // 是否需要下载
  final String? downloadDesc; // 下载描述

  const FontOption({
    required this.name,
    required this.fontFamily,
    this.needDownload = false,
    this.downloadDesc,
  });
}

/// 代码块主题选项
///
/// 定义可选的代码块语法高亮主题
class CodeBlockThemeOption {
  final String name; // 显示名称（本地化键）
  final String themeId; // CodeMirror 主题 ID

  const CodeBlockThemeOption({required this.name, required this.themeId});
}

/// 应用常量
///
/// 使用静态常量确保全局一致性
class AppConstants {
  // ==================== 应用信息 ====================

  /// 应用名称
  static const String appName = '汐';

  /// 版本号
  static const String appVersion = '1.6.0';

  /// 应用描述
  static const String appDescription = 'Markdown 编辑器';

  /// 作者
  static const String appAuthor = 'jiuxina';

  /// GitHub 仓库地址
  static const String githubUrl = 'https://github.com/jiuxina/ushio-md';

  /// 包名 (Application ID)
  static const String packageName = 'com.ushiomd';

  // ==================== 主题色 ====================

  /// 主色调（靛蓝）
  static const Color primaryColor = Color(0xFF6366F1);

  /// 主色调深色变体
  static const Color primaryDark = Color(0xFF4F46E5);

  /// 强调色（青色）
  static const Color accentColor = Color(0xFF22D3EE);

  /// 错误色（红色）
  static const Color errorColor = Color(0xFFEF4444);

  /// 成功色（绿色）
  static const Color successColor = Color(0xFF22C55E);

  /// 警告色（琥珀色）
  static const Color warningColor = Color(0xFFF59E0B);

  // ==================== 浅色主题色 ====================

  /// 浅色背景
  static const Color lightBackground = Color(0xFFEFF1F5);

  /// 浅色表面
  static const Color lightSurface = Color(0xFFE6E9EF);

  /// 浅色主文字
  static const Color lightText = Color(0xFF4C4F69);

  /// 浅色次要文字
  static const Color lightTextSecondary = Color(0xFF6C6F85);

  // ==================== 深色主题色 ====================

  /// 深色背景
  static const Color darkBackground = Color(0xFF1E1E2E);

  /// 深色表面
  static const Color darkSurface = Color(0xFF313244);

  /// 深色主文字
  static const Color darkText = Color(0xFFCDD6F4);

  /// 深色次要文字
  static const Color darkTextSecondary = Color(0xFFA6ADC8);

  // ==================== 夜间主题方案 ====================

  /// 夜间主题配色方案定义
  ///
  /// 配色取自 Catppuccin、Rosé Pine、Nord、Tokyo Night、
  /// Dracula、Gruvbox 等开源配色方案。
  static const List<DarkThemeScheme> darkThemeSchemes = [
    // 1. Catppuccin Mocha
    // https://github.com/catppuccin/palette
    DarkThemeScheme(
      name: '摩卡夜色',
      background: Color(0xFF1E1E2E),
      surface: Color(0xFF313244),
      text: Color(0xFFCDD6F4),
      textSecondary: Color(0xFFA6ADC8),
    ),
    // 2. Rosé Pine
    // https://github.com/rose-pine/palette
    DarkThemeScheme(
      name: '松林暮色',
      background: Color(0xFF191724),
      surface: Color(0xFF26233A),
      text: Color(0xFFE0DEF4),
      textSecondary: Color(0xFF908CAA),
    ),
    // 3. Nord
    // https://github.com/nordtheme/nord
    DarkThemeScheme(
      name: '极地冰蓝',
      background: Color(0xFF2E3440),
      surface: Color(0xFF3B4252),
      text: Color(0xFFE5E9F0),
      textSecondary: Color(0xFF81A1C1),
    ),
    // 4. Tokyo Night
    // https://github.com/folke/tokyonight.nvim
    DarkThemeScheme(
      name: '东京夜蓝',
      background: Color(0xFF1A1B26),
      surface: Color(0xFF292E42),
      text: Color(0xFFC0CAF5),
      textSecondary: Color(0xFFA9B1D6),
    ),
    // 5. Dracula
    // https://github.com/dracula/dracula-theme
    DarkThemeScheme(
      name: '德古拉之夜',
      background: Color(0xFF282A36),
      surface: Color(0xFF44475A),
      text: Color(0xFFF8F8F2),
      textSecondary: Color(0xFFBD93F9),
    ),
    // 6. Gruvbox Dark
    // https://github.com/morhetz/gruvbox
    DarkThemeScheme(
      name: '复古炭灰',
      background: Color(0xFF282828),
      surface: Color(0xFF3C3836),
      text: Color(0xFFEBDBB2),
      textSecondary: Color(0xFFA89984),
    ),
  ];

  // ==================== 浅色主题方案 ====================

  /// 浅色主题配色方案定义
  ///
  /// 配色取自 Catppuccin、Rosé Pine、Tokyo Night、
  /// Gruvbox、Solarized 等开源配色方案。
  static const List<LightThemeScheme> lightThemeSchemes = [
    // 1. Catppuccin Latte
    // https://github.com/catppuccin/palette
    LightThemeScheme(
      name: '拿铁奶油',
      background: Color(0xFFEFF1F5),
      surface: Color(0xFFE6E9EF),
      text: Color(0xFF4C4F69),
      textSecondary: Color(0xFF6C6F85),
    ),
    // 2. Rosé Pine Dawn
    // https://github.com/rose-pine/palette
    LightThemeScheme(
      name: '松林晨光',
      background: Color(0xFFFAF4ED),
      surface: Color(0xFFFFFAF3),
      text: Color(0xFF464261),
      textSecondary: Color(0xFF797593),
    ),
    // 3. Tokyo Night Day
    // https://github.com/folke/tokyonight.nvim
    LightThemeScheme(
      name: '东京晨蓝',
      background: Color(0xFFE1E2E7),
      surface: Color(0xFFFFFFFF),
      text: Color(0xFF3760BF),
      textSecondary: Color(0xFF68709A),
    ),
    // 4. Gruvbox Light
    // https://github.com/morhetz/gruvbox
    LightThemeScheme(
      name: '复古暖纸',
      background: Color(0xFFFBF1C7),
      surface: Color(0xFFF2E5BC),
      text: Color(0xFF3C3836),
      textSecondary: Color(0xFF7C6F64),
    ),
    // 5. Solarized Light
    // https://github.com/altercation/solarized
    LightThemeScheme(
      name: '日光暖黄',
      background: Color(0xFFFDF6E3),
      surface: Color(0xFFEEE8D5),
      text: Color(0xFF073642),
      textSecondary: Color(0xFF586E75),
    ),
  ];

  // ==================== 可用字体 ====================

  /// 可选字体列表
  ///
  /// 第一个为系统默认，其余使用 Google Fonts（需要下载）
  static const List<FontOption> availableFonts = [
    FontOption(name: '系统默认', fontFamily: 'System'),
    FontOption(
      name: '思源黑体',
      fontFamily: 'Noto Sans SC',
      needDownload: true,
      downloadDesc: 'Google 出品的中文字体，适合正文阅读（约 10MB）',
    ),
    FontOption(
      name: 'JetBrains Mono',
      fontFamily: 'JetBrains Mono',
      needDownload: true,
      downloadDesc: 'JetBrains 出品的编程字体，适合代码块（约 0.2MB）',
    ),
  ];

  // ==================== 代码块主题 ====================

  /// 代码块语法高亮主题列表
  ///
  /// 第一个为跟随应用主题，其余为固定主题
  static const List<CodeBlockThemeOption> codeBlockThemes = [
    CodeBlockThemeOption(name: 'codeBlockThemeAuto', themeId: 'auto'),
    CodeBlockThemeOption(name: 'codeBlockThemeOneDark', themeId: 'oneDark'),
    CodeBlockThemeOption(name: 'codeBlockThemeOneLight', themeId: 'oneLight'),
    CodeBlockThemeOption(name: 'codeBlockThemeGithubDark', themeId: 'githubDark'),
    CodeBlockThemeOption(name: 'codeBlockThemeGithubLight', themeId: 'githubLight'),
    CodeBlockThemeOption(name: 'codeBlockThemeNord', themeId: 'nord'),
    CodeBlockThemeOption(name: 'codeBlockThemeMaterial', themeId: 'material'),
  ];

  // ==================== 尺寸规范 ====================

  /// 小内边距
  static const double paddingSmall = 8.0;

  /// 中等内边距
  static const double paddingMedium = 16.0;

  /// 大内边距
  static const double paddingLarge = 24.0;

  /// 标准圆角
  static const double borderRadius = 12.0;

  /// 小圆角
  static const double borderRadiusSmall = 8.0;

  // ==================== 动画配置 ====================

  /// 标准动画时长
  static const Duration animationDuration = Duration(milliseconds: 300);

  // ==================== 编辑器配置 ====================

  /// 编辑器默认字体大小
  static const double editorDefaultFontSize = 16.0;

  /// 编辑器最小字体大小
  static const double editorMinFontSize = 12.0;

  /// 编辑器最大字体大小
  static const double editorMaxFontSize = 24.0;

  /// 编辑器默认行高
  static const double editorDefaultLineHeight = 1.6;

  /// 编辑器默认正文字体
  static const String editorDefaultBodyFont = 'Noto Sans SC';

  /// 编辑器默认代码字体
  static const String editorDefaultMonoFont = 'JetBrains Mono';

  /// 自动保存默认间隔（秒）
  static const int autoSaveDefaultInterval = 30;

  /// 自动保存最小间隔（秒）
  static const int autoSaveMinInterval = 10;

  /// 自动保存最大间隔（秒）
  static const int autoSaveMaxInterval = 300;

  /// 文件缓存最大数量
  static const int maxCachedFiles = 24;

  /// 搜索结果最大显示数量
  static const int maxSearchMatches = 50;

  /// 编辑历史最大记录数
  static const int maxEditHistory = 100;

  /// 目录跳转顶部偏移量
  static const double tocJumpTopOffset = 32.0;

  // ==================== 文件类型配置 ====================

  /// 支持的 Markdown 文件扩展名
  static const List<String> markdownExtensions = ['.md', '.markdown'];

  /// 图片文件扩展名
  static const List<String> imageExtensions = [
    '.png',
    '.jpg',
    '.jpeg',
    '.gif',
    '.webp',
    '.svg',
  ];

  // ==================== 云同步配置 ====================

  /// 默认同步文件夹名称
  static const String defaultSyncFolderName = 'Ushio-MD';

  /// 默认 FTP 端口
  static const int defaultFtpPort = 21;
}
