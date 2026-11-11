import 'package:flutter/material.dart';
import '../models/mountain.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/responsive_center.dart';
import 'mountain_detail_page.dart';

class ExplorePage extends StatefulWidget {
  final String initialQuery;

  const ExplorePage({super.key, this.initialQuery = ''});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late final TextEditingController _searchController;
  String _selectedCategory = 'Semua';

  static const List<String> _categories = ['Semua', 'Mudah', 'Sedang', 'Sulit'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Mountain> get _filteredMountains {
    final query = _searchController.text.trim().toLowerCase();

    return dummyMountains.where((mountain) {
      final matchesCategory = _selectedCategory == 'Semua' || mountain.difficulty == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          mountain.name.toLowerCase().contains(query) ||
          mountain.location.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredMountains;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              'Explore',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Temukan gunung impianmu berikutnya',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            // Search bar fungsional: mengetik langsung memfilter daftar di bawah
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama gunung atau lokasi...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    InkWell(
                      onTap: () => setState(() => _searchController.clear()),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Kategori: menekan chip beneran memfilter tingkat kesulitan
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categories.map((category) {
                  return _CategoryChip(
                    label: category,
                    selected: _selectedCategory == category,
                    onTap: () => setState(() => _selectedCategory = category),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 52, color: AppColors.iconMuted),
                    const SizedBox(height: 12),
                    Text(
                      'Gunung tidak ditemukan',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coba kata kunci atau kategori lain.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final mountain = results[index];
                  return _MountainListTile(
                    mountain: mountain,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MountainDetailPage(mountain: mountain)),
                      );
                    },
                  );
                },
              ),
          ],
          ),
        ),
      ),
      bottomNavigationBar: ResponsiveCenter(expandHeight: false, child: const BottomNav(currentIndex: 1)),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderAlt),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _MountainListTile extends StatelessWidget {
  final Mountain mountain;
  final VoidCallback onTap;

  const _MountainListTile({required this.mountain, required this.onTap});

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromRight = str.length - i;
      buffer.write(str[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 84,
                height: 84,
                child: Image.asset(
                  mountain.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.placeholderBg,
                    alignment: Alignment.center,
                    child: Icon(Icons.terrain, color: AppColors.placeholderIcon),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mountain.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          mountain.location,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: AppColors.accentGold),
                      const SizedBox(width: 2),
                      Text(mountain.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mountain.difficulty,
                          style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              _formatPrice(mountain.price),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
