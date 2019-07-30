import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_flutter/requests/google_maps_requests.dart';

class AppState with ChangeNotifier {
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapController _mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();

  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  LatLng get initialPosition => _initialPosition;

  LatLng get lastPosition => _lastPosition;

  GoogleMapsServices get googleMapsServices => _googleMapsServices;

  GoogleMapController get googleMapController => _mapController;

  Set<Marker> get markers => _markers;

  Set<Polyline> get polyLines => _polyLines;

  AppState() {
    _getUserLocation();
  }

  void _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    _initialPosition = LatLng(position.latitude, position.longitude);
    locationController.text = placeMark[0].name;
    notifyListeners();
  }

  void createRoute(String encodedPoly) {
    _polyLines.add(Polyline(
      polylineId: PolylineId(_lastPosition.toString()),
      width: 10,
      points: converToLatLng(decodePoly(encodedPoly)),
      color: Colors.black,
    ));
    notifyListeners();
  }

  void _addMarker(LatLng location, String address) {
    _markers.add(
      Marker(
        markerId: MarkerId(
          _lastPosition.toString(),
        ),
        position: location,
        infoWindow: InfoWindow(
          title: address,
          snippet: 'Go Here!',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
    notifyListeners();
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

  void sendRequest(String intendedLocation) async {
    List<Placemark> placeMark =
        await Geolocator().placemarkFromAddress(intendedLocation);
    double latitude = placeMark[0].position.latitude;
    double longitude = placeMark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    _addMarker(destination, intendedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(
        _initialPosition, destination);
    createRoute(route);
    notifyListeners();
  }

  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    notifyListeners();
  }

  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }
}
