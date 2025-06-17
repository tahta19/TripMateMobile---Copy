import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripmate_mobile/models/vila_model.dart';
import 'package:tripmate_mobile/admin/widgets/card_vila_baru.dart';

class KelolaVila extends StatefulWidget {
  final VoidCallback? onBack;
  const KelolaVila({Key? key, this.onBack}) : super(key: key);

  @override
  State<KelolaVila> createState() => _KelolaVilaState();
}

class _KelolaVilaState extends State<KelolaVila> {
  final _formKey = GlobalKey<FormState>();
  late final Box<VilaModel> vilaBox;
  final ScrollController _scrollController = ScrollController();

  final nameController = TextEditingController();
  final deskripsiController = TextEditingController();
  final ratingController = TextEditingController();
  final reviewCountController = TextEditingController();
  final priceController = TextEditingController();
  final lokasiDetailController = TextEditingController();
  final fasilitasController = TextEditingController();
  final jumlahKamarController = TextEditingController();
  final kapasitasController = TextEditingController();
  final checkInController = TextEditingController(text: '14:00');
  final checkOutController = TextEditingController(text: '12:00');

  String? selectedTipeVila;
  String? selectedLokasi;
  String? imageBase64;
  int? editingIndex;

  // Fasilitas boolean
  bool tersediaWifi = false;
  bool tersediaKolam = false;
  bool tersediaParkir = false;

  // Data dropdown
  final List<String> tipeVilaList = [
    'Vila Keluarga',
    'Vila Romantis',
    'Vila Mewah',
    'Vila Pantai',
    'Vila Pegunungan',
    'Vila Modern',
    'Vila Tradisional'
  ];
  
  final List<String> lokasiList = ['Surabaya', 'Bali', 'Jogja', 'Bandung', 'Lombok'];

  // Focus nodes untuk mengubah warna border
  final FocusNode nameFocus = FocusNode();
  final FocusNode deskripsiFocus = FocusNode();
  final FocusNode ratingFocus = FocusNode();
  final FocusNode reviewFocus = FocusNode();
  final FocusNode priceFocus = FocusNode();
  final FocusNode lokasiDetailFocus = FocusNode();
  final FocusNode fasilitasFocus = FocusNode();
  final FocusNode jumlahKamarFocus = FocusNode();
  final FocusNode kapasitasFocus = FocusNode();
  final FocusNode checkInFocus = FocusNode();
  final FocusNode checkOutFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    try {
      vilaBox = Hive.box<VilaModel>('vilaBox');
      
      // Test data jika box kosong
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (vilaBox.isEmpty) {
          final testVila = VilaModel(
            nama: 'Vila Sunset Paradise',
            deskripsi: 'Vila mewah dengan pemandangan sunset yang menakjubkan',
            lokasi: 'Bali',
            lokasiDetail: 'Jl. Pantai Kuta No.15, Bali',
            hargaPerMalam: 850000,
            rating: 4.8,
            jumlahReview: 124,
            fasilitas: 'AC, TV, Kulkas, Dapur Lengkap',
            jumlahKamar: 3,
            kapasitas: 6,
            imageBase64: '',
            checkIn: '14:00',
            checkOut: '12:00',
            tipeVila: 'Vila Pantai',
            tersediaWifi: true,
            tersediaKolam: true,
            tersediaParkir: true,
          );
          vilaBox.add(testVila);
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
    fasilitasController.dispose();
    jumlahKamarController.dispose();
    kapasitasController.dispose();
    checkInController.dispose();
    checkOutController.dispose();
    nameFocus.dispose();
    deskripsiFocus.dispose();
    ratingFocus.dispose();
    reviewFocus.dispose();
    priceFocus.dispose();
    lokasiDetailFocus.dispose();
    fasilitasFocus.dispose();
    jumlahKamarFocus.dispose();
    kapasitasFocus.dispose();
    checkInFocus.dispose();
    checkOutFocus.dispose();
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
    fasilitasController.clear();
    jumlahKamarController.clear();
    kapasitasController.clear();
    checkInController.text = '14:00';
    checkOutController.text = '12:00';
    selectedTipeVila = null;
    selectedLokasi = null;
    imageBase64 = null;
    editingIndex = null;
    tersediaWifi = false;
    tersediaKolam = false;
    tersediaParkir = false;
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
                editingIndex == null ? 'Konfirmasi Tambah Vila' : 'Konfirmasi Update Vila',
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
                    ? 'Apakah Anda yakin ingin menambahkan vila "${nameController.text}"?'
                    : 'Apakah Anda yakin ingin memperbarui data vila "${nameController.text}"?',
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
                      Text('• Tipe: $selectedTipeVila'),
                      Text('• Lokasi: $selectedLokasi'),
                      Text('• Harga: Rp ${priceController.text}/malam'),
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

  void saveVila() async {
    if (_formKey.currentState!.validate() &&
        selectedTipeVila != null &&
        selectedLokasi != null &&
        lokasiDetailController.text.isNotEmpty
    ) {
      final confirmed = await _showSaveConfirmation();
      if (!confirmed) return;

      try {
        final vila = VilaModel(
          nama: nameController.text,
          deskripsi: deskripsiController.text,
          lokasi: selectedLokasi!,
          lokasiDetail: lokasiDetailController.text,
          hargaPerMalam: int.tryParse(priceController.text) ?? 0,
          rating: double.tryParse(ratingController.text) ?? 0.0,
          jumlahReview: int.tryParse(reviewCountController.text) ?? 0,
          fasilitas: fasilitasController.text,
          jumlahKamar: int.tryParse(jumlahKamarController.text) ?? 1,
          kapasitas: int.tryParse(kapasitasController.text) ?? 2,
          imageBase64: imageBase64 ?? '',
          checkIn: checkInController.text,
          checkOut: checkOutController.text,
          tipeVila: selectedTipeVila!,
          tersediaWifi: tersediaWifi,
          tersediaKolam: tersediaKolam,
          tersediaParkir: tersediaParkir,
        );

        if (editingIndex == null) {
          await vilaBox.add(vila);
          _showSuccessSnackBar('Vila "${nameController.text}" berhasil ditambahkan!');
        } else {
          await vilaBox.putAt(editingIndex!, vila);
          _showSuccessSnackBar('Vila "${nameController.text}" berhasil diperbarui!');
        }

        setState(() {});
        resetForm();

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
        _showErrorSnackBar('Gagal menyimpan vila. Silakan coba lagi.');
      }
    } else {
      _showWarningSnackBar('Mohon lengkapi semua field yang wajib diisi!');
    }
  }

  void editVila(int index) {
    final vila = vilaBox.getAt(index);
    if (vila != null) {
      setState(() {
        editingIndex = index;
        nameController.text = vila.nama;
        deskripsiController.text = vila.deskripsi;
        selectedLokasi = vila.lokasi;
        lokasiDetailController.text = vila.lokasiDetail;
        priceController.text = vila.hargaPerMalam.toString();
        ratingController.text = vila.rating.toString();
        reviewCountController.text = vila.jumlahReview.toString();
        fasilitasController.text = vila.fasilitas;
        jumlahKamarController.text = vila.jumlahKamar.toString();
        kapasitasController.text = vila.kapasitas.toString();
        checkInController.text = vila.checkIn;
        checkOutController.text = vila.checkOut;
        selectedTipeVila = vila.tipeVila;
        tersediaWifi = vila.tersediaWifi;
        tersediaKolam = vila.tersediaKolam;
        tersediaParkir = vila.tersediaParkir;
        imageBase64 = vila.imageBase64.isEmpty ? null : vila.imageBase64;
      });
      
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      
      _showSuccessSnackBar('Data vila "${vila.nama}" dimuat untuk diedit');
    }
  }

  Future<bool> _showDeleteConfirmation(String vilaNama) async {
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
                'Konfirmasi Hapus Vila',
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
            'Apakah Anda yakin ingin menghapus vila "$vilaNama"?\n\nTindakan ini tidak dapat dibatalkan.',
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

  void deleteVila(int index) async {
    final vila = vilaBox.getAt(index);
    if (vila != null) {
      final confirmed = await _showDeleteConfirmation(vila.nama);
      if (confirmed) {
        try {
          await vilaBox.deleteAt(index);
          _showSuccessSnackBar('Vila "${vila.nama}" berhasil dihapus!');
          setState(() {});
        } catch (e) {
          _showErrorSnackBar('Gagal menghapus vila. Silakan coba lagi.');
        }
      }
    }
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

  Widget buildFasilitasUtamaField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fasilitas Utama', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.wifi, size: 16, color: Color(0xFFDC2626)),
                      SizedBox(width: 4),
                      Text('WiFi', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  value: tersediaWifi,
                  onChanged: (value) => setState(() => tersediaWifi = value ?? false),
                  activeColor: const Color(0xFFDC2626),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Row(
                    children: [
                      Icon(Icons.pool, size: 16, color: Color(0xFFDC2626)),
                      SizedBox(width: 4),
                      Text('Kolam', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  value: tersediaKolam,
                  onChanged: (value) => setState(() => tersediaKolam = value ?? false),
                  activeColor: const Color(0xFFDC2626),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          CheckboxListTile(
            title: const Row(
              children: [
                Icon(Icons.local_parking, size: 16, color: Color(0xFFDC2626)),
                SizedBox(width: 4),
                Text('Parkir', style: TextStyle(fontSize: 14)),
              ],
            ),
            value: tersediaParkir,
            onChanged: (value) => setState(() => tersediaParkir = value ?? false),
            activeColor: const Color(0xFFDC2626),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
      ),
    );
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
                'Kelola Vila',
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
              editingIndex == null ? 'Masukkan Data Vila Baru' : 'Edit Data Vila',
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
                    label: 'Nama Vila',
                    icon: Icons.villa,
                    hint: 'Masukkan nama vila',
                  ),
                  buildTextField(
                    controller: deskripsiController,
                    focusNode: deskripsiFocus,
                    label: 'Deskripsi',
                    icon: Icons.description,
                    hint: 'Masukkan deskripsi vila',
                    maxLines: 3,
                  ),
                  buildDropdownField(
                    label: 'Tipe Vila',
                    icon: Icons.home_work,
                    items: tipeVilaList,
                    selectedValue: selectedTipeVila,
                    onChanged: (value) => setState(() => selectedTipeVila = value),
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
                    hint: 'Masukkan alamat lengkap vila',
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          controller: jumlahKamarController,
                          focusNode: jumlahKamarFocus,
                          label: 'Jumlah Kamar',
                          icon: Icons.bed,
                          hint: 'Contoh: 3',
                          type: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: buildTextField(
                          controller: kapasitasController,
                          focusNode: kapasitasFocus,
                          label: 'Kapasitas',
                          icon: Icons.people,
                          hint: 'Contoh: 6',
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: buildTimeField(
                          controller: checkInController,
                          focusNode: checkInFocus,
                          label: 'Check-in',
                          icon: Icons.login,
                          onTap: () => _selectTime(context, checkInController),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: buildTimeField(
                          controller: checkOutController,
                          focusNode: checkOutFocus,
                          label: 'Check-out',
                          icon: Icons.logout,
                          onTap: () => _selectTime(context, checkOutController),
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
                          hint: 'Contoh: 4.8',
                          type: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: buildTextField(
                          controller: reviewCountController,
                          focusNode: reviewFocus,
                          label: 'Jumlah Review',
                          icon: Icons.rate_review,
                          hint: 'Contoh: 124',
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  
                  buildTextField(
                    controller: priceController,
                    focusNode: priceFocus,
                    label: 'Harga Per Malam',
                    icon: Icons.attach_money,
                    hint: 'Masukkan harga per malam',
                    type: TextInputType.number,
                  ),
                  
                  buildTextField(
                    controller: fasilitasController,
                    focusNode: fasilitasFocus,
                    label: 'Fasilitas Tambahan',
                    icon: Icons.featured_play_list,
                    hint: 'Contoh: AC, TV, Kulkas, Dapur Lengkap',
                    maxLines: 2,
                  ),
                  
                  buildFasilitasUtamaField(),
                  
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Unggah Foto Vila",
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
                          onPressed: saveVila,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(editingIndex == null ? Icons.add : Icons.update),
                          label: Text(editingIndex == null ? "Tambah Vila" : "Update Vila"),
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
                const Text('Daftar Vila', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: vilaBox.listenable(),
                    builder: (context, Box<VilaModel> box, _) {
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
              valueListenable: vilaBox.listenable(),
              builder: (context, Box<VilaModel> box, _) {
                if (box.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.villa_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada vila yang ditambahkan',
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
                    final vila = box.getAt(index);
                    if (vila == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CardVilaBaru(
                        vila: vila,
                        onEdit: () => editVila(index),
                        onDelete: () => deleteVila(index),
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
}