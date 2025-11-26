import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'settings_card.dart';

class SettingsProfileCard extends StatelessWidget {
  final User? user;
  final dynamic themeColors;
  final VoidCallback? onTap;

  const SettingsProfileCard({
    super.key,
    required this.user,
    required this.themeColors,
    this.onTap,
  });

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(user?.name);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWeb ? 32 : 24,
        isWeb ? 32 : 24,
        isWeb ? 32 : 24,
        16,
      ),
      child: SettingsCard(
        themeColors: themeColors,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(isWeb ? 24 : 20),
              child: Row(
                children: [
                  // Avatar with gradient
                  Hero(
                    tag: 'user_avatar',
                    child: Container(
                      width: isWeb ? 72 : 64,
                      height: isWeb ? 72 : 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            themeColors.primary,
                            themeColors.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: themeColors.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWeb ? 26 : 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isWeb ? 20 : 16),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user?.name ?? 'User',
                                style: TextStyle(
                                  fontSize: isWeb ? 22 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    themeColors.primary.withValues(alpha: 0.2),
                                    themeColors.secondary.withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: themeColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: themeColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: TextStyle(
                            fontSize: isWeb ? 15 : 14,
                            color: Colors.grey[400],
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isWeb) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.calendar_today,
                                label: 'Joined Jan 2024',
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                icon: Icons.verified_user,
                                label: 'Verified',
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Chevron
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[600],
                      size: isWeb ? 28 : 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}