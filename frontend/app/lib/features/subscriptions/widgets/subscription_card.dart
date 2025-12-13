import 'package:flutter/material.dart';
import '../../../features/subscriptions/models/subscription_model.dart';
import '../../../core/config/theme.dart';
import 'package:flutter/foundation.dart';

/// Reusable subscription card widget
/// Used in both home and subscriptions screens
class SubscriptionCard extends StatefulWidget {
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
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  bool _isHovered = false;
  bool get _showMenuButton {
  final isTouch = !kIsWeb || MediaQuery.of(context).size.width < 600;
  return isTouch ? true : _isHovered;
}

  @override
  Widget build(BuildContext context) {
    return widget.isCompact ? _buildCompactCard() : _buildFullCard();
  }

  Widget _buildCompactCard() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
                      widget.subscription.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${widget.subscription.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.themeColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getBillingCycleShort(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              _buildHoverMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullCard() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
                                widget.subscription.name,
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
                  _buildHoverMenu(),
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
                    '\$${widget.subscription.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.themeColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration({bool withShadow = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isHovered
            ? [
                widget.themeColors.surface.withValues(alpha: 0.7),
                widget.themeColors.surface.withValues(alpha: 0.5),
              ]
            : [
                widget.themeColors.surface
                    .withValues(alpha: widget.isCompact ? 0.4 : 0.5),
                widget.themeColors.surface.withValues(alpha: 0.2),
              ],
      ),
      borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 20),
      border: Border.all(
        color: _isHovered
            ? widget.themeColors.primary.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.1),
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
            widget.themeColors.primary.withValues(alpha: 0.3),
            widget.themeColors.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(
          color: widget.themeColors.primary.withValues(alpha: 0.3),
          width: widget.isCompact ? 1 : 1.5,
        ),
      ),
      child: Icon(
        Icons.subscriptions_outlined,
        color: widget.themeColors.primary,
        size: size / 2,
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: widget.subscription.isActive
            ? widget.themeColors.primary.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.subscription.isActive
              ? widget.themeColors.primary.withValues(alpha: 0.4)
              : Colors.red.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        widget.subscription.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color:
              widget.subscription.isActive ? widget.themeColors.primary : Colors.red,
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
            widget.themeColors.primary.withValues(alpha: 0.2),
            widget.themeColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.themeColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.subscription.billingCycle.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          color: widget.themeColors.primary,
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

  Widget _buildHoverMenu() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
    opacity: _showMenuButton ? 1.0 : 0.0,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _showMenuButton ? 36 : 0,
      child: PopupMenuButton<String>(
        tooltip: '', // disable "Show Menu"
        icon: Icon(
          Icons.more_vert,
          color: widget.themeColors.primary,
          size: widget.isCompact ? 20 : 22,
        ),
          color: widget.themeColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined,
                      size: 20, color: widget.themeColors.primary),
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
              widget.onEdit();
            } else if (value == 'delete') {
              widget.onDelete();
            }
          },
        ),
      ),
    );
  }

  String _formatNextBillingDate() {
    final date = widget.subscription.nextBillingDate;
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return 'In $difference days';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getBillingCycleShort() {
    switch (widget.subscription.billingCycle.toString().split('.').last) {
      case 'monthly':
        return 'month';
      case 'yearly':
        return 'year';
      case 'weekly':
        return 'week';
      default:
        return '';
    }
  }
}