// ============================================================================
// 配色与主题页面（第三层）
//
// 包含：主题模式、强调色（含从图片取色）、浅色/深色主题方案
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/app_background.dart';
import 'appearance_settings_mixin.dart';
import 'color_setting_selector.dart';

class ColorThemeScreen extends StatefulWidget {
  const ColorThemeScreen({super.key});

  @override
  State<ColorThemeScreen> createState() => _ColorThemeScreenState();
}

class _ColorThemeScreenState extends State<ColorThemeScreen>
    with AppearanceSettingsMixin {
  @override
  void initState() {
    super.initState();
    initAppearanceMixin();
  }

  @override
  void dispose() {
    disposeAppearanceMixin();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBackground(
      wrapWithSafeArea: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.colorThemeSettings),
          centerTitle: true,
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                buildSection(l10n.themeMode, Icons.brightness_6, [
                  buildThemeModeSelector(settings, l10n),
                ]),

                const SizedBox(height: 16),

                buildSection(l10n.themeColor, Icons.color_lens, [
                  ColorSettingSelector(
                    presets: SettingsProvider.themeColors,
                    selectedPresetIndex: settings.customThemeColor == null
                        ? settings.primaryColorIndex
                        : null,
                    customColor: settings.customThemeColor,
                    customLabel: l10n.customThemeColor,
                    pickerInitialColor: settings.primaryColor,
                    onPresetSelected: settings.setPrimaryColorIndex,
                    onCustomColorPicked: settings.setCustomThemeColor,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => pickAccentFromImage(settings),
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: Text(l10n.accentFromImage),
                  ),
                ]),

                // 两套配色方案都常驻：此前按 themeMode 二选一显示，
                // 而默认值是 system，导致绝大多数用户从未见过这 11 套方案。
                const SizedBox(height: 16),

                buildSection(l10n.lightTheme, Icons.light_mode, [
                  buildThemeSchemeSelector(
                    schemes: AppConstants.lightThemeSchemes,
                    selectedIndex: settings.lightThemeIndex,
                    onSelect: settings.setLightThemeIndex,
                  ),
                ]),

                const SizedBox(height: 16),

                buildSection(l10n.darkTheme, Icons.dark_mode, [
                  buildThemeSchemeSelector(
                    schemes: AppConstants.darkThemeSchemes,
                    selectedIndex: settings.darkThemeIndex,
                    onSelect: settings.setDarkThemeIndex,
                  ),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}
