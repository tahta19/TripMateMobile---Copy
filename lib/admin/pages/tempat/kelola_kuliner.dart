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
    super.dispose();
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

  void _showUpdateConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.update, color: Colors.blue[600], size: 28),
              const SizedBox(width: 12),
              const Text(
                'Konfirmasi Update',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin ingin memperbarui data kuliner ini?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                        const SizedBox(width: 6),
                        Text(
                          'Data yang akan diperbarui:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _performUpdate();
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Ya, Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        );
      },
    );
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Kuliner berhasil diperbarui!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error memperbarui kuliner: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Kuliner berhasil ditambahkan!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Error menyimpan kuliner: $e'),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Mohon lengkapi semua field yang wajib diisi!'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
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
    }
  }

  void deleteKuliner(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus kuliner ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await kulinerBox.deleteAt(index);
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kuliner berhasil dihapus!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
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
              editingIndex == null ? 'Masukkan Data Kuliner' : 'Edit Data Kuliner',
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
                    label: 'Nama Restoran/Kuliner',
                    icon: Icons.restaurant,
                    hint: 'Masukkan nama restoran',
                  ),
                  buildTextField(
                    controller: deskripsiController,
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
                          label: 'Jam Buka',
                          icon: Icons.access_time,
                          onTap: () => _selectTime(context, jamBukaController),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: buildTimeField(
                          controller: jamTutupController,
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
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(imageBase64!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Unggah Foto', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: saveKuliner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: editingIndex == null ? Colors.green : Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      icon: Icon(editingIndex == null ? Icons.save : Icons.update),
                      label: Text(editingIndex == null ? "Simpan" : "Update"),
                    ),
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
                    color: Colors.blue,
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
                    padding: const EdgeInsets.all(40),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.restaurant, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada kuliner yang ditambahkan',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tambahkan kuliner pertama Anda!',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
        keyboardType: type,
        maxLines: maxLines,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          alignLabelWithHint: true,
        ),
        validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }
  
  Widget buildTimeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
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
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item, textAlign: TextAlign.left));
        }).toList(),
        validator: (val) => val == null || val.isEmpty ? 'Wajib dipilih' : null,
      ),
    );
  }
}
