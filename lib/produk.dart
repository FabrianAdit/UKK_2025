import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  State<Produk> createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  final supabase = Supabase.instance.client;
  final List<Map<String, dynamic>> keranjang = [];

  // Mengambil data produk dari database
  Future<List<Map<String, dynamic>>> fetchProduk() async {
    final response = await supabase.from('produk').select();
    return response;
  }

  // Menambah produk baru
  Future<void> tambahProduk(String nama, double harga, int stok) async {
    await supabase.from('produk').insert({
      'namaproduk': nama,
      'harga': harga,
      'stok': stok,
    });
    setState(() {});
  }

  // Mengedit produk
  Future<void> editProduk(int id, String nama, double harga, int stok) async {
    await supabase.from('produk').update({
      'namaproduk': nama,
      'harga': harga,
      'stok': stok,
    }).eq('produkid', id);
    setState(() {});
  }

  // Menghapus produk
  Future<void> hapusProduk(int id) async {
    await supabase.from('produk').delete().eq('produkid', id);
    setState(() {});
  }

  // Menampilkan dialog tambah/edit produk
  void showProdukDialog({int? id, String? nama, double? harga, int? stok}) {
    TextEditingController namaController = TextEditingController(text: nama ?? '');
    TextEditingController hargaController = TextEditingController(text: harga?.toString() ?? '');
    TextEditingController stokController = TextEditingController(text: stok?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? 'Tambah Produk' : 'Edit Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaController, decoration: const InputDecoration(labelText: 'Nama Produk')),
            TextField(controller: hargaController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
            TextField(controller: stokController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              String namaProduk = namaController.text;
              double hargaProduk = double.tryParse(hargaController.text) ?? 0;
              int stokProduk = int.tryParse(stokController.text) ?? 0;

              if (id == null) {
                await tambahProduk(namaProduk, hargaProduk, stokProduk);
              } else {
                await editProduk(id, namaProduk, hargaProduk, stokProduk);
              }

              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => showProdukDialog()),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchProduk(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat mengambil data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada produk tersedia'));
          }

          final daftarProduk = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: daftarProduk.length,
            itemBuilder: (context, index) {
              final produk = daftarProduk[index];
              return ProdukItem(
                produk: produk,
                onEdit: showProdukDialog,
                onDelete: hapusProduk,
              );
            },
          );
        },
      ),
    );
  }
}

class ProdukItem extends StatelessWidget {
  final Map<String, dynamic> produk;
  final Function({int? id, String? nama, double? harga, int? stok}) onEdit;
  final Function(int) onDelete;

  const ProdukItem({super.key, required this.produk, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(produk['namaproduk'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Harga: Rp ${produk['harga']} | Stok: ${produk['stok']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => onEdit(
              id: produk['produkid'], 
              nama: produk['namaproduk'], 
              harga: produk['harga'], 
              stok: produk['stok'],
            )),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => onDelete(produk['produkid'])),
          ],
        ),
      ),
    );
  }
}
