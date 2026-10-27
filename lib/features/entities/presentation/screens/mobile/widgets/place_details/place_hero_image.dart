import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlaceHeroImage extends StatelessWidget {
  final String imageUrl;

  const PlaceHeroImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: kIsWeb ? 350 : 250,
        child: imageUrl.isNotEmpty ? _buildImage() : _placeholder(),
      ),
    );
  }

  Widget _buildImage() {
    // En Web
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _loading();
        },
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    // En Móvil
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => _loading(),
      errorWidget: (context, url, error) => _placeholder(),
      maxHeightDiskCache: 800,
      maxWidthDiskCache: 800,
    );
  }

  Widget _loading() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.domain_rounded,
          size: 56,
          color: Color(0xFF00796B),
        ),
      ),
    );
  }
}
