import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_dialog.dart';

/// Halaman Submit Tugas PBM
class SubmitTaskScreen extends StatefulWidget {
  const SubmitTaskScreen({super.key});

  @override
  State<SubmitTaskScreen> createState() => _SubmitTaskScreenState();
}

class _SubmitTaskScreenState extends State<SubmitTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _githubController = TextEditingController();

  bool _isFetchingProducts = true;
  String? _fetchError;

  List<Product> _products = [];
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// Mengambil daftar novel untuk pilihan dropdown
  Future<void> _loadProducts() async {
    setState(() {
      _isFetchingProducts = true;
      _fetchError = null;
    });
    try {
      final products = await ProductService.getProducts();
      if (mounted) setState(() => _products = products);
    } on ApiException catch (e) {
      if (mounted) setState(() => _fetchError = e.message);
    } finally {
      if (mounted) setState(() => _isFetchingProducts = false);
    }
  }

  /// Auto-fill harga dan deskripsi saat produk dipilih
  void _onProductSelected(Product? product) {
    setState(() => _selectedProduct = product);
    if (product != null) {
      _priceController.text = product.price.toString();
      _descController.text = product.description;
    } else {
      _priceController.clear();
      _descController.clear();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: _primary),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Submit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin mensubmit tugas ini? Data yang sudah dikirim tidak dapat diubah kembali.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ya, Submit'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    LoadingDialog.show(context, message: 'Mengirim tugas...');

    try {
      final price = int.parse(_priceController.text.trim());
      await ProductService.submitTask(
        name: _selectedProduct!.name,
        price: price,
        description: _descController.text.trim(),
        githubUrl: _githubController.text.trim(),
      );

      if (mounted) {
        LoadingDialog.hide(context); // Tutup loading

        _showSuccessDialog();
      }
    } on ApiException catch (e) {
      if (mounted) {
        LoadingDialog.hide(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(e.message)),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) LoadingDialog.hide(context);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade600,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tugas Berhasil Disubmit!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  static const _primary = Color(0xFFFF7F87);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3F4),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFF7F87),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  // Tombol kembali
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Submit Tugas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Spacer agar teks tetap center
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Submit tugas bersifat final. Pastikan semua data sudah benar sebelum submit.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ===== Pilih Novel (Dropdown) =====
              const Text(
                'Tambah Novel',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildProductDropdown(),
              const SizedBox(height: 20),

              // ===== Harga (auto-fill mengikuti produk dipilih) =====
              const Text(
                'Harga (Rp)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (_selectedProduct != null)
                _buildReadOnlyField(
                  icon: Icons.payments_outlined,
                  value: NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(_selectedProduct!.price),
                )
              else
                CustomTextField(
                  controller: _priceController,
                  label: 'Harga',
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    final price = int.tryParse(val.trim());
                    if (price == null || price <= 0) {
                      return 'Harga harus angka positif';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),

              // ===== Deskripsi (auto-fill mengikuti produk dipilih) =====
              const Text(
                'Deskripsi',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (_selectedProduct != null)
                _buildReadOnlyField(
                  icon: Icons.description_outlined,
                  value: _selectedProduct!.description,
                  multiline: true,
                )
              else
                CustomTextField(
                  controller: _descController,
                  label: 'Deskripsi',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),

              // ===== GitHub URL =====
              const Text(
                'GitHub URL',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _githubController,
                label: 'GitHub URL',
                hint: 'https://github.com/username/repo',
                prefixIcon: Icons.link_rounded,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'GitHub URL tidak boleh kosong';
                  }
                  if (!val.trim().startsWith('https://github.com/')) {
                    return 'URL harus dimulai dengan https://github.com/';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Submit Tugas',
                onPressed: _submit,
                isLoading: false,
                icon: Icons.send_rounded,
                backgroundColor: _primary,
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Batal',
                onPressed: () => Navigator.of(context).pop(),
                isLoading: false,
                backgroundColor: Colors.grey.shade200,
                textColor: Colors.grey.shade800,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Info card untuk field yang terisi otomatis dari produk terpilih
  Widget _buildReadOnlyField({
    required IconData icon,
    required String value,
    bool multiline = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: multiline ? 1.5 : null,
              ),
            ),
          ),
          Icon(
            Icons.lock_outline_rounded,
            color: _primary.withValues(alpha: 0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  /// Dropdown pemilihan produk dengan state loading/error/empty
  Widget _buildProductDropdown() {
    // Saat loading
    if (_isFetchingProducts) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
            ),
            const SizedBox(width: 12),
            Text(
              'Memuat daftar novel...',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Saat error fetch
    if (_fetchError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _fetchError!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: _loadProducts,
              style: TextButton.styleFrom(foregroundColor: _primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Saat produk kosong
    if (_products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: Colors.grey.shade400,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Tidak ada novel draft. Tambahkan novel terlebih dahulu.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Dropdown untuk pemilihan Novel
    return DropdownButtonFormField<Product>(
      initialValue: _selectedProduct,
      isExpanded: true,
      itemHeight: 70,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: 'Pilih Novel',
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        prefixIcon: const Icon(
          Icons.menu_book_rounded,
          color: _primary,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      hint: Text(
        'Pilih novel...',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      selectedItemBuilder: (BuildContext context) {
        return _products.map<Widget>((Product product) {
          return Text(
            product.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        }).toList();
      },
      items: _products.map((product) {
        final formatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );
        return DropdownMenuItem<Product>(
          value: product,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: _primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatter.format(product.price),
                      style: const TextStyle(
                        fontSize: 12,
                        color: _primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: _onProductSelected,
      validator: (_) =>
          _selectedProduct == null ? 'Pilih novel terlebih dahulu' : null,
    );
  }
}
