# Article Feed Architecture Blueprint

## Project Structure

The app uses feature-first Clean Architecture:

- `core`: constants, errors, Dio, routing, secure storage, theme, utilities, and reusable primitives.
- `features/*/data`: REST datasources, DTO models, and repository implementations.
- `features/*/domain`: entities, repository contracts, and use cases.
- `features/*/presentation`: BLoC/Cubit state, pages, and feature widgets.
- `shared`: cross-feature models, enums, services, and layout widgets.
- `injection_container.dart`: application composition root.
- `main.dart`: app bootstrap, theme mode, route binding, and global providers.

## Screen System

Every screen follows the same contract:

- Layout structure: `Scaffold` plus `ResponsivePage`, with constrained content on web and full-width mobile flow.
- Widget hierarchy: page-level widgets compose reusable buttons, text fields, cards, chips, loaders, empty states, and error states.
- Responsive behavior: mobile uses bottom navigation, tablet uses constrained content, desktop uses an extended navigation rail/sidebar.
- Dark UI: off-black/deep navy surfaces, blue accent, outlined cards, low-glare contrast.
- Light UI: white/soft gray surfaces, blue accent, subtle borders, clean hierarchy.
- UX flow: pages expose one primary task, with secondary actions as text or outlined buttons.
- Animation suggestions: splash scale-in, feed card fade/slide, skeleton shimmer, route transitions, hover/tap ink states.
- Reusable components: `PrimaryButton`, `AppTextField`, `ArticleFeedCard`, `CategoryChip`, `AppNetworkImage`, `AppEmptyState`, `AppErrorState`, `SkeletonLoader`.
- State management: BLoC owns async workflow and validation outcomes; widgets only dispatch events and render states.
- Validation: `form_validator` powers email/password/required fields before BLoC events fire.
- API trigger points: forms dispatch BLoC events, feed filters dispatch fetch events, editor dispatches multipart/presigned upload flows.

## Authentication Flow

Splash checks secure storage through `AuthStarted`.

Flow: Splash -> Onboarding -> Login or Signup -> OTP Verification -> Dashboard.

- Token persistence: `SecureStorageService` writes access and refresh tokens with `flutter_secure_storage`.
- Auto-login: `AuthBloc` calls `restoreSession` at startup and routes authenticated users to `/dashboard`.
- Route protection: `GoRouter` redirect uses `RouteGuards.authRedirect`.
- Session expiration: `DioAuthInterceptor` attaches bearer tokens and treats 401 responses as an unauthorized session. The production next step is to call refresh-token once, retry the failed request, then dispatch logout if refresh fails.

## Dashboard Flow

Dashboard includes:

- Personalized feed from `FeedBloc`.
- Search field dispatching `FeedSearchChanged`.
- Category chips dispatching `FeedCategoryChanged`.
- Like, block, and article open actions on cards.
- Infinite scrolling through `FeedNextPageRequested`.
- Trending categories through the category chip group.
- Responsive cards that switch from vertical mobile cards to horizontal desktop cards.
- Floating create button on the shell.
- Sidebar navigation on desktop and bottom navigation on mobile.

## Article Flow

Article operations are owned by `ArticleRepository`.

- Create article: form validates title/category/body, then `ArticleEditorCubit.create` calls the repository.
- Upload image: `image_picker` selects a cover image.
- Presigned URLs: repository requests `/uploads/presigned-url`, uploads bytes with Dio `PUT`, then sends the article payload.
- Edit article: `/articles/:id` route reuses the editor surface.
- Delete article: repository exposes `deleteArticle`.
- Analytics: article detail and my articles screens reserve analytics actions for read depth, likes, saves, shares, and category affinity.

## Settings Flow

Settings includes profile edit, change password, theme switch, preferences management, and logout.

- Theme switch: `ThemeCubit` persists `ThemeMode` in secure storage.
- Logout: dispatches `AuthLogoutRequested`, clears tokens, and route protection returns to login.

## Theme System

- `AppTheme.light` and `AppTheme.dark` expose complete `ThemeData`.
- `AppColors` defines neutral surfaces, muted borders, semantic colors, and one blue accent.
- `AppTextTheme` centralizes typography hierarchy.
- Component theming covers cards and form fields.
- Adaptive colors come from `ColorScheme`.
- Theme switching is persisted by `ThemeCubit`.

## Responsive Strategy

- Mobile `< 700`: bottom navigation, single-column forms, stacked article cards.
- Tablet `700-1023`: constrained content, larger spacing, still touch-first navigation.
- Desktop `>= 1024`: extended navigation rail/sidebar, wider card layouts, hover-capable Material states.
- Breakpoints are centralized in `AppSizes`.

## BLoC State Management

- Auth: `AuthBloc` handles startup, login, signup, OTP verification, and logout.
- Feed: `FeedBloc` handles initial load, filtering, searching, pagination, empty, and error states.
- Editor: `ArticleEditorCubit` handles image selection and submit state.
- Loading states render skeletons or disabled submit buttons.
- Error states render inline error UI or retryable pages.
- Pagination state keeps current page, current articles, and `hasMore`.

## Production API Mapping

- `POST /auth/login`
- `POST /auth/signup`
- `POST /auth/verify-otp`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `GET /feed`
- `GET /articles/:id`
- `POST /articles`
- `PUT /articles/:id`
- `DELETE /articles/:id`
- `POST /uploads/presigned-url`
- `GET /notifications`
- `GET/PUT /profile`
- `GET/PUT /preferences`
