// ============================================================================
// 主题设置页面（第三层）
//
// 包含：主题模式、语言、主题色、界面字体颜色、编辑器文字颜色、按钮样式、卡片透明度、浅色/深色主题方案、莫奈取色
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_style.dart';
import '../../../widgets/app_background.dart';
import '../../../utils/constants.dart';
import 'appearance_settings_mixin.dart';
import 'color_setting_selector.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen>
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
          title: Text(l10n.themeSettings),
          centerTitle: true,
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            initBrightnessValues(settings);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 主题模式
                buildSection(l10n.themeMode, Icons.brightness_6, [
                  buildThemeModeSelector(settings, l10n),
                ]),

                const SizedBox(height: 16),

                // 语言
                buildSection(l10n.language, Icons.language, [
                  buildLanguageSelector(settings, l10n),
                ]),

                const SizedBox(height: 16),

                // 主题色
                buildSection(l10n.themeColor, Icons.color_lens, [
                  ColorSettingSelector(
                    presets: SettingsProvider.themeColors,
                    selectedPresetIndex: settings.customThemeColor == null
                        ? settings.primaryColorIndex
                        : null,
                    customColor: settings.customThemeColor,
                    customLabel: l10n.customThemeColor,
                    pickerInitialColor: settings.primaryColor,
                    onPresetSelected: (index) =>
                        settings.setPrimaryColorIndex(index),
                    onCustomColorPicked: (color) =>
                        settings.setCustomThemeColor(color),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => pickAccentFromImage(settings),
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: Text(l10n.accentFromImage),
                  ),
                ]),

                const SizedBox(height: 16),

                // 界面字体颜色
                buildSection(l10n.uiFontColor, Icons.text_fields, [
                  ColorSettingSelector(
                    presets: SettingsProvider.uiFontColors,
                    selectedPresetIndex: settings.customUiFontColor == null
                        ? settings.uiFontColorIndex
                        : null,
                    customColor: settings.customUiFontColor,
                    customLabel: l10n.customUiFontColor,
                    pickerInitialColor: settings.uiFontColor,
                    showTextPreview: true,
                    onPresetSelected: (index) =>
                        settings.setUiFontColorIndex(index),
                    onCustomColorPicked: (color) =>
                        settings.setCustomUiFontColor(color),
                  ),
                ]),

                const SizedBox(height: 16),

                // 编辑器文字颜色
                buildSection(l10n.editorFontColor, Icons.edit_note, [
                  ColorSettingSelector(
                    presets: SettingsProvider.editorFontColors,
                    selectedPresetIndex: settings.customEditorFontColor == null
                        ? settings.editorFontColorIndex
                        : null,
                    customColor: settings.customEditorFontColor,
                    customLabel: l10n.customEditorFontColor,
                    pickerInitialColor: settings.editorFontColor,
                    description: l10n.editorFontColorDesc,
                    showTextPreview: true,
                    onPresetSelected: (index) =>
                        settings.setEditorFontColorIndex(index),
                    onCustomColorPicked: (color) =>
                        settings.setCustomEditorFontColor(color),
                  ),
                ]),

                const SizedBox(height: 16),

                // 全局图标颜色
                buildSection(l10n.globalIconColor, Icons.format_paint, [
                  ColorSettingSelector(
                    presets: SettingsProvider.globalIconColors,
                    customColor: settings.customIconColor,
                    customLabel: l10n.customGlobalIconColor,
                    pickerInitialColor: context.appIconColor,
                    description: l10n.globalIconColorDesc,
                    clearLabel: l10n.useThemeDefault,
                    onClearCustom: () => settings.setCustomIconColor(null),
                    onPresetSelected: (index) => settings.setCustomIconColor(
                      SettingsProvider.globalIconColors[index],
                    ),
                    onCustomColorPicked: (color) =>
                        settings.setCustomIconColor(color),
                  ),
                ]),

                const SizedBox(height: 16),

                // UI 风格
                buildSection(l10n.uiStyle, Icons.auto_awesome_rounded, [
                  buildButtonStyleSelector(settings, l10n),
                ]),

                const SizedBox(height: 16),

                // 卡片外观（独立于 UI 风格）
                buildSection(l10n.cardAppearance, Icons.style, [
                  buildOpacitySlider(
                    label: l10n.opacity,
                    value: settings.cardOpacity,
                    min: 0.4,
                    divisions: 12,
                    onChanged: settings.setCardOpacity,
                  ),
                  const SizedBox(height: 12),
                  ColorSettingSelector(
                    presets: AppConstants.cardColorPresets,
                    customColor: settings.customCardColor,
                    customLabel: l10n.cardColor,
                    pickerInitialColor: Theme.of(context).colorScheme.surface,
                    clearLabel: l10n.useThemeDefault,
                    onClearCustom: () => settings.setCustomCardColor(null),
                    onPresetSelected: (index) => settings.setCustomCardColor(
                      AppConstants.cardColorPresets[index],
                    ),
                    onCustomColorPicked: (color) =>
                        settings.setCustomCardColor(color),
                  ),
                ]),

                // 浅色主题方案（仅在浅色模式下显示）
                if (settings.themeMode == ThemeMode.light) ...[
                  const SizedBox(height: 16),
                  buildSection(l10n.lightTheme, Icons.light_mode, [
                    buildThemeSchemeSelector(
                      schemes: AppConstants.lightThemeSchemes,
                      selectedIndex: settings.lightThemeIndex,
                      onSelect: settings.setLightThemeIndex,
                    ),
                  ]),
                ],

                // 深色主题方案（仅在深色模式下显示）
                if (settings.themeMode == ThemeMode.dark) ...[
                  const SizedBox(height: 16),
                  buildSection(l10n.darkTheme, Icons.dark_mode, [
                    buildThemeSchemeSelector(
                      schemes: AppConstants.darkThemeSchemes,
                      selectedIndex: settings.darkThemeIndex,
                      onSelect: settings.setDarkThemeIndex,
                    ),
                  ]),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
