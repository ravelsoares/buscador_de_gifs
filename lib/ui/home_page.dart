import 'package:buscador_de_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _offset = 0;
  String _search = '';

  Future<Map> _getGifs() async {
    String request;
    if (_search == '') {
      request =
          "https://api.giphy.com/v1/gifs/trending?api_key=3Eddg74I1G9FPorFe1Ya9TNeLgArqXdK&limit=25&rating=g";
    } else {
      request =
          "https://api.giphy.com/v1/gifs/search?api_key=3Eddg74I1G9FPorFe1Ya9TNeLgArqXdK&q=$_search&limit=19&offset=$_offset&rating=g&lang=en";
    }

    http.Response response = await http.get(Uri.parse(request));

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquise aqui!',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        height: 200,
                        width: 200,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 5,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _createGifTable(context, snapshot);
                  }
                }),
          ),
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data['data'].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data['data'][index]['images']['fixed_height']
                    ['url'],
                height: 300,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data['data'][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data['data'][index]['images']
                    ['fixed_height']['url']);
              },
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      'Carregar mais...',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
          }
        });
  }
}
