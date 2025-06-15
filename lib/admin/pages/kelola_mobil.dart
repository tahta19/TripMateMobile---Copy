import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripmate_mobile/models/mobil_model.dart';
import 'package:tripmate_mobile/admin/widgets/card_mobil_baru.dart';

class KelolaMobilPage extends StatefulWidget {
  final VoidCallback? onBack;
  const KelolaMobilPage({Key? key, this.onBack}) : super(key: key);

  @override
  State<KelolaMobilPage> createState() => _KelolaMobilPageState();
}

class _KelolaMobilPageState extends State<KelolaMobilPage> {
  final _formKey = GlobalKey<FormState>();
  late final Box<MobilModel> mobilBox;
  final ScrollController _scrollController = ScrollController();

  final merkController = TextEditingController();
  final hargaController = TextEditingController();

  final List<String> jumlahPenumpangList = ['4 Penumpang', '6 Penumpang', '8 Penumpang'];
  final List<String> tipeList = ['Otomatis', 'Manual'];

  String? selectedJumlahPenumpang;
  String? selectedTipe;
  String? imageBase64;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    try {
      mobilBox = Hive.box<MobilModel>('mobilBox');
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    merkController.dispose();
    hargaController.dispose();
    super.dispose();
  }

  void resetForm() {
    merkController.clear();
    hargaController.clear();
    selectedJumlahPenumpang = null;
    selectedTipe = null;
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
                'Apakah Anda yakin ingin memperbarui data mobil ini?',
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
                    Text('• Merk: ${merkController.text}'),
                    Text('• Penumpang: $selectedJumlahPenumpang'),
                    Text('• Transmisi: $selectedTipe'),
                    Text('• Harga: Rp ${hargaController.text}/hari'),
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
      final mobil = MobilModel(
        merk: merkController.text,
        jumlahPenumpang: selectedJumlahPenumpang ?? '',
        tipeMobil: selectedTipe ?? '',
        hargaSewa: int.tryParse(hargaController.text) ?? 0,
        imageBase64: imageBase64 ?? '',
      );

      await mobilBox.putAt(editingIndex!, mobil);

      setState(() {});
      resetForm();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Data mobil berhasil diperbarui!'),
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
                Text('Error memperbarui mobil: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void saveMobil() async {
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
              Text('Gambar mobil wajib diunggah'),
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
      final mobil = MobilModel(
        merk: merkController.text,
        jumlahPenumpang: selectedJumlahPenumpang ?? '',
        tipeMobil: selectedTipe ?? '',
        hargaSewa: int.tryParse(hargaController.text) ?? 0,
        imageBase64: imageBase64 ?? '',
      );

      await mobilBox.add(mobil);

      setState(() {});
      resetForm();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Data mobil berhasil disimpan!'),
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
                Text('Error menyimpan mobil: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void editMobil(int index) {
    final mobil = mobilBox.getAt(index);
    if (mobil != null) {
      setState(() {
        editingIndex = index;
        merkController.text = mobil.merk;
        selectedJumlahPenumpang = mobil.jumlahPenumpang;
        selectedTipe = mobil.tipeMobil;
        hargaController.text = mobil.hargaSewa.toString();
        imageBase64 = mobil.imageBase64;
      });
      
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void deleteMobil(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data mobil ini?'),
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
        await mobilBox.deleteAt(index);
        
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Data mobil berhasil dihapus!'),
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
                'Kelola Mobil',
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
              editingIndex == null ? 'Masukkan Data Mobil' : 'Edit Data Mobil',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField(
                    controller: merkController,
                    label: 'Merk Mobil',
                    icon: Icons.directions_car,
                    hint: 'Masukkan merk mobil',
                  ),
                  buildDropdownField(
                    label: 'Jumlah Penumpang',
                    icon: Icons.people,
                    items: jumlahPenumpangList,
                    selectedValue: selectedJumlahPenumpang,
                    onChanged: (value) => setState(() => selectedJumlahPenumpang = value),
                  ),
                  buildDropdownField(
                    label: 'Tipe Transmisi',
                    icon: Icons.settings,
                    items: tipeList,
                    selectedValue: selectedTipe,
                    onChanged: (value) => setState(() => selectedTipe = value),
                  ),
                  buildTextField(
                    controller: hargaController,
                    label: 'Harga Sewa per Hari',
                    icon: Icons.attach_money,
                    hint: 'Masukkan harga sewa',
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Unggah Gambar Mobil",
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
                                  Text('Unggah Gambar', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: saveMobil,
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
                const Text('Daftar Mobil', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: mobilBox.listenable(),
                    builder: (context, Box<MobilModel> box, _) {
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
              valueListenable: mobilBox.listenable(),
              builder: (context, Box<MobilModel> box, _) {
                if (box.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.directions_car, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada data mobil yang ditambahkan',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tambahkan data mobil pertama Anda!',
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
                    final mobil = box.getAt(index);
                    if (mobil == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CardMobilBaru(
                        mobil: mobil,
                        onEdit: () => editMobil(index),
                        onDelete: () => deleteMobil(index),
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
