import 'package:flutter/material.dart';
import 'dart:html' as html;

import '../data/demo_event_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page.dart';
import '../widgets/header_title.dart';

class HotelGalleryScreen extends StatelessWidget {
  const HotelGalleryScreen({super.key});

  static const String hotelAddress =
      'Vişnezade, Acısu Sokak No:19, Beşiktaş / İstanbul';

  static const String mapUrl =
      'https://www.google.com/maps/search/?api=1&query=Swissotel+The+Bosphorus+Istanbul';

  void openMap() {
    html.window.open(mapUrl, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppPage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackHeader(
                title: 'Konaklama Galerisi',
                subtitle: 'Otel fotoğrafları, ulaşım ve yakın çevre',
              ),
              const SizedBox(height: 18),

              HotelHeroCard(
                onOpenMap: openMap,
              ),

              const SizedBox(height: 16),

              CompactHotelPhotoGrid(
                photos: demoHotelPhotos,
              ),

              const SizedBox(height: 16),

              HotelMapCard(
                onOpenMap: openMap,
              ),

              const SizedBox(height: 16),

              const NearbyHotelPlacesCard(),

              const SizedBox(height: 16),

              const FeaturedNearbyLocationsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class HotelHeroCard extends StatelessWidget {
  final VoidCallback onOpenMap;

  const HotelHeroCard({
    super.key,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final String heroImage =
        demoHotelPhotos.isNotEmpty ? demoHotelPhotos.first : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        height: 210,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (heroImage.isNotEmpty)
              Image.asset(
                heroImage,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.06),
                    Colors.black.withOpacity(0.24),
                    Colors.black.withOpacity(0.74),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      HotelBadge(
                        icon: Icons.hotel_rounded,
                        label: '5 yıldızlı otel',
                      ),
                      HotelBadge(
                        icon: Icons.location_on_rounded,
                        label: 'Beşiktaş',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    demoGuest.hotelName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.06,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${demoHotelPhotos.length} fotoğraf • İstanbul Boğazı bölgesi',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.74),
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 14,
              top: 14,
              child: GestureDetector(
                onTap: onOpenMap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.42),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.map_rounded,
                        color: AppColors.champagne,
                        size: 17,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Harita',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HotelBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const HotelBadge({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.13),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.champagne,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.8,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class CompactHotelPhotoGrid extends StatelessWidget {
  final List<String> photos;

  const CompactHotelPhotoGrid({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> visiblePhotos = photos.take(6).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: hotelGlassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            icon: Icons.photo_library_rounded,
            title: 'Otel Fotoğrafları',
            subtitle: '${visiblePhotos.length} fotoğraf',
          ),
          const SizedBox(height: 13),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visiblePhotos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
              childAspectRatio: 1.12,
            ),
            itemBuilder: (context, index) {
              return HotelPhotoCard(
                imagePath: visiblePhotos[index],
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }
}

class HotelMapCard extends StatelessWidget {
  final VoidCallback onOpenMap;

  const HotelMapCard({
    super.key,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: hotelGlassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            icon: Icons.route_rounded,
            title: 'Otele Ulaşım',
            subtitle: 'Harita, transfer ve konum bilgileri',
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 116,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1D4ED8).withOpacity(0.42),
                  const Color(0xFF111827).withOpacity(0.82),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.13),
                    ),
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    color: AppColors.champagne,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        HotelGalleryScreen.hotelAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.28,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Transfer noktası: otel ana giriş / resepsiyon önü',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MapActionButton(
                  icon: Icons.map_rounded,
                  title: 'Haritada Aç',
                  onTap: onOpenMap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MapActionButton(
                  icon: Icons.directions_rounded,
                  title: 'Yol Tarifi Al',
                  onTap: onOpenMap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NearbyHotelPlacesCard extends StatelessWidget {
  const NearbyHotelPlacesCard({super.key});

  @override
  Widget build(BuildContext context) {
    const List<NearbyItem> items = [
      NearbyItem(
        icon: Icons.local_pharmacy_rounded,
        title: 'Eczane',
        subtitle: 'Yakın çevrede açık eczaneler',
        color: Color(0xFF34D399),
        mapQuery: 'pharmacy near Swissotel The Bosphorus Istanbul',
      ),
      NearbyItem(
        icon: Icons.restaurant_rounded,
        title: 'Restoran',
        subtitle: 'Yemek ve akşam alternatifleri',
        color: Color(0xFFF59E0B),
        mapQuery: 'restaurants near Swissotel The Bosphorus Istanbul',
      ),
      NearbyItem(
        icon: Icons.local_cafe_rounded,
        title: 'Kafe',
        subtitle: 'Kısa mola ve kahve noktaları',
        color: Color(0xFF60A5FA),
        mapQuery: 'cafes near Swissotel The Bosphorus Istanbul',
      ),
      NearbyItem(
        icon: Icons.shopping_bag_rounded,
        title: 'AVM',
        subtitle: 'Nişantaşı ve Zorlu Center',
        color: Color(0xFFA78BFA),
        mapQuery: 'shopping mall near Swissotel The Bosphorus Istanbul',
      ),
      NearbyItem(
        icon: Icons.account_balance_rounded,
        title: 'ATM',
        subtitle: 'Banka ve para çekme noktaları',
        color: Color(0xFFFB7185),
        mapQuery: 'ATM near Swissotel The Bosphorus Istanbul',
      ),
      NearbyItem(
        icon: Icons.camera_alt_rounded,
        title: 'Gezilecek Yer',
        subtitle: 'Dolmabahçe, Maçka, Ortaköy',
        color: AppColors.champagne,
        mapQuery: 'tourist attractions near Swissotel The Bosphorus Istanbul',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: hotelGlassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            icon: Icons.near_me_rounded,
            title: 'Yakında Neler Var?',
            subtitle: 'Otel çevresinde ihtiyaç duyabileceğiniz noktalar',
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
              childAspectRatio: 1.34,
            ),
            itemBuilder: (context, index) {
              return NearbyTile(item: items[index]);
            },
          ),
        ],
      ),
    );
  }
}

class FeaturedNearbyLocationsCard extends StatelessWidget {
  const FeaturedNearbyLocationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> locations = [
      'Dolmabahçe Sarayı',
      'Maçka Parkı',
      'Nişantaşı',
      'Beşiktaş',
      'Ortaköy',
      'Zorlu Center',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: hotelGlassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            icon: Icons.place_rounded,
            title: 'Öne Çıkan Yakın Noktalar',
            subtitle: 'Boş zamanlar için kısa öneriler',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: locations.map((location) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.09),
                  ),
                ),
                child: Text(
                  location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.2,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.champagne.withOpacity(0.13),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.champagne.withOpacity(0.16),
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.champagne,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.54),
                  fontSize: 11.8,
                  height: 1.26,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MapActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MapActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.champagne,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.champagne.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF111827),
              size: 19,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 12.8,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NearbyItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String mapQuery;

  const NearbyItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.mapQuery,
  });
}

class NearbyTile extends StatelessWidget {
  final NearbyItem item;

  const NearbyTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final String encodedQuery = Uri.encodeComponent(item.mapQuery);
        html.window.open(
          'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
          '_blank',
        );
      },
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(0.085),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 19,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.white.withOpacity(0.38),
                  size: 16,
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.2,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.52),
                fontSize: 10.8,
                height: 1.22,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HotelPhotoCard extends StatelessWidget {
  final String imagePath;
  final int index;

  const HotelPhotoCard({
    super.key,
    required this.imagePath,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.86),
          builder: (_) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.46),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.24),
              blurRadius: 16,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration hotelGlassDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(28),
    color: Colors.white.withOpacity(0.065),
    border: Border.all(
      color: Colors.white.withOpacity(0.095),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.24),
        blurRadius: 24,
        offset: const Offset(0, 14),
      ),
    ],
  );
}