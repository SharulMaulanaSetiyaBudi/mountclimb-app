// Model data gunung untuk aplikasi MountClimb.
// Data masih berupa dummy/static karena tugas ini berfokus pada UI & navigation.

class Mountain {
  final String id;
  final String name;
  final String location;
  final int heightMeters;
  final double rating;
  final int price; // harga tiket dalam rupiah
  final String difficulty; // Mudah, Sedang, Sulit
  final String description;
  final String hikingInfo;
  final List<String> images; // untuk image slider di detail page
  final String thumbnail; // gambar utama untuk card
  final int dailyQuota; // kuota pendaki maksimal per hari (kebijakan TN/basecamp)

  const Mountain({
    required this.id,
    required this.name,
    required this.location,
    required this.heightMeters,
    required this.rating,
    required this.price,
    required this.difficulty,
    required this.description,
    required this.hikingInfo,
    required this.images,
    required this.thumbnail,
    this.dailyQuota = 500,
  });

  // Dari JSON Laravel (GET /api/mountains).
  factory Mountain.fromJson(Map<String, dynamic> j) => Mountain(
        id: j['id'].toString(),
        name: j['name'].toString(),
        location: j['location'].toString(),
        heightMeters: (j['height_meters'] as num).toInt(),
        rating: double.tryParse(j['rating'].toString()) ?? 0,
        price: (j['price'] as num).toInt(),
        difficulty: j['difficulty'].toString(),
        description: j['description'].toString(),
        hikingInfo: j['hiking_info'].toString(),
        images: (j['images'] as List).map((e) => e.toString()).toList(),
        thumbnail: j['thumbnail'].toString(),
        dailyQuota: (j['daily_quota'] as num?)?.toInt() ?? 500,
      );
}

// Kuota harian pendakian belum tersambung ke sistem booking sungguhan
// (mis. SIMAKSI/e-booking Taman Nasional), jadi sisa kuota per tanggal
// dihitung secara deterministik (bukan acak murni) dari kombinasi tanggal
// & gunung — supaya tiap kali tanggal yang sama dibuka, angkanya konsisten
// selama sesi aplikasi berjalan, mirip seperti membaca data sungguhan.
// Begitu backend/API kuota resmi tersedia, cukup ganti isi fungsi ini
// tanpa mengubah UI yang memanggilnya.
int remainingQuotaFor(Mountain mountain, DateTime date) {
  final seed = mountain.id.hashCode ^ (date.year * 10000 + date.month * 100 + date.day);
  final usedRatio = 0.15 + (seed.abs() % 70) / 100; // terpakai 15%-85%
  final remaining = (mountain.dailyQuota * (1 - usedRatio)).round();
  return remaining.clamp(0, mountain.dailyQuota);
}

// Data dummy 5 gunung populer di Indonesia.
// Pastikan file gambar berikut sudah ditambahkan ke assets/images/:
// semeru.jpg, rinjani.jpg, merbabu.jpg, bromo.jpg, papandayan.jpg
final List<Mountain> dummyMountains = [
  const Mountain(
    id: 'semeru',
    name: 'Gunung Semeru',
    location: 'Jawa Timur',
    heightMeters: 3676,
    rating: 4.8,
    price: 90000,
    difficulty: 'Sulit',
    description:
        'Gunung tertinggi di Pulau Jawa dengan puncak Mahameru yang legendaris. '
        'Jalur pendakian melewati savana luas dan Ranu Kumbolo yang memukau.',
    hikingInfo:
        'Estimasi pendakian 3-4 hari. Wajib membawa perlengkapan lengkap dan '
        'mengikuti briefing dari petugas Taman Nasional Bromo Tengger Semeru.',
    images: [
      'assets/images/semeru.jpg',
      'assets/images/bromo.jpg',
      'assets/images/rinjani.jpg',
    ],
    thumbnail: 'assets/images/semeru.jpg',
  ),
  const Mountain(
    id: 'rinjani',
    name: 'Gunung Rinjani',
    location: 'Lombok, NTB',
    heightMeters: 3726,
    rating: 4.9,
    price: 150000,
    difficulty: 'Sulit',
    description:
        'Gunung berapi tertinggi kedua di Indonesia dengan danau kawah Segara '
        'Anak yang menakjubkan. Favorit para pendaki lokal maupun mancanegara.',
    hikingInfo:
        'Estimasi pendakian 2-3 hari. Jalur Sembalun dan Senaru adalah rute '
        'paling populer bagi pendaki pemula hingga berpengalaman.',
    images: [
      'assets/images/rinjani.jpg',
      'assets/images/merbabu.jpg',
      'assets/images/papandayan.jpg',
    ],
    thumbnail: 'assets/images/rinjani.jpg',
  ),
  const Mountain(
    id: 'merbabu',
    name: 'Gunung Merbabu',
    location: 'Jawa Tengah',
    heightMeters: 3145,
    rating: 4.6,
    price: 25000,
    difficulty: 'Sedang',
    description:
        'Gunung ramah pemula dengan padang sabana hijau yang luas dan '
        'pemandangan Gunung Merapi dari puncaknya.',
    hikingInfo:
        'Estimasi pendakian 1-2 hari. Cocok untuk pendaki pemula yang ingin '
        'mencoba pengalaman camping di ketinggian.',
    images: [
      'assets/images/merbabu.jpg',
      'assets/images/semeru.jpg',
      'assets/images/bromo.jpg',
    ],
    thumbnail: 'assets/images/merbabu.jpg',
  ),
  const Mountain(
    id: 'bromo',
    name: 'Gunung Bromo',
    location: 'Jawa Timur',
    heightMeters: 2329,
    rating: 4.7,
    price: 35000,
    difficulty: 'Mudah',
    description:
        'Ikon wisata Jawa Timur dengan lautan pasir dan sunrise paling '
        'terkenal di Indonesia. Cocok untuk pendakian singkat bersama keluarga.',
    hikingInfo:
        'Estimasi pendakian setengah hari. Akses mudah dengan kendaraan '
        'hingga area lautan pasir sebelum jalan kaki ke kawah.',
    images: [
      'assets/images/bromo.jpg',
      'assets/images/papandayan.jpg',
      'assets/images/rinjani.jpg',
    ],
    thumbnail: 'assets/images/bromo.jpg',
  ),
  const Mountain(
    id: 'papandayan',
    name: 'Gunung Papandayan',
    location: 'Garut, Jawa Barat',
    heightMeters: 2665,
    rating: 4.5,
    price: 20000,
    difficulty: 'Mudah',
    description:
        'Gunung dengan kawah aktif dan Hutan Mati yang unik. Jalur pendakian '
        'landai membuatnya cocok untuk pendaki pemula maupun keluarga.',
    hikingInfo:
        'Estimasi pendakian 1 hari atau camping semalam di Pondok Saladah. '
        'Akses kendaraan hingga dekat area kawah.',
    images: [
      'assets/images/papandayan.jpg',
      'assets/images/merbabu.jpg',
      'assets/images/semeru.jpg',
    ],
    thumbnail: 'assets/images/papandayan.jpg',
  ),
];
