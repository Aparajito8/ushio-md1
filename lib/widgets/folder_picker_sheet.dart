import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_provider.dart';
import '../providers/settings_provider.dart';
import '../services/file_service.dart';
import '../services/my_files_service.dart';
import '../utils/app_style.dart';
import '../utils/responsive_layout.dart';

/// 文件夹选择器底部弹窗 / 对话框
/// 用于将文件或文件夹移动到指定的目标文件夹
class FolderPickerSheet extends StatefulWidget {
  /// 要移动的文件或文件夹的原始完整路径
  final String entityPath;

  /// 是否是文件夹（否则为文件）
  final bool isFolder;

  /// 初始浏览目录（可选，默认从工作区根目录或文件所在目录开始）
  final String? initialDirectory;

  const FolderPickerSheet({
    super.key,
    required this.entityPath,
    this.isFolder = false,
    this.initialDirectory,
  });

  /// 打开文件夹选择器底部弹窗
  static Future<String?> show(
    BuildContext context, {
    required String entityPath,
    bool isFolder = false,
    String? initialDirectory,
  }) {
    final isDesktop = ResponsiveLayout.isDesktopWidth(context);

    if (isDesktop) {
      return showDialog<String>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: FolderPickerSheet(
                entityPath: entityPath,
                isFolder: isFolder,
                initialDirectory: initialDirectory,
              ),
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.82,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: FolderPickerSheet(
              entityPath: entityPath,
              isFolder: isFolder,
              initialDirectory: initialDirectory,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<FolderPickerSheet> {
  final MyFilesService _myFilesService = MyFilesService();
  String? _workspaceRoot;
  late String _currentDirectory;
  final List<String> _navigationHistory = [];

  List<Directory> _subdirectories = [];
  bool _isLoading = true;
  String? _errorMessage;

  String get _entityName => widget.entityPath.split(Platform.pathSeparator).last;
  String get _entityParentPath {
    final separator = Platform.pathSeparator;
    final lastIndex = widget.entityPath.lastIndexOf(separator);
    return lastIndex > 0 ? widget.entityPath.substring(0, lastIndex) : '';
  }

  @override
  void initState() {
    super.initState();
    _initDirectory();
  }

  Future<void> _initDirectory() async {
    final settings = context.read<SettingsProvider>();
    _myFilesService.setSettingsProvider(settings);

    try {
      _workspaceRoot = await _myFilesService.getWorkspacePath();
    } catch (_) {
      _workspaceRoot = null;
    }

    // 默认浏览位置：若指定了初始目录则使用，否则优先使用工作区根目录
    String initial = widget.initialDirectory ?? _workspaceRoot ?? _entityParentPath;
    if (!Directory(initial).existsSync()) {
      initial = _entityParentPath;
    }
    if (!Directory(initial).existsSync() && _workspaceRoot != null) {
      initial = _workspaceRoot!;
    }

    _currentDirectory = initial;
    await _loadSubdirectories();
  }

  Future<void> _loadSubdirectories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dir = Directory(_currentDirectory);
      if (!await dir.exists()) {
        throw Exception('目录不存在');
      }

      final entities = await dir.list(followLinks: false).toList();
      final dirs = <Directory>[];

      for (final e in entities) {
        if (e is Directory) {
          final name = e.path.split(Platform.pathSeparator).last;
          if (name.startsWith('.')) continue; // 忽略隐藏目录

          // 如果是移动文件夹，不能移动到自身或其子目录中
          if (widget.isFolder) {
            final oldNorm = Directory(widget.entityPath).absolute.path.toLowerCase();
            final curNorm = e.absolute.path.toLowerCase();
            if (curNorm == oldNorm || curNorm.startsWith('$oldNorm${Platform.pathSeparator}')) {
              continue;
            }
          }

          dirs.add(e);
        }
      }

      // 按文件夹名称排序
      dirs.sort((a, b) {
        final nameA = a.path.split(Platform.pathSeparator).last.toLowerCase();
        final nameB = b.path.split(Platform.pathSeparator).last.toLowerCase();
        return nameA.compareTo(nameB);
      });

      if (mounted) {
        setState(() {
          _subdirectories = dirs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateTo(String newPath) {
    if (newPath == _currentDirectory) return;
    _navigationHistory.add(_currentDirectory);
    setState(() {
      _currentDirectory = newPath;
    });
    _loadSubdirectories();
  }

  bool _canGoBack() {
    if (_navigationHistory.isNotEmpty) return true;
    final parent = Directory(_currentDirectory).parent;
    if (_workspaceRoot != null) {
      final currentNorm = Directory(_currentDirectory).absolute.path.toLowerCase();
      final rootNorm = Directory(_workspaceRoot!).absolute.path.toLowerCase();
      return currentNorm != rootNorm && parent.existsSync();
    }
    return parent.existsSync() && parent.path != _currentDirectory;
  }

  void _goBack() {
    if (_navigationHistory.isNotEmpty) {
      final prev = _navigationHistory.removeLast();
      setState(() {
        _currentDirectory = prev;
      });
      _loadSubdirectories();
    } else {
      final parent = Directory(_currentDirectory).parent;
      if (parent.existsSync() && parent.path != _currentDirectory) {
        setState(() {
          _currentDirectory = parent.path;
        });
        _loadSubdirectories();
      }
    }
  }

  /// 在当前目录下快速新建子文件夹
  Future<void> _showCreateFolderDialog() async {
    final controller = TextEditingController();
    final illegalCharsRegex = RegExp(r'[\\/:*?"<>|]');
    String? errorText;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.create_new_folder, color: Colors.amber),
              SizedBox(width: 8),
              Text('新建子文件夹'),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: '文件夹名称',
              hintText: '例如: 计算机网络',
              errorText: errorText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              setDialogState(() {
                if (val.trim().isEmpty) {
                  errorText = '名称不能为空';
                } else if (illegalCharsRegex.hasMatch(val)) {
                  errorText = '名称不能包含 \\ / : * ? " < > |';
                } else {
                  errorText = null;
                }
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty && !illegalCharsRegex.hasMatch(text)) {
                  Navigator.pop(context, text);
                }
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );

    if (name != null && name.isNotEmpty) {
      try {
        final newFolderPath = '$_currentDirectory${Platform.pathSeparator}$name';
        final newDir = Directory(newFolderPath);
        if (await newDir.exists()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已存在同名文件夹')),
            );
          }
          return;
        }
        await newDir.create(recursive: true);
        await _loadSubdirectories();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('创建失败: $e')),
          );
        }
      }
    }
  }

  /// 从系统目录中选取外部文件夹
  Future<void> _pickExternalDirectory() async {
    final fileProvider = context.read<FileProvider>();
    final path = await fileProvider.fileService.pickDirectory();
    if (path != null && Directory(path).existsSync()) {
      _navigateTo(path);
    }
  }

  /// 确认执行移动
  Future<void> _confirmMove() async {
    final fileProvider = context.read<FileProvider>();
    final targetDirectory = _currentDirectory;

    // 检查是否已经在当前目录
    if (widget.isFolder) {
      if (targetDirectory == _entityParentPath) {
        return;
      }
    } else {
      if (targetDirectory == _entityParentPath) {
        return;
      }
    }

    // 冲突检查
    if (!widget.isFolder) {
      final targetFilePath = '$targetDirectory${Platform.pathSeparator}$_entityName';
      if (File(targetFilePath).existsSync()) {
        final resolution = await _showConflictDialog(_entityName);
        if (resolution == null || resolution == _ConflictChoice.cancel) {
          return;
        }

        if (!mounted) return;

        if (resolution == _ConflictChoice.overwrite) {
          final result = await fileProvider.moveFile(
            widget.entityPath,
            targetDirectory,
            overwrite: true,
          );
          _handleMoveResult(result);
          return;
        }

        if (resolution == _ConflictChoice.keepBoth) {
          final uniqueName = FileService.generateUniqueFileName(
            targetDirectory,
            _entityName,
          );
          final result = await fileProvider.moveFile(
            widget.entityPath,
            targetDirectory,
            newFileName: uniqueName,
            overwrite: false,
          );
          _handleMoveResult(result);
          return;
        }
      } else {
        final result = await fileProvider.moveFile(
          widget.entityPath,
          targetDirectory,
        );
        _handleMoveResult(result);
      }
    } else {
      // 移动文件夹
      final targetFolderPath = '$targetDirectory${Platform.pathSeparator}$_entityName';
      if (Directory(targetFolderPath).existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('目标位置已存在同名文件夹，请先重命名')),
          );
        }
        return;
      }

      final result = await fileProvider.moveFolder(
        widget.entityPath,
        targetDirectory,
      );
      _handleMoveResult(result);
    }
  }

  void _handleMoveResult(String? resultPath) {
    if (!mounted) return;
    if (resultPath != null) {
      final targetFolderName = _getDisplayFolderName(_currentDirectory);
      Navigator.pop(context, resultPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('已成功移动到 "$targetFolderName"'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('移动失败，请重试')),
      );
    }
  }

  Future<_ConflictChoice?> _showConflictDialog(String fileName) {
    return showDialog<_ConflictChoice>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('发现同名文件'),
        content: Text('目标文件夹中已存在名为 "$fileName" 的文件，请选择操作：'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _ConflictChoice.cancel),
            child: const Text('取消'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, _ConflictChoice.keepBoth),
            child: const Text('保留两者'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _ConflictChoice.overwrite),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('覆盖'),
          ),
        ],
      ),
    );
  }

  String _getDisplayFolderName(String path) {
    if (_workspaceRoot != null) {
      final norm = Directory(path).absolute.path.toLowerCase();
      final rootNorm = Directory(_workspaceRoot!).absolute.path.toLowerCase();
      if (norm == rootNorm) {
        return '我的文件 (根目录)';
      }
    }
    return path.split(Platform.pathSeparator).last;
  }

  String _getBreadcrumbPath() {
    if (_workspaceRoot != null) {
      final currentNorm = Directory(_currentDirectory).absolute.path;
      final rootNorm = Directory(_workspaceRoot!).absolute.path;
      if (currentNorm.toLowerCase().startsWith(rootNorm.toLowerCase())) {
        final rel = currentNorm.substring(rootNorm.length);
        final parts = rel.split(Platform.pathSeparator).where((s) => s.isNotEmpty).toList();
        if (parts.isEmpty) {
          return '我的文件';
        }
        return '我的文件 > ${parts.join(' > ')}';
      }
    }
    return _currentDirectory;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCurrentLocation = _currentDirectory == _entityParentPath;

    return Column(
      children: [
        // 顶部拖拽手柄条
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // 头部标题栏
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.drive_file_move_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isFolder ? '移动文件夹' : '移动文件',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _entityName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                tooltip: '关闭',
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // 面包屑导航与快速操作栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Row(
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                onPressed: _canGoBack() ? _goBack : null,
                tooltip: '返回上一层',
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getBreadcrumbPath(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined, size: 22),
                onPressed: _showCreateFolderDialog,
                tooltip: '新建子文件夹',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.folder_open_outlined, size: 22),
                onPressed: _pickExternalDirectory,
                tooltip: '从外部系统选取',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        // 文件夹列表
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        '加载失败: $_errorMessage',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    )
                  : _subdirectories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.folder_open_rounded,
                                size: 56,
                                color: colorScheme.outline.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '此文件夹下暂无子文件夹',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '可直接点击下方按钮移动至此处',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.outline.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _subdirectories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final dir = _subdirectories[index];
                            final dirName = dir.path.split(Platform.pathSeparator).last;
                            final isSameAsSource = !widget.isFolder &&
                                dir.path == _entityParentPath;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _navigateTo(dir.path),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.dividerColor
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.folder_rounded,
                                        color: Colors.amber,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dirName,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (isSameAsSource)
                                              Text(
                                                '文件当前所在位置',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: colorScheme.outline,
                                                  fontSize: 11,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: colorScheme.outline,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
        ),

        // 底部确认操作栏
        Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '目标目录: ${_getDisplayFolderName(_currentDirectory)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: isCurrentLocation ? null : _confirmMove,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    isCurrentLocation
                        ? '已在当前文件夹中'
                        : '移动到此处 (${_getDisplayFolderName(_currentDirectory)})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _ConflictChoice { cancel, keepBoth, overwrite }
