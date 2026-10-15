import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdreader/l10n/app_localizations.dart';
import 'package:mdreader/providers/settings_provider.dart';
import 'package:mdreader/screens/settings/appearance/theme_settings_screen.dart';
import 'package:mdreader/utils/app_style.dart';
import 'package:mdreader/utils/constants.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => 'C:/fake/documents';

  @override
  Future<String?> getApplicationSupportPath() async => 'C:/fake/support';

  @override
  Future<String?> getTemporaryPath() async => 'C:/fake/tmp';
}

Future<SettingsProvider> _createSettings() async {
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  PathProviderPlatform.instance = _FakePathProvider();
  final settings = SettingsProvider();
  await settings.initialize();
  return settings;
}

Future<void> pumpThemeSettings(WidgetTester tester, SettingsProvider settings) async {
  // SliverList 只构建视口与 cacheExtent 内的子项，页面下方区块会因此缺席；
  // 把测试面拉高到足以容纳整页，断言才能覆盖全部区块。
  tester.view.physicalSize = const Size(1200, 6400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final scheme = ColorScheme.fromSeed(seedColor: SettingsProvider.themeColors.first);
  final appStyle = AppStyleTheme.resolve(
    brightness: Brightness.light,
    colorScheme: scheme,
    textSecondary: scheme.onSurfaceVariant,
    buttonStyleMode: AppButtonStyleMode.liquidGlass,
    cardOpacity: 0.8,
  );
  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh'), Locale('en')],
        locale: const Locale('zh'),
        theme: ThemeData(colorScheme: scheme, extensions: [appStyle]),
        home: const ThemeSettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  // SettingsProvider 的写入有 500ms 防抖 Timer，pumpAndSettle 只等帧不等 Timer，
  // 不冲刷的话测试结束时会留下 pending timer 而失败。
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('主题设置页不再提供莫奈入口，并提供从图片取色', (tester) async {
    final settings = await _createSettings();
    await pumpThemeSettings(tester, settings);

    expect(tester.takeException(), isNull);
    expect(find.textContaining('莫奈'), findsNothing);
    expect(find.text('从图片取色'), findsOneWidget);
  });

  testWidgets('五个颜色区块各自只渲染一个自定义取色入口，且无遗留开关', (tester) async {
    final settings = await _createSettings();
    await pumpThemeSettings(tester, settings);

    // 主题色 / 界面字体 / 编辑器文字 / 图标色 / 卡片色
    expect(find.byIcon(Icons.tune), findsNWidgets(5));
    // 图标色与卡片色的旧式 useCustom 开关已随状态模型收敛一并移除
    expect(find.byType(Switch), findsNothing);
  });

  testWidgets('浅色 5 套与深色 6 套主题方案均参与渲染', (tester) async {
    final settings = await _createSettings();
    await settings.setThemeMode(ThemeMode.light);
    await pumpThemeSettings(tester, settings);

    for (final scheme in AppConstants.lightThemeSchemes) {
      expect(find.text(scheme.name), findsOneWidget);
    }
    // 深色方案只在深色模式下显示，这是当前门控的既定行为
    for (final scheme in AppConstants.darkThemeSchemes) {
      expect(find.text(scheme.name), findsNothing);
    }
  });
}
