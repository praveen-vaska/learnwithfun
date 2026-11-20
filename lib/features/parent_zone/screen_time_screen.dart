import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../blocs/user_cubit.dart';

class ScreenTimeScreen extends StatefulWidget {
  const ScreenTimeScreen({super.key});

  @override
  State<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends State<ScreenTimeScreen> {
  late bool _screenTimeEnabled;
  late int _dailyMinutes;
  late bool _breakReminder;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserCubit>().state;
    _screenTimeEnabled = profile.screenTimeLimitEnabled;
    _dailyMinutes = profile.screenTimeLimitMinutes;
    _breakReminder = profile.breakReminderEnabled;
  }

  void _saveChanges() {
    context.read<UserCubit>().updateScreenTime(
      enabled: _screenTimeEnabled,
      minutes: _dailyMinutes,
      breakReminder: _breakReminder,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Screen time preferences saved successfully!'),
        backgroundColor: AppColors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Screen Time', style: AppTextStyles.heading2()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help balance healthy learning habits and playtime.',
                style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
              ),
              const SizedBox(height: 24),

              // 1. Enable Screen Time Limit Switch
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Screen Time Limit',
                            style: AppTextStyles.heading3(),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Set daily maximum usage time',
                            style: AppTextStyles.bodySmall(
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _screenTimeEnabled,
                      activeTrackColor: AppColors.primaryPurple,
                      onChanged: (val) {
                        setState(() {
                          _screenTimeEnabled = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Daily Limit Selector
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Limit', style: AppTextStyles.heading3()),
                        const SizedBox(height: 2),
                        Text(
                          'App locks after reaching limit',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _dailyMinutes,
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.primaryPurple,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 30,
                            child: Text('30 Minutes'),
                          ),
                          DropdownMenuItem(
                            value: 45,
                            child: Text('45 Minutes'),
                          ),
                          DropdownMenuItem(
                            value: 60,
                            child: Text('60 Minutes'),
                          ),
                          DropdownMenuItem(
                            value: 90,
                            child: Text('90 Minutes'),
                          ),
                          DropdownMenuItem(
                            value: 120,
                            child: Text('120 Minutes'),
                          ),
                        ],
                        onChanged: _screenTimeEnabled
                            ? (val) {
                                if (val != null) {
                                  setState(() {
                                    _dailyMinutes = val;
                                  });
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Allowed Hours
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allowed Time Window',
                          style: AppTextStyles.heading3(),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Active between set hours',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '8:00 AM - 8:00 PM',
                        style: AppTextStyles.buttonSmall(
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Break Reminder
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Break Reminder',
                            style: AppTextStyles.heading3(),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Gentle alerts every 20 minutes',
                            style: AppTextStyles.bodySmall(
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _breakReminder,
                      activeTrackColor: AppColors.primaryPurple,
                      onChanged: (val) {
                        setState(() {
                          _breakReminder = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Save Changes Button
              AppButton(
                label: 'Save Changes',
                width: double.infinity,
                onPressed: _saveChanges,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
