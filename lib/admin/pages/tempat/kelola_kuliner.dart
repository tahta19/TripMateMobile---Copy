import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripmate_mobile/models/kuliner_model.dart';
import 'package:tripmate_mobile/admin/widgets/card_kuliner_baru.dart';

class KelolaKuliner extends StatefulWidget {
  final VoidCallback? onBack;
  const KelolaKuliner({Key? key, this.onBack}) : super(key: key);

  @override
  State<KelolaKuliner> createState() => _KelolaKulinerState();
}

class _KelolaKulinerState extends State<KelolaKuliner> {
  final _formKey = GlobalKey<FormState>();
  late final Box<KulinerModel> kulinerBox;
  final ScrollController _scrollController = ScrollController();

  final nameController = TextEditingController();
  final deskripsiController = TextEditingController();
  final ratingController = TextEditingController();
  final reviewCountController = TextEditingController();
  final priceController = TextEditingController();
  final lokasiDetailController = TextEditingController();
  final jamBukaController = TextEditingController(text: '10:00');
  final jamTutupController = TextEditingController(text: '22:00');

  String? selectedKategori;
  String? selectedLokasi;
  String? imageBase64;
  int? editingIndex;

  // Data dropdown
  final List<String> kategoriKuliner = [
    'BBQ & Grill',
    'Indonesian',
    'Chinese',
    'Western',
    'Seafood',
    'Dessert',
    'Fast Food',
    'Coffee & Tea'
  ];
  final List<String> lokasiList = ['Surabaya', 'Bali', 'Jogja'];

  // Focus nodes untuk styling konsisten
  final FocusNode nameFocus = FocusNode();
  final FocusNode deskripsiFocus = FocusNode();
  final FocusNode ratingFocus = FocusNode();
  final FocusNode reviewFocus = FocusNode();
  final FocusNode priceFocus = FocusNode();
  final FocusNode lokasiDetailFocus = FocusNode();
  final FocusNode jamBukaFocus = FocusNode();
  final FocusNode jamTutupFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    try {
      kulinerBox = Hive.box<KulinerModel>('kulinerBox');
      
      // Test data jika box kosong
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (kulinerBox.isEmpty) {
          final testKuliner = KulinerModel(
            nama: 'Brazilian Aussie BBQ',
            deskripsi: 'Restoran BBQ dengan cita rasa Australia dan Brazil yang autentik',
            kategori: 'BBQ & Grill',
            lokasi: 'Bali',
            lokasiDetail: 'Jl. Beraban No.12, Bali',
            rating: 4.9,
            jumlahReview: 156,
            hargaMulaiDari: 30000,
            imageBase64: '',
            jamBuka: '10:00',
            jamTutup: '22:00',
          );
          kulinerBox.add(testKuliner);
          setState(() {});
        }
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    nameController.dispose();
    deskripsiController.dispose();
    ratingController.dispose();
    reviewCountController.dispose();
    priceController.dispose();
    lokasiDetailController.dispose();
    jamBukaController.dispose();
    jamTutupController.dispose();
    nameFocus.dispose();
    deskripsiFocus.dispose();
    ratingFocus.dispose();
    reviewFocus.dispose();
    priceFocus.dispose();
    lokasiDetailFocus.dispose();
    jamBukaFocus.dispose();
    jamTutupFocus.dispose();
    super.dispose();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void resetForm() {
    nameController.clear();
    deskripsiController.clear();
    ratingController.clear();
    reviewCountController.clear();
    priceController.clear();
    lokasiDetailController.clear();
    jamBukaController.text = '10:00';
    jamTutupController.text = '22:00';
    selectedKategori = null;
    selectedLokasi = null;
    imageBase64 = null;
    editingIndex = null;
    setState(() {});
  }

  void pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        imageBase64 = base64Encode(bytes);
      });
      _showSuccessSnackBar('Foto berhasil dipilih!');
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFDC2626),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hour:$minute';
    }
  }

  Future<bool> _showSaveConfirmation() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFDC2626),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Icon(
                editingIndex == null ? Icons.add_circle_outline : Icons.update,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                editingIndex == null ? 'Konfirmasi Tambah Kuliner' : 'Konfirmasi Update Kuliner',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editingIndex == null
                    ? 'Apakah Anda yakin ingin menambahkan kuliner "${nameController.text}"?'
                    : 'Apakah Anda yakin ingin memperbarui data kuliner "${nameController.text}"?',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              if (editingIndex != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.red[600]),
                          const SizedBox(width: 6),
                          Text(
                            'Data yang akan diperbarui:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('• Nama: ${nameController.text}'),
                      Text('• Kategori: $selectedKategori'),
                      Text('• Lokasi: $selectedLokasi'),
                      Text('• Harga: Rp ${priceController.text}'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    editingIndex == null ? 'Tambah' : 'Update',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ) ?? false;
  }

  void _showUpdateConfirmationDialog() async {
    final confirmed = await _showSaveConfirmation();
    if (confirmed) {
      _performUpdate();
    }
  }

  void _performUpdate() async {
    try {
      final kuliner = KulinerModel(
        nama: nameController.text,
        deskripsi: deskripsiController.text,
        kategori: selectedKategori!,
        lokasi: selectedLokasi!,
        lokasiDetail: lokasiDetailController.text,
        rating: double.tryParse(ratingController.text) ?? 0.0,
        jumlahReview: int.tryParse(reviewCountController.text) ?? 0,
        hargaMulaiDari: int.tryParse(priceController.text) ?? 0,
        imageBase64: imageBase64 ?? '',
        jamBuka: jamBukaController.text,
        jamTutup: jamTutupController.text,
      );

      await kulinerBox.putAt(editingIndex!, kuliner);

      setState(() {});
      resetForm();
      
      _showSuccessSnackBar('Kuliner "${nameController.text}" berhasil diperbarui!');

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });

    } catch (e) {
      _showErrorSnackBar('Gagal memperbarui kuliner. Silakan coba lagi.');
    }
  }

  void saveKuliner() async {
    if (_formKey.currentState!.validate() &&
        selectedKategori != null &&
        selectedLokasi != null &&
        lokasiDetailController.text.isNotEmpty
    ) {
      if (editingIndex != null) {
        _showUpdateConfirmationDialog();
        return;
      }

      final confirmed = await _showSaveConfirmation();
      if (!confirmed) return;

      try {
        final kuliner = KulinerModel(
          nama: nameController.text,
          deskripsi: deskripsiController.text,
          kategori: selectedKategori!,
          lokasi: selectedLokasi!,
          lokasiDetail: lokasiDetailController.text,
          rating: double.tryParse(ratingController.text) ?? 0.0,
          jumlahReview: int.tryParse(reviewCountController.text) ?? 0,
          hargaMulaiDari: int.tryParse(priceController.text) ?? 0,
          imageBase64: imageBase64 ?? '',
          jamBuka: jamBukaController.text,
          jamTutup: jamTutupController.text,
        );

        await kulinerBox.add(kuliner);

        setState(() {});
        resetForm();
        
        _showSuccessSnackBar('Kuliner "${nameController.text}" berhasil ditambahkan!');

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });

      } catch (e) {
        _showErrorSnackBar('Gagal menyimpan kuliner. Silakan coba lagi.');
      }
    } else {
      _showWarningSnackBar('Mohon lengkapi semua field yang wajib diisi!');
    }
  }

  void editKuliner(int index) {
    final kuliner = kulinerBox.getAt(index);
    if (kuliner != null) {
      setState(() {
        editingIndex = index;
        nameController.text = kuliner.nama;
        deskripsiController.text = kuliner.deskripsi;
        selectedKategori = kuliner.kategori;
        selectedLokasi = kuliner.lokasi;
        lokasiDetailController.text = kuliner.lokasiDetail;
        ratingController.text = kuliner.rating.toString();
        reviewCountController.text = kuliner.jumlahReview.toString();
        priceController.text = kuliner.hargaMulaiDari.toString();
        jamBukaController.text = kuliner.jamBuka;
        jamTutupController.text = kuliner.jamTutup;
        imageBase64 = kuliner.imageBase64.isEmpty ? null : kuliner.imageBase64;
      });
      
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      
      _showSuccessSnackBar('Data kuliner "${kuliner.nama}" dimuat untuk diedit');
    }
  }

  Future<bool> _showDeleteConfirmation(String kulinerNama) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Konfirmasi Hapus Kuliner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Apakah Anda yakin ingin menghapus kuliner "$kulinerNama"?\n\nTindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ) ?? false;
  }

  void deleteKuliner(int index) async {
    final kuliner = kulinerBox.getAt(index);
    if (kuliner != null) {
      final confirmed = await _showDeleteConfirmation(kuliner.nama);
      if (confirmed) {
        try {
          await kulinerBox.deleteAt(index);
          _showSuccessSnackBar('Kuliner "${kuliner.nama}" berhasil dihapus!');
          setState(() {});
        } catch (e) {
          _showErrorSnackBar('Gagal menghapus kuliner. Silakan coba lagi.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFDC2626),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(left: 8, top: screenWidth * 0.08, bottom: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack ?? () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Text(
                'Kelola Kuliner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(screenWidth * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              editingIndex == null ? 'Masukkan Data Kuliner Baru' : 'Edit Data Kuliner',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField(
                    controller: nameController,
                    focusNode: nameFocus,
                    label: 'Nama Restoran/Kuliner',
                    icon: Icons.restaurant,
                    hint: 'Masukkan nama restoran',
                  ),
                  buildTextField(
                    controller: deskripsiController,
                    focusNode: deskripsiFocus,
                    label: 'Deskripsi',
                    icon: Icons.description,
                    hint: 'Masukkan deskripsi kuliner',
                    maxLines: 3,
                  ),
                  buildDropdownField(
                    label: 'Kategori Kuliner',
                    icon: Icons.restaurant_menu,
                    items: kategoriKuliner,
                    selectedValue: selectedKategori,
                    onChanged: (value) => setState(() => selectedKategori = value),
                  ),
                  buildDropdownField(
                    label: 'Lokasi',
                    icon: Icons.location_city,
                    items: lokasiList,
                    selectedValue: selectedLokasi,
                    onChanged: (value) => setState(() => selectedLokasi = value),
                  ),
                  buildTextField(
                    controller: lokasiDetailController,
                    focusNode: lokasiDetailFocus,
                    label: 'Detail Lokasi',
                    icon: Icons.place,
                    hint: 'Masukkan alamat lengkap restoran',
                  ),
                  
                  // Jam Operasional
                  Row(
                    children: [
                      Expanded(
                        child: buildTimeField(
                          controller: jamBukaController,
                          focusNode: jamBukaFocus,
                          label: 'Jam Buka',
                          icon: Icons.access_time,
                          onTap: () => _selectTime(context, jamBukaController),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: buildTimeField(
                          controller: jamTutupController,
                          focusNode: jamTutupFocus,
                          label: 'Jam Tutup',
                          icon: Icons.access_time_filled,
                          onTap: () => _selectTime(context, jamTutupController),
                        ),
                      ),
                    ],
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          controller: ratingController,
                          focusNode: ratingFocus,
                          label: 'Rating',
                          icon: Icons.star,
                          hint: 'Contoh: 4.9',
                          type: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: buildTextField(
                          controller: reviewCountController,
                          focusNode: reviewFocus,
                          label: 'Jumlah Review',
                          icon: Icons.people,
                          hint: 'Contoh: 156',
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  buildTextField(
                    controller: priceController,
                    focusNode: priceFocus,
                    label: 'Harga Mulai Dari',
                    icon: Icons.attach_money,
                    hint: 'Masukkan harga mulai dari',
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Unggah Foto Restoran",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: screenWidth * 0.26 + 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: imageBase64 != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(imageBase64!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.black),
                                  SizedBox(height: 8),
                                  Text('Unggah Foto', style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (editingIndex != null) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              resetForm();
                              _showSuccessSnackBar('Form berhasil direset');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.clear),
                            label: const Text("Batal Edit"),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: saveKuliner,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(editingIndex == null ? Icons.add : Icons.update),
                          label: Text(editingIndex == null ? "Tambah Kuliner" : "Update Kuliner"),
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Row(
              children: [
                const Text('Daftar Kuliner', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: kulinerBox.listenable(),
                    builder: (context, Box<KulinerModel> box, _) {
                      return Text(
                        '${box.length} item',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            ValueListenableBuilder(
              valueListenable: kulinerBox.listenable(),
              builder: (context, Box<KulinerModel> box, _) {
                if (box.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada kuliner yang ditambahkan',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final kuliner = box.getAt(index);
                    if (kuliner == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CardKulinerBaru(
                        kuliner: kuliner,
                        onEdit: () => editKuliner(index),
                        onDelete: () => deleteKuliner(index),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? type,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: type,
        maxLines: maxLines,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelStyle: const TextStyle(color: Color(0xFFDC2626)),
          alignLabelWithHint: true,
        ),
        validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }
  
  Widget buildTimeField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.black),
          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelStyle: const TextStyle(color: Color(0xFFDC2626)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }

  Widget buildDropdownField({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isExpanded: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelStyle: const TextStyle(color: Color(0xFFDC2626)),
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item, textAlign: TextAlign.left));
        }).toList(),
        validator: (val) => val == null || val.isEmpty ? 'Wajib dipilih' : null,
      ),
    );
  }
}