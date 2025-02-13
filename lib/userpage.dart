import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController namaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Mengambil data user dari database
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await supabase.from('user').select();
    return response;
  }

  // Tambah User ke database
  Future<void> tambahUser() async {
    String nama = namaController.text;
    String password = passwordController.text;

    if (nama.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan password tidak boleh kosong')),
      );
      return;
    }

    await supabase.from('user').insert({
      'nama': nama,
      'password': password, // Simpan password (Sebaiknya dienkripsi)
    });

    namaController.clear();
    passwordController.clear();
    setState(() {});
  }

  // Edit User
  Future<void> editUser(int id, String nama, String password) async {
    namaController.text = nama;
    passwordController.text = password;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaController, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await supabase.from('user').update({
                'nama': namaController.text,
                'password': passwordController.text,
              }).eq('id', id);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Hapus User
  Future<void> hapusUser(int id) async {
    await supabase.from('user').delete().eq('id', id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat mengambil data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada user terdaftar'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(user['nama'] ?? 'Tanpa Nama'),
                  subtitle: Text('Password: ${user['password'] ?? 'Tidak ada password'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editUser(user['id'], user['nama'], user['password']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => hapusUser(user['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          namaController.clear();
          passwordController.clear();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Tambah User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: namaController, decoration: const InputDecoration(labelText: 'Nama')),
                  TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    await tambahUser();
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
