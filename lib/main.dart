import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_offline/api_service.dart';
import 'package:flutter_offline/local_database_manager.dart';
import 'package:flutter_offline/network_status_provider.dart';
import 'package:flutter_offline/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NetworkStatusProvider()),
        Provider(create: (context) => LocalDatabaseManager()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage(
          localDatabase: LocalDatabaseManager(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final LocalDatabaseManager localDatabase;

  const MyHomePage({
    Key? key,
    required this.localDatabase,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<User> sampleData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Data Sync'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: Connectivity().onConnectivityChanged,
              builder: (BuildContext context,
                  AsyncSnapshot<ConnectivityResult> snapshot) {
                final networkStatus = snapshot.data ?? ConnectivityResult.none;
                final localDatabase = context.read<LocalDatabaseManager>();

                if (networkStatus == ConnectivityResult.none) {
                  // Offline: Tampilkan pesan atau widget ketika offline
                  return const Center(
                    child: Text('Connectivity Status : Offline'),
                  );
                } else {
                  // Online: Sinkronisasi data
                  sampleData.clear();
                  syncData(localDatabase);
                  return const Center(
                    child: Text('Connectivity Status : Online'),
                  );
                }
              },
            ),
          ),
          sampleData.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: sampleData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = sampleData[index];
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                      );
                    },
                  ),
                )
              : const SizedBox(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveSampleData();
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> syncData(LocalDatabaseManager localDatabase) async {
    final List<User> localUsers = await localDatabase.getUsers();
    for (User user in localUsers) {
      // Kirim data ke server
      await ApiService.sendUserToServer(user);
    }
    // Hapus data dari database lokal setelah berhasil dikirim
    // atau Anda dapat menandai data yang sudah dikirim dan menghapusnya jika diperlukan
    await localDatabase.deleteSyncedUsers(localUsers);
    const snackBar = SnackBar(
      content: Text('Sync data success!'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print('Sinkronisasi data melalui API sukses!');
  }

  Future<void> saveSampleData() async {
    final user1 = User(
        id: 3,
        name: 'John Doe',
        email: 'johndoe@example.com',
        password: 'password',
        avatar: 'https://picsum.photos/800');
    final user2 = User(
        id: 4,
        name: 'Jane Smith',
        email: 'janesmith@example.com',
        password: 'password',
        avatar: 'https://picsum.photos/800');
    await widget.localDatabase.insertUser(user1);
    await widget.localDatabase.insertUser(user2);
    print('Sample data berhasil disimpan di DB LOCAL');
    const snackBar = SnackBar(
      content: Text('Save data to LOCAL DB'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    final List<User> localUsers = await widget.localDatabase.getUsers();
    setState(() {
      sampleData = localUsers;
    });
  }
}
