import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/wd_button.dart';
import '../../../../core/widgets/wd_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_notice_listener.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Klaviaturani yopamiz — xatolik snackbar'i tagida qolib ketmasin.
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
      AuthLoginSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthNoticeListener(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final fieldErrors = state.fieldErrors;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: WdCircleBackButton(
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go(AppRoutes.welcome),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        children: [
                          Text(
                            AppStrings.loginTitle,
                            style: AppTextStyles.display,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppStrings.loginSubtitle,
                            style: AppTextStyles.bodyMuted,
                          ),
                          const SizedBox(height: 36),
                          WdTextField(
                            controller: _emailController,
                            label: AppStrings.email,
                            hint: AppStrings.emailHint,
                            icon: AppIcons.email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            validator: Validators.email,
                            // Server 422 bergan bo'lsa aynan shu maydon ostida
                            // ko'rsatamiz.
                            errorText: fieldErrors['email'],
                            enabled: !state.isSubmitting,
                          ),
                          const SizedBox(height: 20),
                          WdTextField(
                            controller: _passwordController,
                            label: AppStrings.password,
                            hint: AppStrings.passwordHint,
                            icon: AppIcons.lock,
                            obscure: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            validator: Validators.loginPassword,
                            errorText: fieldErrors['password'],
                            enabled: !state.isSubmitting,
                            onSubmitted: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      16 + MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: Column(
                      children: [
                        WdPrimaryButton(
                          label: AppStrings.loginAction,
                          isLoading: state.isSubmitting,
                          onPressed: _submit,
                        ),
                        WdTextLink(
                          prefix: AppStrings.noAccount,
                          label: AppStrings.signUp,
                          onPressed: state.isSubmitting
                              ? () {}
                              : () =>
                                    context.pushReplacement(AppRoutes.register),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
