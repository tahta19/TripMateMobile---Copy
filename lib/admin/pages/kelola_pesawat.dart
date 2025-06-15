import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripmate_mobile/models/pesawat_model.dart';
import 'package:tripmate_mobile/admin/widgets/card_pesawat_baru.dart';
import 'package:intl/intl.dart';

class KelolaPesawatPage extends StatefulWidget {
  final VoidCallback? onBack;
  const KelolaPesawatPage({Key? key, this.onBack}) : super(key: key);

  @override
  State<KelolaPesawatPage> createState() => _KelolaPesawatState();
}

class _KelolaPesawatState extends State<KelolaPesawatPage> {
  final _formKey = GlobalKey<FormState>();
  late final Box<PesawatModel> pesawatBox;
  final ScrollController _scrollController = ScrollController();

  final namaController = TextEditingController();
  final asalController = TextEditingController();
  final tujuanController = TextEditingController();
  final kelasController = TextEditingController();
  final hargaController = TextEditingController();
  final waktuController = TextEditingController();
  final durasiController = TextEditingController();

  final List<String> lokasiList = ['Jakarta', 'Surabaya', 'Denpasar', 'Yogyakarta'];
  final List<String> kelasList = ['Ekonomi', 'Bisnis'];

  String? selectedAsal;
  String? selectedTujuan;
  String? selectedKelas;
  String? imageBase64;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    try {
      pesawatBox = Hive.box<PesawatModel>('pesawatBox');
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    namaController.dispose();
    asalController.dispose();
    tujuanController.dispose();
    kelasController.dispose();
    hargaController.dispose();
    waktuController.dispose();
    durasiController.dispose();
    super.dispose();
  }

  void resetForm() {
    namaController.clear();
    hargaController.clear();
    waktuController.clear();
    durasiController.clear();
    selectedAsal = null;
    selectedTujuan = null;
    selectedKelas = null;
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
                'Apakah Anda yakin ingin memperbarui data pesawat ini?',
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
                  // children: [
                  //   Row(
                  //     children: [
                  //       Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                  //       const SizedBox(width: 6),
                  //       Text(
                  //         'Data yang akan diperbarui:',
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.w600,
                  //           color: Colors.blue[700],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  //   const SizedBox(height: 8),
                  //   Text('• Maskapai: ${namaController.text}'),
                  //   Text('• Rute: $selectedAsal → $selectedTujuan'),
                  //   Text('• Kelas: $selectedKelas'),
                  //   Text('• Harga: Rp ${hargaController.text}'),
                  // ],
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
      final pesawat = PesawatModel(
        nama: namaController.text,
        asal: selectedAsal ?? '',
        tujuan: selectedTujuan ?? '',
        kelas: selectedKelas ?? '',
        harga: int.tryParse(hargaController.text) ?? 0,
        durasi: int.tryParse(durasiController.text) ?? 0,
        waktu: DateTime.parse(waktuController.text),
        imageBase64: imageBase64 ?? '',
      );

      await pesawatBox.putAt(editingIndex!, pesawat);

      setState(() {});
      resetForm();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Data pesawat berhasil diperbarui!'),
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
                Text('Error memperbarui pesawat: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void savePesawat() async {
    final isValid = _formKey.currentState!.validate();
    
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Harap lengkapi seluruh field yang wajib diisi'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (imageBase64 == null || imageBase64!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Logo maskapai wajib diunggah'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (editingIndex != null) {
      _showUpdateConfirmationDialog();
      return;
    }

    try {
      final pesawat = PesawatModel(
        nama: namaController.text,
        asal: selectedAsal ?? '',
        tujuan: selectedTujuan ?? '',
        kelas: selectedKelas ?? '',
        harga: int.tryParse(hargaController.text) ?? 0,
        durasi: int.tryParse(durasiController.text) ?? 0,
        waktu: DateTime.parse(waktuController.text),
        imageBase64: imageBase64 ?? '',
      );

      await pesawatBox.add(pesawat);

      setState(() {});
      resetForm();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Data pesawat berhasil disimpan!'),
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
                Text('Error menyimpan pesawat: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void editPesawat(int index) {
    final pesawat = pesawatBox.getAt(index);
    if (pesawat != null) {
      setState(() {
        editingIndex = index;
        namaController.text = pesawat.nama;
        selectedAsal = pesawat.asal;
        selectedTujuan = pesawat.tujuan;
        selectedKelas = pesawat.kelas;
        hargaController.text = pesawat.harga.toString();
        waktuController.text = DateFormat('yyyy-MM-dd HH:mm').format(pesawat.waktu);
        durasiController.text = pesawat.durasi.toString();
        imageBase64 = pesawat.imageBase64;
      });
      
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void deletePesawat(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data pesawat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await pesawatBox.deleteAt(index);
        
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Data pesawat berhasil dihapus!'),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
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

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
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

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        waktuController.text = fullDateTime.toString();
        setState(() {});
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
                'Kelola Pesawat',
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
              editingIndex == null ? 'Masukkan Data Pesawat' : 'Edit Data Pesawat',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField(
                    controller: namaController,
                    label: 'Nama Maskapai',
                    icon: Icons.flight,
                    hint: 'Masukkan nama maskapai',
                  ),
                  buildDropdownField(
                    label: 'Asal',
                    icon: Icons.flight_takeoff,
                    items: lokasiList,
                    selectedValue: selectedAsal,
                    onChanged: (value) => setState(() => selectedAsal = value),
                  ),
                  buildDropdownField(
                    label: 'Tujuan',
                    icon: Icons.flight_land,
                    items: lokasiList,
                    selectedValue: selectedTujuan,
                    onChanged: (value) => setState(() => selectedTujuan = value),
                  ),
                  buildDropdownField(
                    label: 'Kelas',
                    icon: Icons.airline_seat_recline_extra,
                    items: kelasList,
                    selectedValue: selectedKelas,
                    onChanged: (value) => setState(() => selectedKelas = value),
                  ),
                  buildTextField(
                    controller: hargaController,
                    label: 'Harga Tiket',
                    icon: Icons.attach_money,
                    hint: 'Masukkan harga tiket',
                    type: TextInputType.number,
                  ),
                  buildDateTimeField(
                    controller: waktuController,
                    label: 'Waktu Berangkat',
                    icon: Icons.schedule,
                    onTap: selectDateTime,
                  ),
                  buildTextField(
                    controller: durasiController,
                    label: 'Durasi (Menit)',
                    icon: Icons.timer,
                    hint: 'Masukkan durasi penerbangan',
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Unggah Logo Maskapai",
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
                                  Text('Unggah Logo', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: savePesawat,
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
                const Text('Daftar Maskapai', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: pesawatBox.listenable(),
                    builder: (context, Box<PesawatModel> box, _) {
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
              valueListenable: pesawatBox.listenable(),
              builder: (context, Box<PesawatModel> box, _) {
                if (box.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.flight, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada data pesawat yang ditambahkan',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tambahkan data pesawat pertama Anda!',
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
                    final pesawat = box.getAt(index);
                    if (pesawat == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CardPesawatBaru(
                        pesawat: pesawat,
                        onEdit: () => editPesawat(index),
                        onDelete: () => deletePesawat(index),
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
  
  Widget buildDateTimeField({
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
          suffixIcon: const Icon(Icons.calendar_today),
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
