import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripmate_mobile/models/aktivitas_model.dart';
import 'package:tripmate_mobile/admin/widgets/card_aktivitas_baru.dart';

class KelolaAktivitas extends StatefulWidget {
  final VoidCallback? onBack;
  const KelolaAktivitas({Key? key, this.onBack}) : super(key: key);

  @override
  State<KelolaAktivitas> createState() => _KelolaAktivitasState();
}

class _KelolaAktivitasState extends State<KelolaAktivitas> {
  final _formKey = GlobalKey<FormState>();
  late final Box<AktivitasModel> aktivitasBox;
  final ScrollController _scrollController = ScrollController();

  final nameController = TextEditingController();
  final deskripsiController = TextEditingController();
  final ratingController = TextEditingController();
  final reviewCountController = TextEditingController();
  final priceController = TextEditingController();
  final lokasiDetailController = TextEditingController();
  final jamBukaController = TextEditingController(text: '08:00');
  final jamTutupController = TextEditingController(text: '17:00');

  String? selectedTipe;
  String? selectedLokasi;
  String? imageBase64;
  int? editingIndex;

  // Data dropdown
  final List<String> tipeAktivitas = ['Budaya', 'Atraksi', 'Alam'];
  final List<String> lokasiList = ['Surabaya', 'Bali', 'Jogja'];

  @override
  void initState() {
    super.initState();
    try {
      aktivitasBox = Hive.box<AktivitasModel>('aktivitasBox');
      
      // Test data jika box kosong
      
    } catch (e) {
      // Handle error silently or show user-friendly message
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
    jamBukaController.text = '08:00';
    jamTutupController.text = '17:00';
    selectedTipe = null;
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
                'Apakah Anda yakin ingin memperbarui data aktivitas ini?',
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
                    Text('• Tipe: $selectedTipe'),
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
      final aktivitas = AktivitasModel(
        nama: nameController.text,
        deskripsi: deskripsiController.text,
        tipe: selectedTipe!,
        lokasi: selectedLokasi!,
        lokasiDetail: lokasiDetailController.text,
        rating: double.tryParse(ratingController.text) ?? 0.0,
        jumlahReview: int.tryParse(reviewCountController.text) ?? 0,
        harga: int.tryParse(priceController.text) ?? 0,
        imageBase64: imageBase64 ?? '',
        jamBuka: jamBukaController.text,
        jamTutup: jamTutupController.text,
      );

      await aktivitasBox.putAt(editingIndex!, aktivitas);

      setState(() {});
      resetForm();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Aktivitas berhasil diperbarui!'),
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
                Text('Error memperbarui aktivitas: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void saveAktivitas() async {
    if (_formKey.currentState!.validate() &&
        selectedTipe != null &&
        selectedLokasi != null &&
        lokasiDetailController.text.isNotEmpty
    ) {
      if (editingIndex != null) {
        _showUpdateConfirmationDialog();
        return;
      }

      try {
        final aktivitas = AktivitasModel(
          nama: nameController.text,
          deskripsi: deskripsiController.text,
          tipe: selectedTipe!,
          lokasi: selectedLokasi!,
          lokasiDetail: lokasiDetailController.text,
          rating: double.tryParse(ratingController.text) ?? 0.0,
          jumlahReview: int.tryParse(reviewCountController.text) ?? 0,
          harga: int.tryParse(priceController.text) ?? 0,
          imageBase64: imageBase64 ?? '',
          jamBuka: jamBukaController.text,
          jamTutup: jamTutupController.text,
        );

        await aktivitasBox.add(aktivitas);

        setState(() {});
        resetForm();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Aktivitas berhasil ditambahkan!'),
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
                  Text('Error menyimpan aktivitas: $e'),
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

  void editAktivitas(int index) {
    final aktivitas = aktivitasBox.getAt(index);
    if (aktivitas != null) {
      setState(() {
        editingIndex = index;
        nameController.text = aktivitas.nama;
        deskripsiController.text = aktivitas.deskripsi;
        selectedTipe = aktivitas.tipe;
        selectedLokasi = aktivitas.lokasi;
        lokasiDetailController.text = aktivitas.lokasiDetail;
        ratingController.text = aktivitas.rating.toString();
        reviewCountController.text = aktivitas.jumlahReview.toString();
        priceController.text = aktivitas.harga.toString();
        jamBukaController.text = aktivitas.jamBuka;
        jamTutupController.text = aktivitas.jamTutup;
        imageBase64 = aktivitas.imageBase64.isEmpty ? null : aktivitas.imageBase64;
      });
      
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void deleteAktivitas(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus aktivitas ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await aktivitasBox.deleteAt(index);
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aktivitas berhasil dihapus!'),
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
                'Kelola Aktivitas',
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
              editingIndex == null ? 'Masukkan Data Aktivitas' : 'Edit Data Aktivitas',
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
                    label: 'Nama Aktivitas',
                    icon: Icons.local_activity,
                    hint: 'Masukkan nama aktivitas',
                  ),
                  buildTextField(
                    controller: deskripsiController,
                    label: 'Deskripsi',
                    icon: Icons.description,
                    hint: 'Masukkan deskripsi aktivitas',
                    maxLines: 3,
                  ),
                  buildDropdownField(
                    label: 'Tipe Aktivitas',
                    icon: Icons.category,
                    items: tipeAktivitas,
                    selectedValue: selectedTipe,
                    onChanged: (value) => setState(() => selectedTipe = value),
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
                    hint: 'Masukkan alamat lengkap aktivitas',
                  ),
                  
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
                          hint: 'Contoh: 4.8',
                          type: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: buildTextField(
                          controller: reviewCountController,
                          label: 'Jumlah Review',
                          icon: Icons.people,
                          hint: 'Contoh: 205',
                          type: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  buildTextField(
                    controller: priceController,
                    label: 'Harga',
                    icon: Icons.attach_money,
                    hint: 'Masukkan harga aktivitas',
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Unggah Foto Aktivitas",
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
                      onPressed: saveAktivitas,
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
                const Text('Daftar Aktivitas', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: aktivitasBox.listenable(),
                    builder: (context, Box<AktivitasModel> box, _) {
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
              valueListenable: aktivitasBox.listenable(),
              builder: (context, Box<AktivitasModel> box, _) {
                if (box.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada aktivitas yang ditambahkan',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tambahkan aktivitas pertama Anda!',
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
                    final aktivitas = box.getAt(index);
                    if (aktivitas == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CardAktivitasBaru(
                        aktivitas: aktivitas,
                        onEdit: () => editAktivitas(index),
                        onDelete: () => deleteAktivitas(index),
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
