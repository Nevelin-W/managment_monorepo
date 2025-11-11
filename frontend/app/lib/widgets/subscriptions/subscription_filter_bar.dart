import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../common/app_filter_chip.dart';

class SubscriptionFilterBar extends StatelessWidget {
  final ThemeColors themeColors;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback? onSortPressed;
  final String? sortLabel;

  const SubscriptionFilterBar({
    super.key,
    required this.themeColors,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.onSortPressed,
    this.sortLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: kIsWeb ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  /// Web layout with filter chips
  Widget _buildWebLayout() {
    return Row(
      children: [
        AppFilterChip(
          label: 'All',
          isSelected: selectedFilter == 'All',
          themeColors: themeColors,
          onTap: () => onFilterChanged('All'),
        ),
        const SizedBox(width: 8),
        AppFilterChip(
          label: 'Monthly',
          isSelected: selectedFilter == 'Monthly',
          themeColors: themeColors,
          onTap: () => onFilterChanged('Monthly'),
        ),
        const SizedBox(width: 8),
        AppFilterChip(
          label: 'Yearly',
          isSelected: selectedFilter == 'Yearly',
          themeColors: themeColors,
          onTap: () => onFilterChanged('Yearly'),
        ),
        const SizedBox(width: 8),
        AppFilterChip(
          label: 'Weekly',
          isSelected: selectedFilter == 'Weekly',
          themeColors: themeColors,
          onTap: () => onFilterChanged('Weekly'),
        ),
        const Spacer(),
        _SortButton(
          onPressed: onSortPressed,
          themeColors: themeColors,
          label: sortLabel,
        ),
      ],
    );
  }

  /// Mobile layout with custom dropdown
  Widget _buildMobileLayout() {
    return Row(
      children: [
        Expanded(
          child: _CustomFilterDropdown(
            themeColors: themeColors,
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
        ),
        const SizedBox(width: 12),
        _SortButton(
          onPressed: onSortPressed,
          themeColors: themeColors,
          label: sortLabel,
        ),
      ],
    );
  }
}

class _CustomFilterDropdown extends StatefulWidget {
  final ThemeColors themeColors;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _CustomFilterDropdown({
    required this.themeColors,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  State<_CustomFilterDropdown> createState() => _CustomFilterDropdownState();
}

class _CustomFilterDropdownState extends State<_CustomFilterDropdown> {
  final _filterOptions = ['All', 'Monthly', 'Yearly', 'Weekly'];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 8),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  shadowColor: Colors.black.withOpacity(0.15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.themeColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.themeColors.primary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _filterOptions.map((option) {
                          final isSelected = option == widget.selectedFilter;
                          final isLast = option == _filterOptions.last;
                          
                          return InkWell(
                            onTap: () {
                              widget.onFilterChanged(option);
                              _removeOverlay();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? widget.themeColors.primary.withOpacity(0.08)
                                    : Colors.transparent,
                                border: !isLast
                                    ? Border(
                                        bottom: BorderSide(
                                          color: widget.themeColors.primary.withOpacity(0.06),
                                          width: 1,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? widget.themeColors.primary
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: !isSelected
                                          ? Border.all(
                                              color: widget.themeColors.primary.withOpacity(0.3),
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            size: 14,
                                            color: widget.themeColors.surface,
                                          )
                                        : null,
                                  ),
                                  Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected
                                          ? widget.themeColors.primary
                                          : widget.themeColors.primary.withOpacity(0.7),
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: widget.themeColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isOpen
                  ? widget.themeColors.primary.withOpacity(0.4)
                  : widget.themeColors.primary.withOpacity(0.2),
              width: _isOpen ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: widget.themeColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                widget.selectedFilter,
                style: TextStyle(
                  color: widget.themeColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: widget.themeColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ThemeColors themeColors;
  final String? label;

  const _SortButton({
    required this.onPressed,
    required this.themeColors,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final showLabel = label != null && kIsWeb;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? 16 : 12,
          ),
          constraints: BoxConstraints(
            minWidth: showLabel ? 120 : 48,
          ),
          decoration: BoxDecoration(
            color: themeColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sort,
                size: 22,
                color: themeColors.primary,
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label!,
                    style: TextStyle(
                      color: themeColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}