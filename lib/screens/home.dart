import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_flutter/requests/google_maps_requests.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Map(),
    );
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return _initialPosition == null
        ? Container(
            alignment: Alignment.center,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 10,
                ),
                onMapCreated: onCreated,
                myLocationEnabled: true,
                mapType: MapType.normal,
                compassEnabled: true,
                markers: _markers,
                onCameraMove: _onCameraMove,
              ),
              Positioned(
                top: 50,
                right: 15,
                left: 15,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(1, 5),
                          blurRadius: 10,
                          spreadRadius: 3),
                    ],
                  ),
                  child: TextField(
                    cursorColor: Colors.black,
                    controller: locationController,
                    decoration: InputDecoration(
                      icon: Container(
                        margin: EdgeInsets.only(left: 20, top: 5),
                        width: 10,
                        height: 10,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.black,
                        ),
                      ),
                      hintText: 'Pick Up',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: 15,
                        top: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 105,
                right: 15,
                left: 15,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1, 5),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: TextField(
                    cursorColor: Colors.black,
                    controller: destinationController,
                    decoration: InputDecoration(
                      icon: Container(
                        margin: EdgeInsets.only(left: 20, top: 5),
                        width: 10,
                        height: 10,
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.black,
                        ),
                      ),
                      hintText: 'Destination?',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: 15,
                        top: 16,
                      ),
                    ),
                  ),
                ),
              ),
              /*Positioned(
          top: 40,
          right: 10,
          child: FloatingActionButton(
            onPressed: _onAddMarkerPressed,
            tooltip: 'Add Marker',
            backgroundColor: black,
            child: Icon(
              Icons.add_location,
              color: white,
            ),
          ),
        ),*/
            ],
          );
  }

  void onCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _lastPosition = position.target;
    });
  }

  void _onAddMarkerPressed() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(
            _lastPosition.toString(),
          ),
          position: _lastPosition,
          infoWindow: InfoWindow(
            title: 'Remember Here',
            snippet: 'Good Place',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  List<LatLng> converToLatLng(List points) {
    List<LatLng> result = <LatLng>[];

    for (int i = 0; i < points.length; i++) {
      if (i % 2 == 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }

    return result;
  }

  List decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = List();
    int index = 0;
    int len = poly.length;
    int c = 0;

    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);

      if (result & 1 == 1) {
        result = ~result;
      }

      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  void _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      locationController.text = placeMark[0].name;
    });
  }
}
