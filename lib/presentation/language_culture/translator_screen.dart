import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:country_picker/country_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../core/utils/connectivity.dart';
import '../../data/models/destination.dart';
import '../../bloc/destination/destination_bloc.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/buttons.dart';
import 'widgets/phrase_card.dart';

class TranslatorScreen extends StatefulWidget {
  final String? destinationId;

  const TranslatorScreen({
    super.key,
    this.destinationId,
  });

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  
  late TabController _tabController;
  String _selectedSourceLanguage = 'English';
  String _selectedTargetLanguage = 'Sinhala';
  bool _isTranslating = false;
  bool _hasTranslated = false;
  
  final List<String> _recentTranslations = [];
  List<Map<String, String>> _commonPhrases = [];
  final List<String> _favoriteTranslations = [];
  
  Destination? _destination;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load destination data if destinationId is provided
    if (widget.destinationId != null) {
      context.read<DestinationBloc>().add(
        LoadDestinationDetails(destinationId: widget.destinationId!),
      );
    }
    
    // Initialize with common phrases for Sri Lanka
    _commonPhrases = [
      {
        'english': 'Hello',
        'sinhala': 'ආයුබෝවන් (Ayubowan)',
        'tamil': 'வணக்கம் (Vanakkam)',
      },
      {
        'english': 'Thank you',
        'sinhala': 'ස්තූතියි (Sthuthi)',
        'tamil': 'நன்றி (Nandri)',
      },
      {
        'english': 'Yes',
        'sinhala': 'ඔව් (Ow)',
        'tamil': 'ஆம் (Aam)',
      },
      {
        'english': 'No',
        'sinhala': 'නැහැ (Nehe)',
        'tamil': 'இல்லை (Illai)',
      },
      {
        'english': 'Excuse me',
        'sinhala': 'සමාවෙන්න (Samaavenna)',
        'tamil': 'மன்னிக்கவும் (Mannikkavum)',
      },
      {
        'english': 'How much is this?',
        'sinhala': 'මේක කීයද? (Meka keeyada)',
        'tamil': 'இது எவ்வளவு? (Idhu evvalavu)',
      },
      {
        'english': 'Where is the bathroom?',
        'sinhala': 'වැසිකිළිය කොහෙද? (Vaesikiliya koheda)',
        'tamil': 'கழிவறை எங்கே? (Kazhivarai enge)',
      },
      {
        'english': 'I don\'t understand',
        'sinhala': 'මට තේරෙන්නෑ (Mata therenne)',
        'tamil': 'எனக்கு புரியவில்லை (Enakku puriyavillai)',
      },
      {
        'english': 'Help!',
        'sinhala': 'උදව් කරන්න! (Udau karanna)',
        'tamil': 'உதவி! (Udhavi)',
      },
      {
        'english': 'Good morning',
        'sinhala': 'සුභ උදෑසනක් (Suba Udaasanak)',
        'tamil': 'காலை வணக்கம் (Kaalai Vanakkam)',
      },
    ];
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _translateText() async {
    if (_inputController.text.isEmpty) return;

    final connectivityService = ConnectivityService();
    final hasConnectivity = await connectivityService.checkConnectivity();
    
    if (!hasConnectivity) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Translation requires internet access.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    // Simulating API call with delay
    // In a real app, you would call a translation API service here
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock translation result based on common phrases
    String translatedText = '';
    
    final inputText = _inputController.text.toLowerCase().trim();
    
    for (final phrase in _commonPhrases) {
      if (phrase['english']?.toLowerCase() == inputText) {
        if (_selectedTargetLanguage == 'Sinhala') {
          translatedText = phrase['sinhala'] ?? '';
        } else if (_selectedTargetLanguage == 'Tamil') {
          translatedText = phrase['tamil'] ?? '';
        }
        break;
      }
    }

    // If not found in common phrases, generate a mock translation
    if (translatedText.isEmpty) {
      if (_selectedTargetLanguage == 'Sinhala') {
        translatedText = '${_inputController.text} (in Sinhala)';
      } else if (_selectedTargetLanguage == 'Tamil') {
        translatedText = '${_inputController.text} (in Tamil)';
      } else {
        translatedText = '${_inputController.text} (in $_selectedTargetLanguage)';
      }
    }

    setState(() {
      _outputController.text = translatedText;
      _isTranslating = false;
      _hasTranslated = true;
      
      // Add to recent translations if not already there
      final newTranslation = '${_inputController.text} → $translatedText';
      if (!_recentTranslations.contains(newTranslation)) {
        _recentTranslations.insert(0, newTranslation);
        // Keep only last 10 translations
        if (_recentTranslations.length > 10) {
          _recentTranslations.removeLast();
        }
      }
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _selectedSourceLanguage;
      _selectedSourceLanguage = _selectedTargetLanguage;
      _selectedTargetLanguage = temp;
      
      if (_hasTranslated) {
        // Swap text in input and output fields
        final tempText = _inputController.text;
        _inputController.text = _outputController.text;
        _outputController.text = tempText;
      }
    });
  }

  void _copyTranslation() {
    if (_outputController.text.isEmpty) return;
    
    Clipboard.setData(ClipboardData(text: _outputController.text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Translation copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  void _shareTranslation() {
    if (_outputController.text.isEmpty) return;
    
    final textToShare = '${_inputController.text} ($_selectedSourceLanguage)\n'
        '${_outputController.text} ($_selectedTargetLanguage)\n\n'
        'Translated with Taprobana Trails';
    
    Share.share(textToShare);
  }

  void _toggleFavorite() {
    if (!_hasTranslated) return;
    
    final currentTranslation = '${_inputController.text} → ${_outputController.text}';
    
    setState(() {
      if (_favoriteTranslations.contains(currentTranslation)) {
        _favoriteTranslations.remove(currentTranslation);
      } else {
        _favoriteTranslations.add(currentTranslation);
      }
    });
  }

  bool _isCurrentTranslationFavorite() {
    if (!_hasTranslated) return false;
    
    final currentTranslation = '${_inputController.text} → ${_outputController.text}';
    return _favoriteTranslations.contains(currentTranslation);
  }

  void _clearTranslation() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
      _hasTranslated = false;
    });
  }

  void _selectSourceLanguage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildLanguageSelector(
        title: 'Select Source Language',
        currentLanguage: _selectedSourceLanguage,
        onSelect: (language) {
          setState(() {
            _selectedSourceLanguage = language;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _selectTargetLanguage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildLanguageSelector(
        title: 'Select Target Language',
        currentLanguage: _selectedTargetLanguage,
        onSelect: (language) {
          setState(() {
            _selectedTargetLanguage = language;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildLanguageSelector({
    required String title,
    required String currentLanguage,
    required Function(String) onSelect,
  }) {
    // For this demo, we'll focus on Sri Lankan languages and a few common tourist languages
    final languages = [
      'English',
      'Sinhala',
      'Tamil',
      'Hindi',
      'Chinese',
      'German',
      'French',
      'Japanese',
      'Korean',
      'Russian',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              final isSelected = language == currentLanguage;
              
              return ListTile(
                title: Text(language),
                trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                selected: isSelected,
                selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
                onTap: () => onSelect(language),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Translator',
        showBackButton: true,
      ),
      body: BlocConsumer<DestinationBloc, DestinationState>(
        listener: (context, state) {
          if (state is DestinationDetailsLoaded && 
              state.destination.id == widget.destinationId) {
            setState(() {
              _destination = state.destination;
              
              // If destination has specified languages, set the target language
              if (_destination?.languages != null && 
                  _destination!.languages!.isNotEmpty) {
                _selectedTargetLanguage = _destination!.languages!.first;
              }
            });
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Language selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectSourceLanguage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _selectedSourceLanguage,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: _swapLanguages,
                      color: AppTheme.primaryColor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectTargetLanguage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _selectedTargetLanguage,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Input and output fields
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Input text field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 8),
                              child: Text(
                                _selectedSourceLanguage,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _inputController,
                              maxLines: 5,
                              minLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Enter text to translate',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              onChanged: (value) {
                                if (_hasTranslated && value.isEmpty) {
                                  setState(() {
                                    _outputController.clear();
                                    _hasTranslated = false;
                                  });
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: _inputController.text.isNotEmpty 
                                        ? _clearTranslation 
                                        : null,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Translate button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _inputController.text.isNotEmpty
                              ? _translateText
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isTranslating
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Translate'),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Output text field
                      if (_hasTranslated || _outputController.text.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16, top: 8),
                                child: Text(
                                  _selectedTargetLanguage,
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _outputController,
                                maxLines: 5,
                                minLines: 3,
                                readOnly: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                  hintText: 'Translation will appear here',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _isCurrentTranslationFavorite()
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 20,
                                      ),
                                      onPressed: _hasTranslated ? _toggleFavorite : null,
                                      color: _isCurrentTranslationFavorite()
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.content_copy, size: 20),
                                      onPressed: _hasTranslated ? _copyTranslation : null,
                                      color: Colors.grey[600],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share, size: 20),
                                      onPressed: _hasTranslated ? _shareTranslation : null,
                                      color: Colors.grey[600],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                      const SizedBox(height: 24),
                      
                      // Tabs for phrases, history and favorites
                      TabBar(
                        controller: _tabController,
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: AppTheme.primaryColor,
                        tabs: const [
                          Tab(text: 'Common Phrases'),
                          Tab(text: 'History'),
                          Tab(text: 'Favorites'),
                        ],
                      ),
                      
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Common Phrases Tab
                            _buildCommonPhrasesTab(),
                            
                            // History Tab
                            _buildHistoryTab(),
                            
                            // Favorites Tab
                            _buildFavoritesTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommonPhrasesTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: _commonPhrases.length,
      itemBuilder: (context, index) {
        final phrase = _commonPhrases[index];
        final english = phrase['english'] ?? '';
        final translation = _selectedTargetLanguage == 'Sinhala' 
            ? phrase['sinhala'] 
            : _selectedTargetLanguage == 'Tamil'
                ? phrase['tamil']
                : 'Not available';
        
        return PhraseCard(
          sourceText: english,
          translatedText: translation ?? 'Not available',
          sourceLanguage: 'English',
          targetLanguage: _selectedTargetLanguage,
          onCopy: () {
            final textToCopy = '$english - $translation';
            Clipboard.setData(ClipboardData(text: textToCopy));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phrase copied to clipboard'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 1),
              ),
            );
          },
          onTapToSpeak: () {
            // Would implement text-to-speech here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Text-to-speech feature would play here'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_recentTranslations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No translation history yet',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: _recentTranslations.length,
      itemBuilder: (context, index) {
        final translation = _recentTranslations[index];
        final parts = translation.split(' → ');
        
        if (parts.length != 2) return const SizedBox.shrink();
        
        return ListTile(
          title: Text(parts[0]),
          subtitle: Text(
            parts[1],
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.content_copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: translation));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Translation copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            color: Colors.grey[600],
          ),
          onTap: () {
            setState(() {
              _inputController.text = parts[0];
              _outputController.text = parts[1];
              _hasTranslated = true;
            });
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    if (_favoriteTranslations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No favorite translations yet',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: _favoriteTranslations.length,
      itemBuilder: (context, index) {
        final translation = _favoriteTranslations[index];
        final parts = translation.split(' → ');
        
        if (parts.length != 2) return const SizedBox.shrink();
        
        return ListTile(
          title: Text(parts[0]),
          subtitle: Text(
            parts[1],
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.content_copy, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: translation));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Translation copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                color: Colors.grey[600],
              ),
              IconButton(
                icon: const Icon(Icons.favorite, size: 20),
                onPressed: () {
                  setState(() {
                    _favoriteTranslations.remove(translation);
                  });
                },
                color: Colors.red,
              ),
            ],
          ),
          onTap: () {
            setState(() {
              _inputController.text = parts[0];
              _outputController.text = parts[1];
              _hasTranslated = true;
            });
          },
        );
      },
    );
  }
}