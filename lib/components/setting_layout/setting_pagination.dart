import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/settings_provider.dart';
import '../../models/settings.dart';
import '../../i18n/app_localizations.dart';
import '../../config/app_constants.dart';

/// Settings Pagination Component
/// Displays page title and navigation buttons
class SettingPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const SettingPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;
        final appLocalizations = AppLocalizations.of(context);

        return _buildPagination(settings, appLocalizations);
      },
    );
  }

  Widget _buildPagination(Settings settings, AppLocalizations appLocalizations) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: LayoutConstants.largeSpacing, vertical: LayoutConstants.extraLargeSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPreviousPage,
            icon: Icon(Icons.chevron_left, color: Color(StyleConstants.primaryColorValue)),
          ),
          Text(
            _getPageTitle(settings, appLocalizations),
            style: AppTextStyles.title20,
          ),
          IconButton(
            onPressed: onNextPage,
            icon: Icon(Icons.chevron_right, color: Color(StyleConstants.primaryColorValue)),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(Settings settings, AppLocalizations appLocalizations) {
    switch (currentPage) {
      case 0:
        return appLocalizations.t('global_settings', settings.language);
      case 1:
        return appLocalizations.t('animation_settings', settings.language);
      case 2:
        return appLocalizations.t('text_display', settings.language);
      case 3:
        return appLocalizations.t('center_settings', settings.language);
      default:
        return '';
    }
  }
}
