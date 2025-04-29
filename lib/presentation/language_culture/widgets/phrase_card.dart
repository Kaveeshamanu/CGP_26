import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../config/theme.dart';

class PhraseCard extends StatelessWidget {
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final VoidCallback? onCopy;
  final VoidCallback? onTapToSpeak;
  final VoidCallback? onAddToFavorites;
  final bool isFavorite;

  const PhraseCard({
    super.key,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.onCopy,
    this.onTapToSpeak,
    this.onAddToFavorites,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSourceSection(),
            const Divider(height: 24),
            _buildTranslationSection(),
            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sourceLanguage,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sourceText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTranslationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          targetLanguage,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          translatedText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onTapToSpeak != null)
          _buildActionButton(
            icon: FontAwesomeIcons.volumeHigh,
            tooltip: 'Listen',
            onPressed: onTapToSpeak,
          ),
        if (onCopy != null)
          _buildActionButton(
            icon: Icons.content_copy,
            tooltip: 'Copy to clipboard',
            onPressed: onCopy,
          ),
        if (onAddToFavorites != null)
          _buildActionButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: onAddToFavorites,
            color: isFavorite ? Colors.red : null,
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(
          icon,
          size: 18,
          color: color ?? Colors.grey[700],
        ),
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        padding: EdgeInsets.zero,
        splashRadius: 24,
      ),
    );
  }
}

class PhraseCategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final int phraseCount;
  final VoidCallback onTap;

  const PhraseCategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.phraseCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$phraseCount phrases',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PhraseListItem extends StatelessWidget {
  final String sourceText;
  final String? translatedText;
  final VoidCallback onTap;
  final bool isFavorite;

  const PhraseListItem({
    super.key,
    required this.sourceText,
    this.translatedText,
    required this.onTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(sourceText),
      subtitle: translatedText != null ? Text(translatedText!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFavorite)
            Icon(
              Icons.favorite,
              color: Colors.red,
              size: 18,
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}