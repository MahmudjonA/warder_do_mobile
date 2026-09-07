import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/group_template_catalog.dart';
import '../../domain/entities/group.dart';
import '../../../../core/widgets/pickers.dart';
import '../../../../core/widgets/wd_icon.dart';

/// "Shablonlar" ekrani — screenshotdagi bo'limlarga bo'lingan ro'yxat.
///
/// Katalog **client tomonda** (backendda guruh shablonlari yo'q), shuning
/// uchun bu ekran hech qanday so'rov yubormaydi. Shablon tanlanganda
/// "Guruh qo'shish" formasi oldindan to'ldirilgan holda ochiladi.
class GroupTemplatesPage extends StatefulWidget {
  const GroupTemplatesPage({super.key});

  @override
  State<GroupTemplatesPage> createState() => _GroupTemplatesPageState();
}

class _GroupTemplatesPageState extends State<GroupTemplatesPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = GroupTemplateCatalog.search(_query);
    final isSearching = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.templates),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const WdIcon(AppIcons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceHigh,
              shape: const CircleBorder(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: sections.isEmpty
                ? const Center(
                    child: Text(
                      AppStrings.nothingFound,
                      style: AppTextStyles.bodyMuted,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      // Qidiruv paytida "o'zingiznikilar" bo'limi keraksiz.
                      if (!isSearching) ...[
                        _SectionTitle(AppStrings.customSection),
                        CardGroup(
                          children: [
                            EmojiListTile(
                              emojiKey: 'folder',
                              title: AppStrings.createOwnGroup,
                              onTap: () => _openForm(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      for (final section in sections) ...[
                        _SectionTitle(section.title),
                        CardGroup(
                          children: [
                            for (final template in section.templates)
                              EmojiListTile(
                                emojiKey: template.icon,
                                title: template.name,
                                onTap: () =>
                                    _openForm(context, template: template),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
          ),
          _SearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {GroupTemplate? template}) {
    context.push(AppRoutes.groupEdit, extra: template);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(title, style: AppTextStyles.sectionLabel),
    );
  }
}

/// Screenshotdagi kabi pastda turadigan qidiruv maydoni.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: AppStrings.searchTemplates,
          hintStyle: AppTextStyles.bodyMuted,
          prefixIcon: const WdIcon(
            AppIcons.search,
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
