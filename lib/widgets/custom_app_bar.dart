import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/currency_provider.dart';
import '../services/theme_provider.dart';
import '../styles/colors.dart';
import '../styles/sizes.dart';

/// A reusable app bar with the LuminaLoan brand, a currency selector
/// dropdown, and a theme-toggle button.
///
/// Implements [PreferredSizeWidget] so it can be assigned directly to
/// [Scaffold.appBar].
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final appBarBg =
        isDark ? AppColors.darkAppBarBackground : AppColors.lightAppBarBackground;

    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: appBarBg,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkCardShadow : AppColors.lightCardShadow,
            blurRadius: AppSizes.p8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppSizes.paddingH16,
        child: Row(
          children: [
            // ── Logo ──
            _AppLogo(isDark: isDark),
            const SizedBox(width: AppSizes.p12),

            // ── Brand Name ──
            _BrandText(theme: theme, isDark: isDark),

            const Spacer(),

            // ── Currency Selector ──
            _CurrencyButton(isDark: isDark, ref: ref, theme: theme),
            const SizedBox(width: AppSizes.p8),

            // ── Theme Toggle ──
            _ThemeToggleButton(isDark: isDark, ref: ref),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Rounded-square lightning-bolt logo.
class _AppLogo extends StatelessWidget {
  const _AppLogo({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.appBarLogoSize,
      height: AppSizes.appBarLogoSize,
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyPrimaryDark : AppColors.navyPrimaryLight,
        borderRadius: AppSizes.brSmall,
      ),
      child: const Icon(
        Icons.bolt,
        color: Colors.white,
        size: AppSizes.iconMedium,
      ),
    );
  }
}

/// "Lumina" in primary text + "Loan" in accent colour.
class _BrandText extends StatelessWidget {
  const _BrandText({required this.theme, required this.isDark});

  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: theme.textTheme.titleLarge,
        children: [
          const TextSpan(text: 'Lumina'),
          TextSpan(
            text: 'Loan',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark
                  ? AppColors.darkBrandAccent
                  : AppColors.lightBrandAccent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Outlined button that opens the currency [PopupMenuButton].
class _CurrencyButton extends StatelessWidget {
  const _CurrencyButton({
    required this.isDark,
    required this.ref,
    required this.theme,
  });

  final bool isDark;
  final WidgetRef ref;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final selectedCurrency = ref.watch(currencyProvider);
    final borderColor = isDark
        ? AppColors.darkCurrencyBtnBorder
        : AppColors.lightCurrencyBtnBorder;
    final btnBg = isDark
        ? AppColors.darkCurrencyBtnBackground
        : AppColors.lightCurrencyBtnBackground;

    return PopupMenuButton<Currency>(
      onSelected: (currency) {
        ref.read(currencyProvider.notifier).setCurrency(currency);
      },
      offset: const Offset(0, AppSizes.currencyBtnHeight + AppSizes.p8),
      shape: RoundedRectangleBorder(borderRadius: AppSizes.brMedium),
      color: isDark
          ? AppColors.darkDropdownBackground
          : AppColors.lightDropdownBackground,
      elevation: 8,
      constraints: const BoxConstraints(minWidth: AppSizes.dropdownWidth),
      itemBuilder: (_) => Currency.values.map((currency) {
        final isSelected = currency == selectedCurrency;
        return PopupMenuItem<Currency>(
          value: currency,
          padding: AppSizes.paddingZero,
          child: _CurrencyDropdownItem(
            currency: currency,
            isSelected: isSelected,
            isDark: isDark,
            theme: theme,
          ),
        );
      }).toList(),
      child: Container(
        height: AppSizes.currencyBtnHeight,
        padding: AppSizes.paddingH12,
        decoration: BoxDecoration(
          color: btnBg,
          borderRadius: AppSizes.brLarge,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCurrency.symbol,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(width: AppSizes.p4),
            Text(
              selectedCurrency.code,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(width: AppSizes.p4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: AppSizes.iconSmall,
              color: theme.textTheme.labelLarge?.color,
            ),
          ],
        ),
      ),
    );
  }
}

/// A single row inside the currency dropdown menu.
class _CurrencyDropdownItem extends StatelessWidget {
  const _CurrencyDropdownItem({
    required this.currency,
    required this.isSelected,
    required this.isDark,
    required this.theme,
  });

  final Currency currency;
  final bool isSelected;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final selectedBg = isDark
        ? AppColors.darkDropdownSelectedBg
        : AppColors.lightDropdownSelectedBg;
    final iconBg = isDark
        ? AppColors.darkCurrencyIconBg
        : AppColors.lightCurrencyIconBg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p12,
      ),
      decoration: BoxDecoration(
        color: isSelected ? selectedBg : Colors.transparent,
        borderRadius: AppSizes.brSmall,
      ),
      child: Row(
        children: [
          // Circular currency icon
          Container(
            width: AppSizes.currencyIconSize,
            height: AppSizes.currencyIconSize,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              currency.symbol,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.p12),

          // Currency code + full name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currency.code,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: AppSizes.p4),
              Text(
                currency.name,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Outlined icon button that toggles between light and dark mode.
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({
    required this.isDark,
    required this.ref,
  });

  final bool isDark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? AppColors.darkCurrencyBtnBorder
        : AppColors.lightCurrencyBtnBorder;
    final btnBg = isDark
        ? AppColors.darkCurrencyBtnBackground
        : AppColors.lightCurrencyBtnBackground;

    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
      child: Container(
        width: AppSizes.currencyBtnHeight,
        height: AppSizes.currencyBtnHeight,
        decoration: BoxDecoration(
          color: btnBg,
          borderRadius: AppSizes.brLarge,
          border: Border.all(color: borderColor),
        ),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          size: AppSizes.iconSmall + AppSizes.p4,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
