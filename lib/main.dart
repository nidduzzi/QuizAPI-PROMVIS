import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

String API_ROOT = "http://178.128.17.76:8000";

class PinjamanModel {
  int id;
  String nama;
  String bunga = "";
  String isSyariah = "";
  PinjamanModel({required this.id, required this.nama});
}

class PinjamanCubit extends Cubit<PinjamanModel> {
  String url = "$API_ROOT/detil_jenis_pinjaman/";

  PinjamanCubit() : super(PinjamanModel(id: -1, nama: ""));

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    if (json["error"] != null) throw Exception('data kosong');
    int id = int.parse(json['id']);
    String nama = json['nama'];
    String bunga = json['bunga'];
    String isSyariah = json['is_syariah'];
    var tmp = PinjamanModel(id: id, nama: nama);
    tmp.bunga = bunga;
    tmp.isSyariah = isSyariah;
    emit(tmp);
  }

  void fetchData(int id) async {
    final response = await http.get(Uri.parse("$url$id"));
    if (response.statusCode == 200) {
      developer.log("$url$id");
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class PinjamanListModel {
  List<PinjamanModel> list;
  PinjamanListModel({required this.list});
}

class PinjamanListCubit extends Cubit<PinjamanListModel> {
  String url = "$API_ROOT/jenis_pinjaman/";
  PinjamanListCubit() : super(PinjamanListModel(list: []));

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    List<PinjamanModel> pinjanmanList = <PinjamanModel>[];
    if (json["error"] != null) throw Exception('data kosong');
    var data = json["data"];
    for (var val in data) {
      int id = int.parse(val['id']);
      String nama = val['nama'];
      pinjanmanList.add(PinjamanModel(id: id, nama: nama));
    }
    emit(PinjamanListModel(list: pinjanmanList));
  }

  void fetchData(int jenisPinjaman) async {
    final response = await http.get(Uri.parse("$url$jenisPinjaman"));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App P2P',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepOrange,
      ),
      home: BlocProvider(
          create: (_) => PinjamanListCubit(),
          child: const PinjamanListPage(title: 'My App P2P')),
    );
  }
}

class PinjamanListPage extends StatefulWidget {
  const PinjamanListPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<PinjamanListPage> createState() => _PinjamanListPageState();
}

class _PinjamanListPageState extends State<PinjamanListPage> {
  int? jenisSelected;
  int? jenisOut;
  PinjamanModel? pinjamanSelected;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: BlocBuilder<PinjamanListCubit, PinjamanListModel>(
        buildWhen: (previousState, state) {
          developer.log(
              "${previousState.list.toString()} -> ${state.list.toString()}",
              name: 'State Change');
          return true;
        },
        builder: (context, pinjamanList) {
          return Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                    "1908919,Ahmad Izzuddin;1904601,Thariq Hafizhuddin;Saya berjanji tidak berbuat curang data atau membantu orang lain berbuat curang"),
                DropdownButton(
                  value: jenisSelected,
                  items: [1, 2, 3]
                      .map<DropdownMenuItem<int>>((e) => (DropdownMenuItem<int>(
                            value: e,
                            child: Text(e.toString()),
                          )))
                      .toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      if (newValue != null) {
                        jenisSelected = newValue;
                        jenisOut = newValue;
                        context.read<PinjamanListCubit>().fetchData(newValue);
                      }
                    });
                  },
                  hint: const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Pilih jenis pinjaman",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Center(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(20),
                        itemCount: pinjamanList.list.length,
                        itemBuilder: (context, index) {
                          var pinjaman = pinjamanList.list[index];
                          return Container(
                              decoration: BoxDecoration(border: Border.all()),
                              padding: const EdgeInsets.all(14),
                              child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return BlocProvider(
                                          create: (_) => PinjamanCubit(),
                                          child: PinjamanDetailPage(
                                              title: 'My App P2P',
                                              id: pinjaman.id));
                                    }));
                                  },
                                  leading: Image.network(
                                      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                                  trailing: const Icon(Icons.more_vert),
                                  title: Text(pinjaman.nama),
                                  subtitle: Text("id: ${pinjaman.id}"),
                                  tileColor: Colors.white70));
                        })),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PinjamanDetailPage extends StatefulWidget {
  const PinjamanDetailPage({super.key, required this.title, required this.id});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final int id;

  @override
  State<PinjamanDetailPage> createState() => _PinjamanDetailState();
}

class _PinjamanDetailState extends State<PinjamanDetailPage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: BlocBuilder<PinjamanCubit, PinjamanModel>(
            buildWhen: (previousState, state) {
          developer.log(
              "${previousState.id.toString()} -> ${state.id.toString()}",
              name: 'State Change');
          return true;
        }, builder: (context, pinjaman) {
          if (pinjaman.id == -1) {
            context.read<PinjamanCubit>().fetchData(widget.id);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('id: ${pinjaman.id.toString()}'),
                Text('nama: ${pinjaman.nama}'),
                Text('bunga: ${pinjaman.bunga}'),
                Text('syariah: ${pinjaman.isSyariah}'),
              ],
            ),
          );
        }));
  }
}
