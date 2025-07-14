import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/app_colors.dart';
import '../../../core/utils/location_helper.dart';
import '../../../core/constants.dart';

class LocationSectionWidget extends StatefulWidget {
  final GeoPoint? initialLocation;
  final Function(GeoPoint?) onLocationChanged;
  final bool isLoading;

  const LocationSectionWidget({
    super.key,
    this.initialLocation,
    required this.onLocationChanged,
    this.isLoading = false,
  });

  @override
  State<LocationSectionWidget> createState() => _LocationSectionWidgetState();
}

class _LocationSectionWidgetState extends State<LocationSectionWidget> {
  GeoPoint? _currentLocation;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              _buildLocationStatus(),
              if (_currentLocation == null) _buildLocationWarning(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStatus() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _currentLocation != null ? Colors.green[100] : Colors.orange[100],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            _currentLocation != null ? Icons.location_on : Icons.location_off,
            color: _currentLocation != null ? Colors.green[600] : Colors.orange[600],
            size: 20.w,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentLocation != null ? 'Location Set' : 'No Location',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_currentLocation != null)
                Text(
                  LocationHelper.formatLocation(_currentLocation!),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isGettingLocation || widget.isLoading ? null : _getCurrentLocation,
          icon: _isGettingLocation
              ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location, size: 18),
          label: Text(_currentLocation != null ? 'Update' : 'Get Location'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationWarning() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[600], size: 16.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              AppConstants.locationRequiredError,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final location = await LocationHelper.getCurrentLocation();
      setState(() {
        _currentLocation = location;
      });
      widget.onLocationChanged(location);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20.w),
                SizedBox(width: 8.w),
                const Text(AppConstants.locationAcquiredSuccess),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20.w),
                SizedBox(width: 8.w),
                Expanded(child: Text('Failed to get location: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      }
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }
}