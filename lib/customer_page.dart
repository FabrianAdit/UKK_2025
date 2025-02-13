import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> customers = [];

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final response = await supabase.from('pelanggan').select();
    setState(() {
      customers = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> addCustomer(String name, String address, String phone) async {
    await supabase.from('pelanggan').insert({
      'namapelanggan': name,
      'alamat': address,
      'nomortelepon': phone,
    });
    fetchCustomers();
  }

  Future<void> updateCustomer(int id, String name, String address, String phone) async {
    await supabase.from('pelanggan').update({
      'namapelanggan': name,
      'alamat': address,
      'nomortelepon': phone,
    }).eq('pelangganid', id);
    fetchCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    await supabase.from('pelanggan').delete().eq('pelangganid', id);
    fetchCustomers();
  }

  void showCustomerDialog({int? id, String? name, String? address, String? phone}) {
    final TextEditingController nameController = TextEditingController(text: name);
    final TextEditingController addressController = TextEditingController(text: address);
    final TextEditingController phoneController = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? 'Tambah Pelanggan' : 'Edit Pelanggan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Alamat')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Nomor Telepon')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (id == null) {
                addCustomer(nameController.text, addressController.text, phoneController.text);
              } else {
                updateCustomer(id, nameController.text, addressController.text, phoneController.text);
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
      appBar: AppBar(title: const Text('Pelanggan')),
      body: customers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  title: Text(customer['namapelanggan'] ?? 'Tanpa Nama'),
                  subtitle: Text(customer['alamat'] ?? 'Alamat tidak tersedia'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showCustomerDialog(
                          id: customer['pelangganid'],
                          name: customer['namapelanggan'],
                          address: customer['alamat'],
                          phone: customer['nomortelepon'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteCustomer(customer['pelangganid']),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCustomerDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
