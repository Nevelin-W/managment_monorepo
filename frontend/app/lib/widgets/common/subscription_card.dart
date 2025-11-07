import 'package:flutter/material.dart';
import '../../models/subscription_model.dart';
import '../../config/theme.dart';

/// Reusable subscription card widget
/// Used in both home and subscriptions screens
class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final ThemeColors themeColors;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isCompact;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.themeColors,
    required this.onEdit,
    required this.onDelete,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return isCompact ? _buildCompactCard() : _buildFullCard();
  }

  Widget _buildCompactCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _buildCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatNextBillingDate(),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${subscription.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeColors.primary,
              ),
            ),
            _buildMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _buildCardDecoration(withShadow: true),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subscription.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          _buildStatusBadge(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatNextBillingDate(),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildMenu(),
              ],
            ),
            const SizedBox(height: 16),
            _buildDivider(),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildBillingCycleBadge(),
                const Spacer(),
                Text(
                  '\$${subscription.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration({bool withShadow = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          themeColors.surface.withValues(alpha: isCompact ? 0.5 : 0.6),
          themeColors.surface.withValues(alpha: 0.3),
        ],
      ),
      borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    );
  }

  Widget _buildIcon({double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColors.primary.withValues(alpha: 0.3),
            themeColors.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(
          color: themeColors.primary.withValues(alpha: 0.3),
          width: isCompact ? 1 : 1.5,
        ),
      ),
      child: Icon(
        Icons.subscriptions_outlined,
        color: themeColors.primary,
        size: size / 2,
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: subscription.isActive
            ? themeColors.primary.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: subscription.isActive
              ? themeColors.primary.withValues(alpha: 0.4)
              : Colors.red.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        subscription.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: subscription.isActive ? themeColors.primary : Colors.red,
        ),
      ),
    );
  }

  Widget _buildBillingCycleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColors.primary.withValues(alpha: 0.2),
            themeColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: themeColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        subscription.billingCycle.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          color: themeColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey[400],
        size: isCompact ? 20 : 22,
      ),
      color: themeColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined,
                  size: 20, color: themeColors.primary),
              const SizedBox(width: 12),
              const Text('Edit', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
    );
  }

  String _formatNextBillingDate() {
    final date = subscription.nextBillingDate;
    return 'Next: ${date.day}/${date.month}/${date.year}';
  }
}