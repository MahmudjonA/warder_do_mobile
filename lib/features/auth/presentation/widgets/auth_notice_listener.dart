import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/wd_icon.dart';
import '../bloc/auth_bloc.dart';

/// Bloc'dan kelgan xatolik va muvaffaqiyat xabarlarini snackbar qilib
/// ko'rsatadi, so'ng ularni tozalaydi.
///
/// Har bir ekranda bir xil `BlocListener` yozib chiqmaslik uchun ajratilgan.
class AuthNoticeListener extends StatelessWidget {
  const AuthNoticeListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Faqat yangi xabar kelganda ishlaydi: `noticeId` har safar oshadi,
      // shuning uchun bir xil xatolik ketma-ket kelsa ham sezamiz.
      listenWhen: (previous, current) =>
          previous.noticeId != current.noticeId &&
          (current.failure != null || current.successMessage != null),
      listener: (context, state) {
        final message = state.failure?.message ?? state.successMessage;
        if (message == null) return;

        final isError = state.failure != null;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  WdIcon(
                    isError ? AppIcons.alert : AppIcons.checkCircle,
                    size: 20,
                    color: isError ? AppColors.danger : AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(message)),
                ],
              ),
              duration: const Duration(seconds: 3),
            ),
          );

        context.read<AuthBloc>().add(const AuthNoticeCleared());
      },
      child: child,
    );
  }
}
