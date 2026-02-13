import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../store/settings_provider.dart';
import '../../models/settings.dart';
import '../../i18n/app_localizations.dart';
import '../../config/app_constants.dart';
import '../common/cancel_button.dart';
import '../common/app_modal.dart';

/// Settings Title Component
/// Displays settings title and author website link
class SettingTitle extends StatelessWidget {
  const SettingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;
        final appLocalizations = AppLocalizations.of(context);

        return _buildTitle(context, settings, appLocalizations);
      },
    );
  }

  Widget _buildTitle(BuildContext context, Settings settings, AppLocalizations appLocalizations) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: LayoutConstants.largeSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              appLocalizations.t('settings', settings.language),
              style: AppTextStyles.title,
            ),
          ),
          InkWell(
            onTap: () => _showAboutDialog(context),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Text(
              appLocalizations.t('about_app', settings.language),
              style: AppTextStyles.labelPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWebsite(BuildContext context) async {
    final Uri url = Uri.parse('https://stand.homes');
    if (!await launchUrl(url)) {
      if (context.mounted) {
        final settings = context.read<SettingsProvider>().settings;
        final appLocalizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.t('cannot_open_website', settings.language))),
        );
      }
    }
  }

  Future<void> _launchGithub(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/Stand404/HypnosisAPP-New');
    if (!await launchUrl(url)) {
      if (context.mounted) {
        final settings = context.read<SettingsProvider>().settings;
        final appLocalizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.t('cannot_open_website', settings.language))),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    final settings = context.read<SettingsProvider>().settings;
    final appLocalizations = AppLocalizations.of(context);
    const String appVersion = '1.0.0';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppModal(
          title: appLocalizations.t('about_app', settings.language),
          actions: [
            CancelButton(
              onPressed: () => Navigator.of(context).pop(),
              text: appLocalizations.t('close', settings.language),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Version
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Text(
                      '${appLocalizations.t('version', settings.language)}: ',
                      style: AppTextStyles.label,
                    ),
                    Text(
                      appVersion,
                      style: AppTextStyles.mediumText,
                    ),
                  ],
                ),
              ),
             
              // Privacy Policy
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.t('privacy_policy', settings.language),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appLocalizations.t('privacy_policy_content', settings.language),
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),
             
              // Author Website
              InkWell(
                onTap: () => _launchWebsite(context),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.language, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        appLocalizations.t('author_website', settings.language),
                        style: AppTextStyles.label.copyWith(
                          color: Color(StyleConstants.primaryColorValue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
             
              // Open Source
              InkWell(
                onTap: () => _launchGithub(context),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.code, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        appLocalizations.t('open_source', settings.language),
                        style: AppTextStyles.label.copyWith(
                          color: Color(StyleConstants.primaryColorValue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
