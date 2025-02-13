import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchTransaksi() async {
    final response = await supabase
        .from('penjualan')
        .select('penjualanid, tanggalpenjualan, totalharga, pelanggan(namapelanggan)');
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchDetailTransaksi(int penjualanId) async {
    final response = await supabase
        .from('detailpenjualan')
        .select('produk(namaproduk), jumlahproduk, subtotal')
        .eq('penjualanid', penjualanId);
    return response;
  }

  void showDetailDialog(int penjualanId, String tanggal, String pelanggan, double total) async {
    final details = await fetchDetailTransaksi(penjualanId);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detail Transaksi'),
          content: details.isEmpty
              ? const Text('Tidak ada detail transaksi.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: details.map((detail) {
                    return ListTile(
                      title: Text(detail['produk']['namaproduk']),
                      subtitle: Text('Jumlah: ${detail['jumlahproduk']}'),
                      trailing: Text('Rp ${detail['subtotal']}'),
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showStrukDialog(penjualanId, tanggal, pelanggan, total, details);
              },
              child: const Text('Cetak Struk'),
            ),
          ],
        );
      },
    );
  }

  void showStrukDialog(int penjualanId, String tanggal, String pelanggan, double total,
      List<Map<String, dynamic>> details) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Struk Transaksi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Transaksi: $penjualanId'),
              Text('Tanggal: $tanggal'),
              Text('Pelanggan: $pelanggan'),
              const Divider(),
              ...details.map((detail) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${detail['produk']['namaproduk']} x${detail['jumlahproduk']} = Rp ${detail['subtotal']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              const Divider(),
              Text('Total Harga: Rp $total', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchTransaksi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada transaksi.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final transaksi = snapshot.data![index];
              return ListTile(
                title: Text('Tanggal: ${transaksi['tanggalpenjualan']}'),
                subtitle: Text('Pelanggan: ${transaksi['pelanggan']['namapelanggan']}'),
                trailing: Text('Rp ${transaksi['totalharga']}'),
                onTap: () => showDetailDialog(
                  transaksi['penjualanid'],
                  transaksi['tanggalpenjualan'],
                  transaksi['pelanggan']['namapelanggan'],
                  transaksi['totalharga'],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
