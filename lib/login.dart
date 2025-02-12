import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart'; //ui login pakai library supabase_auth_ui, dari dokumentasi
import 'produk.dart';

class Login extends StatelessWidget { //pakai widget parent statelesswidget
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( //pakai widget scaffold, isi halaman dibungkus pakai widget scaffold
      //bagian appbar
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true, //judul login di appbar ada di tengah
      ),
      //bagian body halaman
      body: Padding(
        padding: const EdgeInsets.all(
            16.0), //jarak dari samping supaya tidak menempel dengan bagian samping, jaraknya di semua sisi
        child: SupaEmailAuth( //ini template dari halaman library supabase nya
          redirectTo: 'produk', //pergi ke halaman produk setelah login
          onSignInComplete: (response) { //aksi setelah login
            //setelah login, ke halaman produk
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Produk()) //pergi ke class produk di file produk.dart
            );
          },
          onSignUpComplete: (response) { //aksi setelah daftar akun
            //setelah daftar, pergi ke halaman produk
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Produk()),
            );
          },
          metadataFields: [
            MetaDataField(
              prefixIcon: const Icon(Icons.person),
              label: 'Username',
              key: 'username',
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Username tidak boleh kosong';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
