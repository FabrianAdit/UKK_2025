import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({super.key});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> products = [];
  List<dynamic> customers = [];
  Map<int, int> cart = {}; // Key: produkid, Value: jumlah
  int? selectedCustomerId;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCustomers();
  }

  Future<void> fetchProducts() async {
    final response = await supabase.from('produk').select();
    setState(() {
      products = response;
    });
  }

  Future<void> fetchCustomers() async {
    final response = await supabase.from('pelanggan').select();
    setState(() {
      customers = response;
    });
  }

  void addToCart(int produkid) {
    setState(() {
      cart[produkid] = (cart[produkid] ?? 0) + 1;
    });
  }

  void removeFromCart(int produkid) {
    setState(() {
      if (cart.containsKey(produkid) && cart[produkid]! > 1) {
        cart[produkid] = cart[produkid]! - 1;
      } else {
        cart.remove(produkid);
      }
    });
  }

  double calculateTotal() {
    double total = 0;
    for (var entry in cart.entries) {
      final product = products.firstWhere((p) => p['produkid'] == entry.key);
      total += (product['harga'] as double) * entry.value;
    }
    return total;
  }

  Future<void> processPayment() async {
    if (cart.isEmpty || selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pelanggan dan tambahkan produk!')),
      );
      return;
    }

    // Tampilkan konfirmasi pembayaran
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Tanggal: ${DateTime.now().toLocal()}"),
              Text("Pelanggan: ${customers.firstWhere((c) => c['pelangganid'] == selectedCustomerId)['namapelanggan']}"),
              const Divider(),
              ...cart.entries.map((entry) {
                final product = products.firstWhere((p) => p['produkid'] == entry.key);
                return ListTile(
                  title: Text(product['namaproduk']),
                  subtitle: Text("Jumlah: ${entry.value} x ${product['harga']}"),
                  trailing: Text("Rp ${(product['harga'] * entry.value).toStringAsFixed(2)}"),
                );
              }).toList(),
              const Divider(),
              Text("Total: Rp ${calculateTotal().toStringAsFixed(2)}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await saveTransaction();
              },
              child: const Text('Bayar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveTransaction() async {
    try {
      // 1️⃣ Simpan ke tabel `penjualan`
      final response = await supabase.from('penjualan').insert({
        'pelangganid': selectedCustomerId,
        'tanggalpenjualan': DateTime.now().toIso8601String(),
        'totalharga': calculateTotal(),
      }).select('penjualanid').single();

      final int penjualanId = response['penjualanid'];

      // 2️⃣ Simpan ke tabel `detailpenjualan`
      for (var entry in cart.entries) {
        final product = products.firstWhere((p) => p['produkid'] == entry.key);
        await supabase.from('detailpenjualan').insert({
          'penjualanid': penjualanId,
          'produkid': entry.key,
          'jumlahproduk': entry.value,
          'subtotal': product['harga'] * entry.value,
        });
      }

      // 3️⃣ Bersihkan keranjang setelah transaksi berhasil
      setState(() {
        cart.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil! Data disimpan.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<int>(
              value: selectedCustomerId,
              hint: const Text('Pilih Pelanggan'),
              onChanged: (value) {
                setState(() {
                  selectedCustomerId = value;
                });
              },
              items: customers.map<DropdownMenuItem<int>>((customer) {
                return DropdownMenuItem<int>(
                  value: customer['pelangganid'],
                  child: Text(customer['namapelanggan']),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(product['namaproduk']),
                    subtitle: Text("Harga: Rp ${product['harga']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => removeFromCart(product['produkid']),
                        ),
                        Text(cart[product['produkid']]?.toString() ?? '0'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => addToCart(product['produkid']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: processPayment,
              child: const Text('Proses Pembayaran'),
            ),
          ),
        ],
      ),
    );
  }
}
