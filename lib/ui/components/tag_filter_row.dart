import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/category.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../todo_state.dart';
import '../todo_viewmodel.dart';

class TagFilterRow extends ConsumerWidget {
  final List<Category> categories;
  final CategoryFilter activeFilter;

  const TagFilterRow({
    super.key,
    required this.categories,
    required this.activeFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(todoViewmodelProvider.notifier);
    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          spacing: 5,
          children: [
            _TagPill(
              slug: 'all',
              label: 'tất cả',
              isActive: activeFilter is AllCategories,
              canDelete: false,
              onTap: () => vm.filterByCategory(const AllCategories()),
              onDelete: null,
            ),
            ...categories.map((c) => _TagPill(
              key: ValueKey(c.slug),
              slug: c.slug,
              label: c.label,
              isActive: activeFilter is SpecificCategory &&
                  (activeFilter as SpecificCategory).slug == c.slug,
              canDelete: true,
              onTap: () => vm.filterByCategory(SpecificCategory(c.slug)),
              onDelete: () => vm.deleteCategory(c.slug),
            )),
            _AddCategoryButton(onAdd: (label) => vm.addCategory(label)),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatefulWidget {
  final String slug;
  final String label;
  final bool isActive;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _TagPill({
    super.key,
    required this.slug,
    required this.label,
    required this.isActive,
    required this.canDelete,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_TagPill> createState() => _TagPillState();
}

class _TagPillState extends State<_TagPill> {
  bool _deletable = false;

  void _enterDeleteMode() {
    if (!widget.canDelete) return;
    setState(() => _deletable = true);
  }

  void _exitDeleteMode() {
    setState(() => _deletable = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_deletable) {
          widget.onDelete?.call();
          _exitDeleteMode();
        } else {
          widget.onTap();
        }
      },
      onLongPress: _enterDeleteMode,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: widget.isActive ? AppColors.accentGlow : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDim.radiusLg),
              border: Border.all(
                color: widget.isActive ? AppColors.accentDim : AppColors.border,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
            child: Text(
              widget.label,
              style: AppText.tagText.copyWith(
                color: widget.isActive ? AppColors.accent : AppColors.textDim,
              ),
            ),
          ),
          if (widget.canDelete)
            Positioned(
              top: -5,
              right: -5,
              child: IgnorePointer(
                ignoring: !_deletable,
                child: AnimatedOpacity(
                  opacity: _deletable ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: GestureDetector(
                    onTap: () {
                      widget.onDelete?.call();
                      _exitDeleteMode();
                    },
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        PhosphorIconsRegular.x,
                        size: 8,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddCategoryButton extends StatefulWidget {
  final Future<void> Function(String label) onAdd;
  const _AddCategoryButton({required this.onAdd});

  @override
  State<_AddCategoryButton> createState() => _AddCategoryButtonState();
}

class _AddCategoryButtonState extends State<_AddCategoryButton> {
  bool _inputVisible = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _inputVisible) {
        setState(() => _inputVisible = false);
        _controller.clear();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _open() {
    setState(() => _inputVisible = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) await widget.onAdd(text);
    _controller.clear();
    setState(() => _inputVisible = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _inputVisible
              ? SizedBox(
                  width: 88,
                  height: 27,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: AppText.tagText,
                    cursorColor: AppColors.accent,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 4,
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDim.radiusLg),
                        borderSide: const BorderSide(color: AppColors.accentDim),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDim.radiusLg),
                        borderSide: const BorderSide(color: AppColors.accentDim),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDim.radiusLg),
                        borderSide: const BorderSide(color: AppColors.accentDim),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (!_inputVisible)
          GestureDetector(
            onTap: _open,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CustomPaint(
                painter: _DashedCirclePainter(color: AppColors.border),
                child: Center(
                  child: Icon(
                    PhosphorIconsRegular.plus,
                    size: 11,
                    color: AppColors.textDim2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashCount = 12;
    const gapRatio = 0.4; // fraction of arc that's a gap
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 0.5;
    const fullAngle = 2 * pi;
    const dashAngle = (fullAngle / dashCount) * (1 - gapRatio);
    const gapAngle  = (fullAngle / dashCount) * gapRatio;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (dashAngle + gapAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, dashAngle, false, paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
