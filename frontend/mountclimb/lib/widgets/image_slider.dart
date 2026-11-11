import 'package:flutter/material.dart';

// Widget slider foto menggunakan PageView bawaan Flutter (tanpa library
// tambahan). Dibuat sebagai StatelessWidget: halaman aktif untuk indikator
// titik dikelola lewat ValueNotifier + ValueListenableBuilder bawaan
// Flutter, jadi tidak perlu StatefulWidget/State sama sekali.
class ImageSlider extends StatelessWidget {
  final List<String> images;
  final double height;
  final BorderRadius borderRadius;
  final PageController _controller = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  ImageSlider({
    super.key,
    required this.images,
    this.height = 220,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: borderRadius,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (index) {
                _currentPage.value = index;
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Placeholder jika gambar belum tersedia di assets.
                    return Container(
                      color: Colors.blue.shade100,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.terrain,
                        size: 48,
                        color: Colors.blue.shade400,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<int>(
          valueListenable: _currentPage,
          builder: (context, current, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: current == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: current == index
                        ? Colors.blue.shade600
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
