import 'package:btp/presentation/extension/utils_extension.dart';
import 'package:btp/presentation/screen/search/arguments/search_screen_arguments.dart';
import 'package:btp/presentation/theme/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

import 'driver_home_view_model.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DriverHomeViewModel>(
      create: (context) => DriverHomeViewModel(context),
      child: Consumer<DriverHomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            key: _scaffoldKey,
            body: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        zoomControlsEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: viewModel.pickUpLocation,
                          zoom: 16,
                        ),
                        onCameraMove: (CameraPosition? position) {
                          if (viewModel.pickUpLocation != position!.target) {
                            viewModel.onCameraPositionChange(position.target);
                          }
                        },
                        onCameraIdle: () {
                          if (viewModel.sourcePosition == null) {
                            viewModel.getAddressFromPickUpMovement();
                          }
                        },
                        onMapCreated: (GoogleMapController controller) {
                          viewModel.controller.complete(controller);
                        },
                        markers: {
                          if (viewModel.sourcePosition != null)
                            viewModel.sourcePosition!
                        },
                      ),
                      if (viewModel.sourcePosition == null) ...[
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 35.0),
                            child: Image.asset(
                              'assets/images/pick.png',
                              height: 45,
                              width: 45,
                            ),
                          ),
                        ),
                      ],
                      Positioned(
                        top: 40,
                        right: 20,
                        left: 20,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _openDrawer,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.menu,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/rider/search_screen',
                                    arguments: SearchScreenArguments(
                                      'pickup',
                                      viewModel.pickUpLocation,
                                    ),
                                  ).then((result) async {
                                    if (result != null) {
                                      var prediction = result as Prediction;
                                      GoogleMapsPlaces googleMapsPlaces =
                                          GoogleMapsPlaces(
                                        apiKey:
                                            'AIzaSyDschydseXpu7lOGtBorLzIzWl-rEr2a24',
                                      );
                                      PlacesDetailsResponse details =
                                          await googleMapsPlaces
                                              .getDetailsByPlaceId(
                                        prediction.placeId!,
                                      );
                                      LatLng latLng = LatLng(
                                        (details
                                            .result.geometry?.location.lat)!,
                                        (details
                                            .result.geometry?.location.lng)!,
                                      );
                                      Marker marker = Marker(
                                        markerId: MarkerId(prediction.placeId!),
                                        position: latLng,
                                        infoWindow: InfoWindow(
                                          title: prediction.description,
                                          snippet:
                                              details.result.formattedAddress,
                                        ),
                                      );
                                      viewModel.addSourcePositionMarker(
                                          latLng, marker);
                                    }
                                  });
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    alignment: Alignment.centerLeft,
                                    height: 50,
                                    child: Text(
                                      viewModel.pickUpLocationAddress ??
                                          'Enter pickup location',
                                      style: GoogleFonts.openSans(
                                        textStyle: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/rider/search_screen',
                        arguments: SearchScreenArguments(
                          'destination',
                          viewModel.pickUpLocation,
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        height: 50,
                        child: Text(
                          'Enter drop location',
                          style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.green,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 32,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver Name',
                                  style: GoogleFonts.openSans(
                                    textStyle: const TextStyle(
                                      color: primaryTextColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Driver Number',
                                  style: GoogleFonts.openSans(
                                    textStyle: const TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Divider(
                          height: 0,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        ListTile(
                          onTap: () {
                            _closeDrawer();
                            showScaffoldMessenger(
                                context, 'My Rides', primaryTextColor);
                          },
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.orange.shade500,
                            ),
                            child: const Icon(
                              Icons.timelapse_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'My Rides',
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ListTile(
                          onTap: () async {
                            _closeDrawer();
                            Navigator.pushNamed(
                              context,
                              '/driver_settings_screen',
                            );
                          },
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.red.shade500,
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'Settings',
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ListTile(
                          onTap: () async {
                            _closeDrawer();
                            showScaffoldMessenger(
                                context, 'Support', primaryTextColor);
                          },
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.grey.shade500,
                            ),
                            child: const Icon(
                              Icons.support_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'Support',
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ListTile(
                          onTap: () async {
                            _closeDrawer();
                            // todo clear all floor database
                            await FirebaseAuth.instance.signOut().then((value) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login_screen',
                                (r) => false,
                              );
                            });
                          },
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.orange.shade500,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'Logout',
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}