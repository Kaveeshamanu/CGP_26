import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:taprobana_trails/presentation/itinerary/widgets/activity_card.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme.dart';
import '../../core/utils/date_utils.dart' as app_date_utils;
import '../../data/models/destination.dart';
import '../../bloc/destination/destination_bloc.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/cards.dart';
import '../common/widgets/buttons.dart';
import 'widgets/festival_calendar.dart';

class CulturalInfoScreen extends StatefulWidget {
  final String? destinationId;

  const CulturalInfoScreen({
    super.key,
    this.destinationId,
  });

  @override
  State<CulturalInfoScreen> createState() => _CulturalInfoScreenState();
}

class _CulturalInfoScreenState extends State<CulturalInfoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentCarouselIndex = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Load destination data if destinationId is provided
    if (widget.destinationId != null) {
      context.read<DestinationBloc>().add(
        LoadDestinationDetails(destinationId: widget.destinationId!),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Cultural Information',
        showBackButton: true,
      ),
      body: BlocBuilder<DestinationBloc, DestinationState>(
        builder: (context, state) {
          if (state is DestinationsLoading) {
            return const Center(
              child: CircularProgressLoader(),
            );
          }
          
          if (state is DestinationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.destinationId != null) {
                        context.read<DestinationBloc>().add(
                          LoadDestinationDetails(destinationId: widget.destinationId!),
                        );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is DestinationDetailsLoaded && 
              state.destination.id == widget.destinationId) {
            final destination = state.destination;
            return _buildContent(destination);
          }
          
          // Default case: Sri Lankan general cultural info
          return _buildDefaultContent();
        },
      ),
    );
  }

  Widget _buildContent(Destination destination) {
    return Column(
      children: [
        // Cultural image carousel
        _buildImageCarousel(destination.culturalImages ?? _getDefaultCulturalImages()),
        
        // Tab bar
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: AppTheme.primaryColor,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Customs & Etiquette'),
            Tab(text: 'Festivals'),
            Tab(text: 'Cuisine'),
            Tab(text: 'Arts & Crafts'),
          ],
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(destination),
              _buildCustomsTab(destination),
              _buildFestivalsTab(destination),
              _buildCuisineTab(destination),
              _buildArtsCraftsTab(destination),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent() {
    // Create a default Destination object with Sri Lankan cultural information
    final sriLanka = Destination(
      id: 'sri_lanka',
      name: 'Sri Lanka',
      description: 'The island nation of Sri Lanka is a treasure trove of cultural richness, natural beauty, and historical significance.',
      culturalOverview: 'Sri Lanka boasts a vibrant multicultural society with influences from Sinhalese, Tamil, Moor, Burgher, Malay, and indigenous Vedda communities. The island\'s rich tapestry of traditions, religions, languages, and customs has evolved over thousands of years, creating a unique cultural landscape.',
      customs: [
        'Remove shoes before entering temples and homes',
        'Dress modestly when visiting religious sites (cover shoulders and knees)',
        'Use your right hand for giving, receiving, eating, and shaking hands',
        'Public displays of affection are frowned upon',
        'It\'s customary to greet with "Ayubowan" (Sinhala) or "Vanakkam" (Tamil) with palms pressed together',
        'Always ask permission before photographing people',
        'Respect for elders is very important in Sri Lankan culture'
      ],
      festivals: [
        {
          'name': 'Sinhala and Tamil New Year',
          'date': 'April 13-14',
          'description': 'The most important cultural festival in Sri Lanka celebrating the new year for both Sinhala and Tamil communities with traditional games, customs, and special meals.'
        },
        {
          'name': 'Vesak',
          'date': 'May (Full moon)',
          'description': 'Commemorates Buddha\'s birth, enlightenment, and passing away. Streets are decorated with lanterns, pandals (large illustrated panels), and free food stalls called dansal.'
        },
        {
          'name': 'Kandy Esala Perahera',
          'date': 'July-August',
          'description': 'One of the oldest and grandest Buddhist festivals in Sri Lanka featuring dancers, jugglers, musicians, fire-breathers, and lavishly decorated elephants.'
        },
        {
          'name': 'Thai Pongal',
          'date': 'January 14',
          'description': 'Tamil harvest festival dedicated to the Sun God. Families cook pongal (a sweet rice dish) in clay pots and offer thanksgiving for a bountiful harvest.'
        },
      ],
      cuisineInfo: 'Sri Lankan cuisine is known for its complex flavors and abundant use of spices, coconut, and rice. The food has been influenced by colonial powers, foreign traders, and neighboring countries, particularly South India. Rice and curry is the staple diet, complemented by a variety of side dishes.',
      popularDishes: [
        {
          'name': 'Rice and Curry',
          'description': 'A staple meal consisting of rice served with multiple curries, sambols, and pickles.'
        },
        {
          'name': 'Hoppers (Appa)',
          'description': 'Bowl-shaped pancakes made from fermented rice flour and coconut milk, often served with an egg in the center.'
        },
        {
          'name': 'Kottu Roti',
          'description': 'A popular street food made by stir-frying chopped flatbread with spices, vegetables, and meat.'
        },
        {
          'name': 'String Hoppers',
          'description': 'Steamed rice noodles pressed into flat spirals, usually served for breakfast or dinner with curries.'
        },
        {
          'name': 'Lamprais',
          'description': 'Dutch-influenced dish of rice, meat, and sambol wrapped and baked in a banana leaf.'
        },
      ],
      artsCraftsInfo: 'Sri Lanka has a rich tradition of arts and crafts, with techniques passed down through generations. The country is known for its diverse handicrafts that reflect local traditions, values, and aesthetics.',
      traditionalArts: [
        {
          'name': 'Mask Carving',
          'description': 'Traditional wooden masks used in cultural dances and rituals, especially in southern coastal regions.'
        },
        {
          'name': 'Batik',
          'description': 'Wax-resist dyeing technique used to create colorful designs on fabric, influenced by Indonesian traditions.'
        },
        {
          'name': 'Brasswork',
          'description': 'Intricate brass items including lamps, statues, and decorative pieces, often used in religious ceremonies.'
        },
        {
          'name': 'Lace Making',
          'description': 'Known as Beeralu, this Portuguese-influenced craft involves weaving intricate patterns with multiple wooden bobbins.'
        },
      ],
      languageInfo: 'Sinhala and Tamil are the official languages of Sri Lanka, with English widely used in government and business.',
      religionInfo: 'Buddhism is the majority religion (70%), followed by Hinduism (12.6%), Islam (9.7%), and Christianity (7.6%).',
      culturalImages: _getDefaultCulturalImages(),
    );
    
    return _buildContent(sriLanka);
  }

  List<String> _getDefaultCulturalImages() {
    // In a real app, these would be network image URLs
    // For this demo, we're using placeholders
    return [
      'https://example.com/images/sri_lanka_culture1.jpg',
      'https://example.com/images/sri_lanka_culture2.jpg',
      'https://example.com/images/sri_lanka_culture3.jpg',
      'https://example.com/images/sri_lanka_culture4.jpg',
      'https://example.com/images/sri_lanka_culture5.jpg',
    ];
  }

  Widget _buildImageCarousel(List<String> images) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          items: images.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselIndex == entry.key
                    ? AppTheme.primaryColor
                    : Colors.grey.withOpacity(0.4),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOverviewTab(Destination destination) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            destination.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            destination.culturalOverview ?? 
            'Cultural information for ${destination.name} is not available at this time.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (destination.languageInfo != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Languages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              destination.languageInfo!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
          if (destination.religionInfo != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Religion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              destination.religionInfo!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to translator screen
                    Navigator.pushNamed(
                      context, 
                      '/translator',
                      arguments: {'destinationId': destination.id},
                    );
                  },
                  icon: const Icon(Icons.translate),
                  label: const Text('Translator'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomsTab(Destination destination) {
    final customs = destination.customs ?? [];
    
    if (customs.isEmpty) {
      return Center(
        child: Text(
          'No customs information available for ${destination.name}.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customs & Etiquette',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Understanding local customs will help you navigate social situations respectfully and integrate more deeply with the culture.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          ...customs.map((custom) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      custom,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'When in doubt...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Observe what locals are doing and follow their lead. If unsure about appropriate behavior, it\'s always better to ask respectfully than to inadvertently cause offense.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalsTab(Destination destination) {
    final festivals = destination.festivals ?? [];
    
    if (festivals.isEmpty) {
      return Center(
        child: Text(
          'No festival information available for ${destination.name}.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    // Convert festivals to required format for the FestivalCalendar widget
    final formattedFestivals = festivals.map((festival) {
      return {
        'name': festival['name'],
        'date': festival['date'],
        'description': festival['description'],
      };
    }).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Festival Calendar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Experience the vibrant cultural celebrations throughout the year.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          
          // Festival calendar widget
          FestivalCalendar(
            festivals: formattedFestivals,
            onFestivalTap: (festival) {
              // Show detailed festival information
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => _buildFestivalDetails(festival),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalDetails(Map<String, dynamic> festival) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  festival['name'] ?? 'Festival',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    festival['date'] ?? 'Date unknown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  festival['description'] ?? 'No description available.',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    // Add to itinerary or calendar
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Festival added to your travel plan'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_task),
                  label: const Text('Add to My Trip'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCuisineTab(Destination destination) {
    final dishes = destination.popularDishes ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Local Cuisine',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            destination.cuisineInfo ?? 
            'Cuisine information for ${destination.name} is not available at this time.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          if (dishes.isNotEmpty) ...[
            const Text(
              'Popular Dishes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...dishes.map((dish) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish['name'] ?? 'Unknown dish',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dish['description'] ?? 'No description available.',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
          
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to restaurant listings
              Navigator.pushNamed(
                context,
                '/restaurants',
                arguments: {'destinationId': destination.id},
              );
            },
            icon: const Icon(Icons.restaurant),
            label: const Text('Find Local Restaurants'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtsCraftsTab(Destination destination) {
    final arts = destination.traditionalArts ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Arts & Crafts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            destination.artsCraftsInfo ?? 
            'Arts and crafts information for ${destination.name} is not available at this time.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          
          if (arts.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Traditional Arts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...arts.map((art) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    art['name'] ?? 'Unknown art form',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.all(16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      art['description'] ?? 'No description available.',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Shopping Tip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Look for authentic handcrafted souvenirs to support local artisans. The best places to find genuine handicrafts are local markets, government-approved craft shops, and cultural centers.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to shopping locations
                    Navigator.pushNamed(
                      context,
                      '/shopping',
                      arguments: {'destinationId': destination.id},
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Find Craft Markets'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}