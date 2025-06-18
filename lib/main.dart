import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tripmate_mobile/models/pesawat_model.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

// Models
import 'models/user_model.dart';
import 'models/landing_page_model.dart';
import 'models/rencana_model.dart';
import 'models/hotel_model.dart';
import 'models/vila_model.dart'; // ✅ Tambahkan import vila model
import 'models/tiket_model.dart'; // ✅ PERBAIKAN: Ganti dari tiket_model.dart ke tiket_aktivitas_model.dart
import 'models/pesawat_model.dart';
import 'models/aktivitas_model.dart';
import 'models/pesawat_model.dart';
import 'models/mobil_model.dart';
import 'models/kuliner_model.dart';
// Screens umum
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/login_signup/login_screen.dart';
import 'screens/login_signup/signup_screen.dart';
import 'widgets/home_navigation.dart';

// Screens admin
import 'admin/main_admin_screen.dart';
import 'admin/pages/dashboard/dashboard_page.dart';
import 'admin/pages/dashboard/ubah_landing_page.dart';

// Shared global state for location
import 'shared/location_state.dart';
import '/admin/pages/tempat/kelola_kuliner.dart';
import '/admin/pages/tempat/kelola_aktivitas.dart';

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
  // if (!Hive.isAdapterRegistered(AreaAkomodasiModelAdapter().typeId)) {
  //   Hive.registerAdapter(AreaAkomodasiModelAdapter());
  // }
  if (!Hive.isAdapterRegistered(HotelOptionsModelAdapter().typeId)) {
    Hive.registerAdapter(HotelOptionsModelAdapter());
  }
  // ✅ Tambahkan adapter vila
  if (!Hive.isAdapterRegistered(VilaModelAdapter().typeId)) {
    Hive.registerAdapter(VilaModelAdapter());
  }
  if (!Hive.isAdapterRegistered(AreaVilaModelAdapter().typeId)) {
    Hive.registerAdapter(AreaVilaModelAdapter());
  }
  if (!Hive.isAdapterRegistered(VilaOptionsModelAdapter().typeId)) {
    Hive.registerAdapter(VilaOptionsModelAdapter());
  }
  if (!Hive.isAdapterRegistered(PesawatModelAdapter().typeId)) {
    Hive.registerAdapter(PesawatModelAdapter());
  }
  // ✅ PERBAIKAN: Register adapter TiketAktivitasModel dengan nama yang benar
  if (!Hive.isAdapterRegistered(TiketAktivitasModelAdapter().typeId)) {
    Hive.registerAdapter(TiketAktivitasModelAdapter());
  }

  if (!Hive.isAdapterRegistered(AktivitasModelAdapter().typeId)) {
    Hive.registerAdapter(AktivitasModelAdapter());
  }

  if (!Hive.isAdapterRegistered(MobilModelAdapter().typeId)) {
    Hive.registerAdapter(MobilModelAdapter());
  }
  if (!Hive.isAdapterRegistered(KulinerModelAdapter().typeId)) {
    Hive.registerAdapter(KulinerModelAdapter());
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
    await Hive.deleteBoxFromDisk('pesawatBox');
    await Hive.deleteBoxFromDisk('vilaOptionsBox');
    // ✅ PERBAIKAN: Ganti nama box dari 'tiketBox' ke 'tiketAktivitasBox'
    await Hive.deleteBoxFromDisk('tiketAktivitasBox');
    await Hive.deleteBoxFromDisk('aktivitasBox');
    await Hive.deleteBoxFromDisk('mobilBox');
    await Hive.deleteBoxFromDisk('kulinerBox');
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
  await Hive.openBox<PesawatModel>('pesawatOptionsBox');
  await Hive.openBox<PesawatModel>('pesawatBox');
  // ✅ PERBAIKAN: Buka box dengan nama yang konsisten 'tiketAktivitasBox'
  await Hive.openBox<TiketAktivitasModel>('tiketAktivitasBox');
  await Hive.openBox<AktivitasModel>('aktivitasBox');
  await Hive.openBox<MobilModel>('mobilBox');
  await Hive.openBox<KulinerModel>('kulinerBox');

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

    // hotelOptionsBox.put(
    //   0,
    //   HotelOptionsModel(
    //     tipe: defaultTipe,
    //     badge: defaultBadges,
    //     facilities: defaultFacilities,
    //   ),
    // );
  }

  // ✅ Inisialisasi data opsi vila (kalau kosong)
  final vilaOptionsBox = Hive.box<VilaOptionsModel>('vilaOptionsBox');
  if (vilaOptionsBox.isEmpty) {
    final defaultVilaOptions = VilaOptionsModel(
      tipeVila: [
        'Vila',
        'Hotel',
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
      facilities: [
        'Wi-Fi',
        'AC',
        'TV LED',
        'Kulkas',
        'Dapur Lengkap',
        'Kolam Renang',
        'Parkir',
        'BBQ Area',
        'Karaoke',
        'Gazebo',
        'Taman',
        'Security 24 Jam',
      ],
      badge: [
        'Populer',
        'Rekomendasi', 
        'Baru',
        'Terfavorit',
        'Best Deal',
      ],
    );
    
    vilaOptionsBox.put(0, defaultVilaOptions);
  }

  // ✅ Inisialisasi sample data vila (kalau kosong)
  final vilaBox = Hive.box<VilaModel>('vilaBox');
  if (vilaBox.isEmpty) {
    final sampleVilas = [
      // 
      // VilaModel(
      //   nama: 'Vila Mountain Retreat',
      //   deskripsi: 'Vila pegunungan yang sejuk dan asri, cocok untuk retreat keluarga dengan pemandangan hijau yang menyegarkan.',
      //   lokasi: 'Bandung, Jawa Barat',
      //   lokasiDetail: 'Jl. Raya Lembang No.88, Lembang, Bandung',
      //   hargaPerMalam: 650000,
      //   rating: 4.6,
      //   jumlahReview: 89,
      //   fasilitas: ['Wi-Fi', 'AC', 'TV LED', 'Dapur Lengkap', 'Gazebo'],
      //   jumlahKamar: 2,
      //   kapasitas: 4,
      //   imageBase64: '',
      //   checkIn: '15:00',
      //   checkOut: '11:00',
      //   tipeVila: 'Vila Pegunungan',
      //   badge: ['Rekomendasi'],
      //   areaVila: [
      //     AreaVilaModel(nama: 'Tangkuban Perahu', jarakKm: 5.0, iconName: 'park'),
      //     AreaVilaModel(nama: 'Floating Market', jarakKm: 2.5, iconName: 'restaurant'),
      //   ],
      // ),
    ];
    
    for (final vila in sampleVilas) {
      await vilaBox.add(vila);
    }
  }

  // ✅ PERBAIKAN: Inisialisasi sample data tiket aktivitas (kalau kosong)
  final tiketAktivitasBox = Hive.box<TiketAktivitasModel>('tiketAktivitasBox');
  if (tiketAktivitasBox.isEmpty) {
    // Box kosong, siap untuk diisi data tiket aktivitas
    print('TiketAktivitasBox berhasil dibuka dan siap digunakan');
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
  LocationState.selectedLocation.value = selectedLocationBox.get('selected') as String;

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
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
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