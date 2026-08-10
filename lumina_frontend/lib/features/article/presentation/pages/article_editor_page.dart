import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/quill_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/chips/category_chip.dart';
import '../../../../core/widgets/error_widgets/app_error_state.dart';
import '../../../../core/widgets/loaders/skeleton_loader.dart';
import '../../../../core/widgets/textfields/app_text_field.dart';
import '../../../../core/utils/session_error_handler.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../dashboard/presentation/bloc/feed_bloc.dart';
import '../../../preferences/data/models/category_model.dart';
import '../../../preferences/presentation/bloc/preferences_cubit.dart';
import '../bloc/article_editor_cubit.dart';

class ArticleEditorPage extends StatefulWidget {
  const ArticleEditorPage({this.articleId, super.key});

  final String? articleId;

  @override
  State<ArticleEditorPage> createState() => _ArticleEditorPageState();
}

class _ArticleEditorPageState extends State<ArticleEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  // Selected category (id + name stored together for display).
  CategoryModel? _selectedCategory;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
  }

  @override
  void dispose() {
    _title.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  // ── Category bottom-sheet picker ──────────────────────────────────────────
  Future<void> _pickCategory(List<CategoryModel> categories) async {
    final picked = await showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryPickerSheet(
        categories: categories,
        selectedId: _selectedCategory?.id,
      ),
    );
    if (picked != null) setState(() => _selectedCategory = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.articleId != null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ArticleEditorCubit(
            sl.articleRepository,
            storage: sl.storage,
          )..load(widget.articleId),
        ),
        BlocProvider(
          create: (_) => PreferencesCubit(sl.preferencesRepository)..load(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Edit article' : 'New article'),
          centerTitle: false,
        ),
        body: BlocConsumer<ArticleEditorCubit, ArticleEditorState>(
          listener: (context, state) {
            // Pre-fill fields when editing an existing article.
            if (!_prefilled && state.article != null) {
              _title.text = state.article!.title;
              _quillController = QuillUtils.controllerFromContent(state.article!.content);
              // Try to match the article's categoryId with a loaded category.
              final cats =
                  context.read<PreferencesCubit>().state.categories;
              if (cats.isNotEmpty && state.article!.categoryId != null) {
                final match = cats.where(
                  (c) => c.id == state.article!.categoryId,
                );
                if (match.isNotEmpty) {
                  setState(() => _selectedCategory = match.first);
                }
              }
              _prefilled = true;
            }
            if (state.status == ArticleEditorStatus.success) {
              context.read<FeedBloc>().add(const FeedRefreshed());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEdit ? 'Article updated!' : 'Article published!',
                  ),
                ),
              );
              context.go('/my-articles');
            }
            if (state.status == ArticleEditorStatus.failure &&
                state.error != null) {
              SessionErrorHandler.handle(context, state.error);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, editorState) {
            if (editorState.isLoading) {
              return const ResponsivePage(child: SkeletonLoader());
            }
            if (editorState.status == ArticleEditorStatus.failure &&
                editorState.article == null &&
                isEdit) {
              return ResponsivePage(
                child: AppErrorState(
                  message: editorState.error ?? 'Unable to load article',
                  onRetry: () =>
                      context.read<ArticleEditorCubit>().load(widget.articleId),
                ),
              );
            }

            return BlocBuilder<PreferencesCubit, PreferencesState>(
              builder: (context, prefState) {
                return ResponsivePage(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 40),
                      children: [
                        // ── Title ─────────────────────────────────────────
                        AppTextField(
                          label: 'Title',
                          controller: _title,
                          validator: Validators.requiredText,
                        ),
                        const SizedBox(height: 16),

                        // ── Category picker ───────────────────────────────
                        _CategoryPickerField(
                          selected: _selectedCategory,
                          isLoading: prefState.status ==
                              PreferencesStatus.loading,
                          hasError: prefState.status ==
                              PreferencesStatus.failure,
                          onTap: prefState.categories.isEmpty
                              ? null
                              : () => _pickCategory(prefState.categories),
                          validator: (_) => _selectedCategory == null
                              ? 'Please choose a category'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // ── Content with Flutter Quill ─────────────────────
                        FormField<String>(
                          validator: (_) {
                            final text = _quillController.document.toPlainText().trim();
                            if (text.isEmpty) return 'Article content is required';
                            return null;
                          },
                          builder: (field) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Article content',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: field.hasError
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withValues(alpha: .5),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      QuillSimpleToolbar(
                                        controller: _quillController,
                                        config:
                                            const QuillSimpleToolbarConfig(
                                          showHeaderStyle: true,
                                          showBoldButton: true,
                                          showItalicButton: true,
                                          showUnderLineButton: true,
                                          showStrikeThrough: false,
                                          showColorButton: false,
                                          showBackgroundColorButton: false,
                                          showListNumbers: true,
                                          showListBullets: true,
                                          showQuote: true,
                                          showCodeBlock: false,
                                          showLink: true,
                                          showUndo: true,
                                          showRedo: true,
                                        ),
                                      ),
                                      const Divider(height: 1),
                                      SizedBox(
                                        height: 250,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: QuillEditor(
                                            controller: _quillController,
                                            focusNode: _editorFocusNode,
                                            scrollController:
                                                _editorScrollController,
                                            config:
                                                const QuillEditorConfig(
                                              placeholder:
                                                  'Start writing your story here...',
                                              autoFocus: false,
                                              expands: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (field.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6, left: 12),
                                    child: Text(
                                      field.errorText!,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                AnimatedBuilder(
                                  animation: _quillController,
                                  builder: (context, _) {
                                    final len = _quillController.document
                                        .toPlainText()
                                        .trim()
                                        .length;
                                    final Color color;
                                    if (len < 300) {
                                      color = Theme.of(context).colorScheme.error;
                                    } else if (len > 2700) {
                                      color = Colors.amber.shade700;
                                    } else {
                                      color = Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: .7);
                                    }
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$len / 3000',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(color: color),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Cover image ───────────────────────────────────
                        OutlinedButton.icon(
                          onPressed: editorState.isSubmitting
                              ? null
                              : () => context
                                  .read<ArticleEditorCubit>()
                                  .pickImage(),
                          icon: const Icon(Icons.image_rounded),
                          label: Text(
                            editorState.image == null
                                ? 'Upload cover image (optional)'
                                : editorState.image!.name,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Submit ────────────────────────────────────────
                        PrimaryButton(
                          label: isEdit ? 'Save changes' : 'Publish article',
                          icon: Icons.publish_rounded,
                          isLoading: editorState.isSubmitting,
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            final userId =
                                context.read<AuthBloc>().state.user?.id ?? '';
                            final content = QuillUtils.contentFromController(
                              _quillController,
                            );
                            context.read<ArticleEditorCubit>().submit(
                              userId: userId,
                              articleId: widget.articleId,
                              title: _title.text.trim(),
                              content: content,
                              categoryId: _selectedCategory!.id,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Read-only tappable field showing the selected category.
// Uses readOnly: true so the keyboard NEVER opens (no IME events).
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryPickerField extends StatelessWidget {
  const _CategoryPickerField({
    required this.selected,
    required this.isLoading,
    required this.hasError,
    required this.onTap,
    required this.validator,
  });

  final CategoryModel? selected;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onTap;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category_rounded),
                  suffixIcon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.expand_more_rounded),
                  errorText: field.errorText,
                  hintText: hasError
                      ? 'Could not load categories — tap to retry'
                      : 'Select a category',
                ),
                child: selected == null
                    ? Text(
                        hasError ? 'Could not load categories' : 'Select a category',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: .5),
                        ),
                      )
                    : Text(selected!.name),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet with the full category list as chips.
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({
    required this.categories,
    this.selectedId,
  });

  final List<CategoryModel> categories;
  final String? selectedId;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  late String? _selected = widget.selectedId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Handle ──────────────────────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outline.withValues(alpha: .4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Choose a category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              // ── Category chips ──────────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.categories.map((cat) {
                        final isSelected = _selected == cat.id;
                        return CategoryChip(
                          label: cat.name,
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selected = cat.id);
                            // Auto-close after a brief delay so the chip
                            // selection animation is visible.
                            final nav = Navigator.of(context);
                            Future.delayed(
                              const Duration(milliseconds: 150),
                              () => nav.pop(cat),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
