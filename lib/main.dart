import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking map demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Parking map demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double _lat = 0;
  final _latController = TextEditingController();

  double _long = 0;
  final _longController = TextEditingController();

  double _z = 19.0;
  final _zController = TextEditingController();

  int _x = 0;
  int _y = 0;

  String _tilePath = '';

  _MyHomePageState() {
    _latController.text = _lat.toString();
    _longController.text = _long.toString();
    _zController.text = _z.toInt().toString();
  }

  void _loadTile() {
    setState(() {
      double eps = 0.0818191908426;
      double p = pow(2.0, _z + 8.0) / 2.0;

      double beta = pi * _lat / 180.0;
      double phi = (1.0 - eps * sin(beta)) / (1.0 + eps * sin(beta));
      double theta = tan(pi / 4 + beta / 2) * pow(phi, eps / 2);

      double xp = p * (1.0 + _long / 180);
      double yp = p * (1.0 - log(theta) / pi);

      _x = (xp / 256.0).floor().toInt();
      _y = (yp / 256.0).floor().toInt();

      _setTilePath(_x, _y, _z.toInt());
    });
  }

  void _setTilePath(int x, int y, int z) {
    setState(() {
      _tilePath = 'https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=$x&y=$y&z=${z}&scale=1&lang=ru_RU';
      // print(_tilePath);
    });
  }

  Widget _tileImage() {
    if (_tilePath == '') {
      return Container();
    } else {
      return Container(
        margin: EdgeInsets.only(top: 10.0),
        padding: EdgeInsets.only(top: 10.0),
        decoration: BoxDecoration(border: Border.all(width: 2.0), borderRadius: BorderRadius.circular(4.0)),
        width: double.infinity,
        child: Image.network(
          _tilePath,
          fit: BoxFit.contain,
          errorBuilder: ((context, error, stackTrace) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Wrong image url'),
              ),
            );
          }),
          // loadingBuilder: (context, child, loadingProgress) {
          //   return CircularProgressIndicator();
          // },
        ),
      );
    }
  }

  _loadDefaultCoordinates() {
    setState(() {
      String defaultCoordinates = '55.773865, 37.544962';
      var coordinatesList = defaultCoordinates.split(',');

      _lat = double.parse(coordinatesList[0]);
      _latController.text = _lat.toString();

      _long = double.parse(coordinatesList[1]);
      _longController.text = _long.toString();

      _z = 19;
      _zController.text = _z.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: _loadDefaultCoordinates, icon: Icon(Icons.download)),
          IconButton(onPressed: _loadTile, icon: Icon(Icons.refresh)),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 4.0, left: 4.0, right: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Latitude
            Container(
              // margin: EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _latController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lattitude',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _lat = double.parse(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Flexible(
                    child: TextField(
                      enabled: false,
                      controller: TextEditingController(text: _x.toString()),
                      decoration: const InputDecoration(
                        labelText: 'x',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Longitude
            Container(
              margin: EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _longController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _long = double.parse(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Flexible(
                    child: TextField(
                      enabled: false,
                      controller: TextEditingController(text: _y.toString()),
                      decoration: const InputDecoration(
                        labelText: 'y',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8.0),
              child: TextField(
                  controller: _zController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'z',
                    border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF000000))),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _z = double.parse(value);
                    });
                  }
              ),
            ),
            _tileImage(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _loadTile();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
