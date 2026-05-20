import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/error_widgets/app_error_state.dart';
import '../../../../core/widgets/loaders/skeleton_loader.dart';
import '../../../../core/widgets/textfields/app_text_field.dart';
import '../../../../core/utils/session_error_handler.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../dashboard/presentation/bloc/feed_bloc.dart';
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
  final _content = TextEditingController();
  final _categoryId = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _categoryId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.articleId != null;
    return BlocProvider(
      create: (_) =>
          ArticleEditorCubit(sl.articleRepository)..load(widget.articleId),
      child: Scaffold(
        body: BlocConsumer<ArticleEditorCubit, ArticleEditorState>(
          listener: (context, state) {
            if (!_prefilled && state.article != null) {
              _title.text = state.article!.title;
              _content.text = state.article!.content;
              _categoryId.text = state.article!.categoryId ?? '';
              _prefilled = true;
            }
            if (state.status == ArticleEditorStatus.success) {
              context.read<FeedBloc>().add(const FeedRefreshed());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEdit ? 'Article updated' : 'Article published',
                  ),
                ),
              );
              context.go('/my-articles');
            }
            if (state.status == ArticleEditorStatus.failure &&
                state.error != null) {
              SessionErrorHandler.handle(context, state.error);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const ResponsivePage(child: SkeletonLoader());
            }
            if (state.status == ArticleEditorStatus.failure &&
                state.article == null &&
                isEdit) {
              return ResponsivePage(
                child: AppErrorState(
                  message: state.error ?? 'Unable to load article',
                  onRetry: () =>
                      context.read<ArticleEditorCubit>().load(widget.articleId),
                ),
              );
            }
            return ResponsivePage(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text(
                      isEdit ? 'Edit article' : 'Create article',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: 'Title',
                      controller: _title,
                      validator: Validators.requiredText,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Category ID',
                      controller: _categoryId,
                      validator: Validators.requiredText,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Article content',
                      controller: _content,
                      maxLines: 10,
                      validator: Validators.requiredText,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: state.isSubmitting
                          ? null
                          : () =>
                                context.read<ArticleEditorCubit>().pickImage(),
                      icon: const Icon(Icons.image_rounded),
                      label: Text(
                        state.image == null
                            ? 'Upload cover image'
                            : state.image!.name,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: isEdit ? 'Save changes' : 'Publish article',
                      icon: Icons.publish_rounded,
                      isLoading: state.isSubmitting,
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        final userId =
                            context.read<AuthBloc>().state.user?.id ?? '';
                        context.read<ArticleEditorCubit>().submit(
                          userId: userId,
                          articleId: widget.articleId,
                          title: _title.text.trim(),
                          content: _content.text.trim(),
                          categoryId: _categoryId.text.trim(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
