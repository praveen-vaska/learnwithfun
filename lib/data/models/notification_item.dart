import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class NotificationItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isRead = false,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timeAgo,
    bool? isRead,
    IconData? icon,
    Color? iconColor,
    Color? iconBg,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeAgo: timeAgo ?? this.timeAgo,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBg: iconBg ?? this.iconBg,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    timeAgo,
    isRead,
    icon,
    iconColor,
    iconBg,
  ];
}
