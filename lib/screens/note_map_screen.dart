import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/note_provider.dart';
import '../models/note.dart';
import 'note_screen.dart';

class NoteMapScreen extends ConsumerStatefulWidget {
  const NoteMapScreen({super.key});

  @override
  ConsumerState<NoteMapScreen> createState() => _NoteMapScreenState();
}

class _NoteMapScreenState extends ConsumerState<NoteMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);

    if (notesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notesState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Error loading notes',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              notesState.error!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (notesState.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80.w, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'No notes to display on the map yet!',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Add some notes with locations to see them here.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Create markers from notes
    _markers = notesState.notes.map((note) {
      return Marker(
        markerId: MarkerId(note.id),
        position: LatLng(note.location.latitude, note.location.longitude),
        infoWindow: InfoWindow(
          title: note.title,
          snippet: note.body.length > 50 
              ? '${note.body.substring(0, 50)}...' 
              : note.body,
        ),
        onTap: () => _onMarkerTapped(note),
      );
    }).toSet();

    // Calculate initial camera position
    LatLng initialPosition;
    if (notesState.notes.isNotEmpty) {
      final firstNote = notesState.notes.first;
      initialPosition = LatLng(
        firstNote.location.latitude, 
        firstNote.location.longitude
      );
    } else {
      initialPosition = const LatLng(32.0853, 34.7818); // Tel Aviv, Israel
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            // Fit all markers after map is created
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fitAllMarkers();
            });
          },
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 12.0,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          zoomControlsEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
        ),
        // Floating button to fit all markers
        if (_markers.length > 1)
          Positioned(
            top: 16.h,
            right: 16.w,
            child: FloatingActionButton.small(
              onPressed: _fitAllMarkers,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.fit_screen),
              tooltip: 'Fit all notes',
            ),
          ),
      ],
    );
  }

  void _onMarkerTapped(Note note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NoteScreen(note: note),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Note',
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Note body
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                note.body,
                style: TextStyle(fontSize: 14.sp),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 12.h),
            
            // Location info
            Row(
              children: [
                Icon(Icons.location_on, size: 16.w, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  'Lat: ${note.location.latitude.toStringAsFixed(4)}, Lon: ${note.location.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _fitAllMarkers() {
    if (_mapController == null || _markers.isEmpty) return;

    if (_markers.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _markers.first.position,
            zoom: 15.0,
          ),
        ),
      );
    } else {
      LatLngBounds bounds = _calculateBounds(_markers);
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (Marker marker in markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}