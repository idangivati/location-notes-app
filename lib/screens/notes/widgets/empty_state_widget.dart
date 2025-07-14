import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/constants.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            SizedBox(height: 24.h),
            _buildTitle(),
            SizedBox(height: 8.h),
            _buildSubtitle(),
            SizedBox(height: 32.h),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(60.r),
      ),
      child: Icon(
        Icons.note_add_outlined,
        size: 60.w,
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'No notes yet!',
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Create your first location note by tapping the + button below',
      style: TextStyle(
        fontSize: 16.sp,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 20.w,
            color: AppColors.primary,
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              'Notes will automatically save your location',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}