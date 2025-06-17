import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';


// Models
import 'models/user_model.dart';
import 'models/landing_page_model.dart';
import 'models/rencana_model.dart';
import 'models/hotel_model.dart';
import 'models/vila_model.dart'; // ✅ Tambahkan import vila model

// Screens umum
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/login_signup/login_screen.dart';
import 'screens/login_signup/signup_screen.dart';
import 'widgets/home_navigation.dart';

// Screens admin
import 'admin/main_admin_screen.dart';
import 'admin/pages/dashboard/dashboard_page.dart';
import 'admin/pages/dashboard/ubah_landing_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale date format untuk intl, AGAR DateFormat('d MMM', 'id_ID') tidak error
  await initializeDateFormatting('id_ID', null);

  await Hive.initFlutter();

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(LandingPageModelAdapter().typeId)) {
    Hive.registerAdapter(LandingPageModelAdapter());
  }
  if (!Hive.isAdapterRegistered(RencanaModelAdapter().typeId)) {
    Hive.registerAdapter(RencanaModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HotelModelAdapter().typeId)) {
    Hive.registerAdapter(HotelModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HotelOptionsModelAdapter().typeId)) {
    Hive.registerAdapter(HotelOptionsModelAdapter());
  }
  // ✅ Tambahkan adapter vila
  if (!Hive.isAdapterRegistered(VilaModelAdapter().typeId)) {
    Hive.registerAdapter(VilaModelAdapter());
  }
  if (!Hive.isAdapterRegistered(VilaOptionsModelAdapter().typeId)) {
    Hive.registerAdapter(VilaOptionsModelAdapter());
  }

  // Hapus box untuk development/debug mode (reset data)
  if (kDebugMode) {
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('activeUserBox');
    await Hive.deleteBoxFromDisk('landingPageBox');
    await Hive.deleteBoxFromDisk('rencanaBox');
    await Hive.deleteBoxFromDisk('hotelBox');
    await Hive.deleteBoxFromDisk('hotelOptionsBox');
    await Hive.deleteBoxFromDisk('lokasiBox');
    await Hive.deleteBoxFromDisk('selectedLocationBox');
    // ✅ Tambahkan hapus box vila untuk debug
    await Hive.deleteBoxFromDisk('vilaBox');
    await Hive.deleteBoxFromDisk('vilaOptionsBox');
  }

  // Open all necessary boxes
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<UserModel>('activeUserBox');
  await Hive.openBox<LandingPageModel>('landingPageBox');
  await Hive.openBox<RencanaModel>('rencanaBox');
  await Hive.openBox<HotelModel>('hotelBox');
  await Hive.openBox<HotelOptionsModel>('hotelOptionsBox');
  final lokasiBox = await Hive.openBox('lokasiBox');
  final selectedLocationBox = await Hive.openBox('selectedLocationBox');
  // ✅ Buka box vila
  await Hive.openBox<VilaModel>('vilaBox');
  await Hive.openBox<VilaOptionsModel>('vilaOptionsBox');

  // Inisialisasi data user (kalau kosong)
  final userBox = Hive.box<UserModel>('users');
  if (userBox.isEmpty) {
    await userBox.addAll([
      UserModel(name: 'Admin', email: 'admin@gmail.com', password: 'admin123', role: 'admin'),
      UserModel(name: 'Dinda Aisa', email: 'user@gmail.com', password: '12345678', role: 'user'),
    ]);
  }

  // Inisialisasi data landing page (kalau kosong)
  final landingPageBox = Hive.box<LandingPageModel>('landingPageBox');
  if (landingPageBox.isEmpty) {
    landingPageBox.putAll({
      0: LandingPageModel(
        title: 'Siap jalan-jalan dan ciptakan pengalaman seru?',
        description: 'Dengan TripMate, atur perjalananmu jadi lebih gampang dan menyenangkan.',
        imageBytes: null,
      ),
      1: LandingPageModel(
        title: 'Rencanain trip tanpa ribet bareng TripMate!',
        description: 'Cukup beberapa langkah, dan liburan impianmu siap dijalankan.',
        imageBytes: null,
      ),
    });
  }

  // Inisialisasi data opsi hotel (kalau kosong)
  final hotelOptionsBox = Hive.box<HotelOptionsModel>('hotelOptionsBox');
  if (hotelOptionsBox.isEmpty) {
    final defaultFacilities = ['Wi-Fi', 'Breakfast', 'Kolam Renang', 'Gym', 'Parkir', 'AC'];
    final defaultBadges = ['Populer', 'Rekomendasi', 'Baru'];
    final defaultTipe = ['Hotel', 'Villa'];

  }

  // ✅ Inisialisasi data opsi vila (kalau kosong)
  final vilaOptionsBox = Hive.box<VilaOptionsModel>('vilaOptionsBox');
  if (vilaOptionsBox.isEmpty) {
    final defaultVilaOptions = VilaOptionsModel(
      tipeVila: [
        'Vila Keluarga',
        'Vila Romantis',
        'Vila Mewah',
        'Vila Pantai',
        'Vila Pegunungan',
        'Vila Modern',
        'Vila Tradisional',
      ],
      lokasi: [
        'Jakarta, DKI Jakarta',
        'Bandung, Jawa Barat',
        'Semarang, Jawa Tengah',
        'Surabaya, Jawa Timur',
        'Yogyakarta, DI Yogyakarta',
        'Serang, Banten',
        'Denpasar, Bali',
        'Mataram, Nusa Tenggara Barat',
        'Kupang, Nusa Tenggara Timur',
      ],
      fasilitasTambahan: [
        'AC',
        'TV LED',
        'Kulkas',
        'Dapur Lengkap',
        'Balkon',
        'Teras',
        'BBQ Area',
        'Karaoke',
        'Gazebo',
        'Taman',
        'Security 24 Jam',
        'Laundry',
        'Water Heater',
        'Bathtub',
        'Sound System',
      ],
    );
    
    vilaOptionsBox.put(0, defaultVilaOptions);
  }

  // ✅ Inisialisasi sample data vila (kalau kosong)
  final vilaBox = Hive.box<VilaModel>('vilaBox');
  if (vilaBox.isEmpty) {
    final sampleVilas = [
      VilaModel(
        nama: 'Vila Sunset Paradise',
        deskripsi: 'Vila mewah dengan pemandangan sunset yang menakjubkan, dilengkapi fasilitas lengkap untuk liburan keluarga yang tak terlupakan.',
        lokasi: 'Denpasar, Bali',
        lokasiDetail: 'Jl. Pantai Kuta No.15, Badung, Bali',
        hargaPerMalam: 850000,
        rating: 4.8,
        jumlahReview: 124,
        fasilitas: 'AC, TV LED, Kulkas, Dapur Lengkap, Balkon',
        jumlahKamar: 3,
        kapasitas: 6,
        imageBase64: '',
        checkIn: '14:00',
        checkOut: '12:00',
        tipeVila: 'Vila Pantai',
        tersediaWifi: true,
        tersediaKolam: true,
        tersediaParkir: true,
      ),
      VilaModel(
        nama: 'Vila Mountain Retreat',
        deskripsi: 'Vila pegunungan yang sejuk dan asri, cocok untuk retreat keluarga dengan pemandangan hijau yang menyegarkan.',
        lokasi: 'Bandung, Jawa Barat',
        lokasiDetail: 'Jl. Raya Lembang No.88, Lembang, Bandung',
        hargaPerMalam: 650000,
        rating: 4.6,
        jumlahReview: 89,
        fasilitas: 'AC, TV, Kulkas, Dapur, Teras, Gazebo',
        jumlahKamar: 2,
        kapasitas: 4,
        imageBase64: '',
        checkIn: '15:00',
        checkOut: '11:00',
        tipeVila: 'Vila Pegunungan',
        tersediaWifi: true,
        tersediaKolam: false,
        tersediaParkir: true,
      ),
      VilaModel(
        nama: 'Vila Royal Family',
        deskripsi: 'Vila keluarga yang luas dan nyaman dengan fasilitas lengkap untuk gathering keluarga besar.',
        lokasi: 'Yogyakarta, DI Yogyakarta',
        lokasiDetail: 'Jl. Kaliurang KM 12, Sleman, Yogyakarta',
        hargaPerMalam: 750000,
        rating: 4.7,
        jumlahReview: 156,
        fasilitas: 'AC, TV, Kulkas, Dapur Lengkap, Karaoke, BBQ Area',
        jumlahKamar: 4,
        kapasitas: 8,
        imageBase64: '',
        checkIn: '14:00',
        checkOut: '12:00',
        tipeVila: 'Vila Keluarga',
        tersediaWifi: true,
        tersediaKolam: true,
        tersediaParkir: true,
      ),
    ];
    
    for (final vila in sampleVilas) {
      await vilaBox.add(vila);
    }
  }

  // Inisialisasi lokasi (untuk dropdown lokasi pada header) dengan format "Kota, Provinsi"
  if (lokasiBox.get('list') == null || (lokasiBox.get('list') as List).isEmpty) {
    lokasiBox.put('list', [
      "Jakarta, DKI Jakarta",
      "Bandung, Jawa Barat",
      "Semarang, Jawa Tengah",
      "Surabaya, Jawa Timur",
      "Yogyakarta, DI Yogyakarta",
      "Serang, Banten",
      "Denpasar, Bali",
      "Mataram, Nusa Tenggara Barat",
      "Kupang, Nusa Tenggara Timur"
    ]);
  }

  // Inisialisasi lokasi terakhir yang dipilih jika belum ada
  if (selectedLocationBox.get('selected') == null) {
    selectedLocationBox.put('selected', "Denpasar, Bali");
  }
  // Set value ke ValueNotifier global

  // Cek user aktif
  final activeUserBox = Hive.box<UserModel>('activeUserBox');
  Widget initialScreen = const OnBoardingScreen();

  if (activeUserBox.isNotEmpty) {
    final currentUser = activeUserBox.getAt(0);
    if (currentUser != null) {
      initialScreen = currentUser.role == 'admin'
          ? const MainAdminScreen()
          : const HomeNavigation();
    }
  }

  runApp(TripMateApp(initialScreen: initialScreen));
}

class TripMateApp extends StatelessWidget {
  final Widget initialScreen;
  const TripMateApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      
      home: initialScreen,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeNavigation(),
        '/adminHome': (context) => const MainAdminScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/ubahLandingPage': (context) => const UbahLandingPage(),
      },
    );
  }
}