import 'package:autocore_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

enum ACGridType { fixed, responsive, masonry }

class ACGrid extends StatelessWidget {
  final List<Widget> children;
  final ACGridType type;
  final int? columns;
  final int? minColumns;
  final int? maxColumns;
  final double? minItemWidth;
  final double? maxItemWidth;
  final double? aspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool primary;
  final ScrollController? controller;

  const ACGrid({
    super.key,
    required this.children,
    this.type = ACGridType.responsive,
    this.columns,
    this.minColumns = 1,
    this.maxColumns = 6,
    this.minItemWidth = 100,
    this.maxItemWidth = 400,
    this.aspectRatio = 1.0,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.primary = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.acTheme;
    // Especificação A33-PHASE2-IMPORTANT-FIXES: crossAxisSpacing: 16px, mainAxisSpacing: 16px
    final effectiveCrossAxisSpacing = crossAxisSpacing ?? 16.0;
    final effectiveMainAxisSpacing = mainAxisSpacing ?? 16.0;
    final effectivePadding = padding ?? EdgeInsets.all(theme.spacingMd);

    switch (type) {
      case ACGridType.fixed:
        return _buildFixedGrid(
          context,
          effectiveCrossAxisSpacing,
          effectiveMainAxisSpacing,
          effectivePadding,
        );
      case ACGridType.responsive:
        return _buildResponsiveGrid(
          context,
          effectiveCrossAxisSpacing,
          effectiveMainAxisSpacing,
          effectivePadding,
        );
      case ACGridType.masonry:
        return _buildMasonryGrid(
          context,
          effectiveCrossAxisSpacing,
          effectiveMainAxisSpacing,
          effectivePadding,
        );
    }
  }

  Widget _buildFixedGrid(
    BuildContext context,
    double crossAxisSpacing,
    double mainAxisSpacing,
    EdgeInsets padding,
  ) {
    final effectiveColumns = columns ?? _calculateColumns(context);

    return GridView.builder(
      controller: controller,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      primary: primary,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: effectiveColumns,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: aspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    double crossAxisSpacing,
    double mainAxisSpacing,
    EdgeInsets padding,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - padding.horizontal;

        // Calculate optimal number of columns
        int calculatedColumns = 1;
        if (minItemWidth != null) {
          calculatedColumns =
              (availableWidth / (minItemWidth! + crossAxisSpacing)).floor();
        }

        // Apply min/max constraints
        calculatedColumns = calculatedColumns.clamp(
          minColumns ?? 1,
          maxColumns ?? 6,
        );

        // Override with fixed columns if provided
        final effectiveColumns = columns ?? calculatedColumns;

        return GridView.builder(
          controller: controller,
          padding: padding,
          physics: physics,
          shrinkWrap: shrinkWrap,
          primary: primary,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: effectiveColumns,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio:
                aspectRatio ?? _calculateAspectRatio(context, effectiveColumns),
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  Widget _buildMasonryGrid(
    BuildContext context,
    double crossAxisSpacing,
    double mainAxisSpacing,
    EdgeInsets padding,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - padding.horizontal;
        final effectiveColumns = columns ?? _calculateColumns(context);
        final itemWidth =
            (availableWidth - (crossAxisSpacing * (effectiveColumns - 1))) /
            effectiveColumns;

        // Simple masonry layout using columns
        return SingleChildScrollView(
          controller: controller,
          physics: physics,
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                List.generate(effectiveColumns, (columnIndex) {
                      final columnChildren = <Widget>[];

                      for (
                        int i = columnIndex;
                        i < children.length;
                        i += effectiveColumns
                      ) {
                        columnChildren.add(
                          Padding(
                            padding: EdgeInsets.only(bottom: mainAxisSpacing),
                            child: children[i],
                          ),
                        );
                      }

                      return SizedBox(
                        width: itemWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: columnChildren,
                        ),
                      );
                    })
                    .expand(
                      (column) => [column, SizedBox(width: crossAxisSpacing)],
                    )
                    .toList()
                  ..removeLast(),
          ),
        );
      },
    );
  }

  int _calculateColumns(BuildContext context) {
    final width = context.screenWidth;

    // Mobile
    if (context.isMobile) {
      if (width < 360) return 1;
      if (width < 600) return 2;
      return 3;
    }

    // Tablet
    if (context.isTablet) {
      if (width < 800) return 3;
      if (width < 1000) return 4;
      return 5;
    }

    // Desktop
    if (width < 1400) return 5;
    if (width < 1800) return 6;
    return 8;
  }

  double _calculateAspectRatio(BuildContext context, int columns) {
    // Adjust aspect ratio based on device and columns
    if (context.isMobile) {
      if (columns == 1) return 1.5;
      if (columns == 2) return 1.2;
      return 1.0;
    }

    if (context.isTablet) {
      if (columns <= 3) return 1.3;
      return 1.1;
    }

    // Desktop
    return 1.0;
  }

  // Factory constructors for common use cases

  factory ACGrid.products({
    required List<Widget> children,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return ACGrid(
      type: ACGridType.responsive,
      minColumns: 2,
      maxColumns: 6,
      minItemWidth: 150,
      aspectRatio: 0.75, // Taller for product cards
      padding: padding,
      controller: controller,
      children: children,
    );
  }

  factory ACGrid.controls({
    required List<Widget> children,
    EdgeInsets? padding,
  }) {
    return ACGrid(
      type: ACGridType.responsive,
      minColumns: 1,
      maxColumns: 4,
      minItemWidth: 200,
      aspectRatio: 2.0, // Wider for control tiles
      padding: padding,
      shrinkWrap: true,
      children: children,
    );
  }

  factory ACGrid.gallery({
    required List<Widget> children,
    int columns = 3,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    return ACGrid(
      type: ACGridType.fixed,
      columns: columns,
      aspectRatio: 1.0, // Square for gallery items
      padding: padding,
      controller: controller,
      children: children,
    );
  }

  factory ACGrid.dashboard({
    required List<Widget> children,
    EdgeInsets? padding,
  }) {
    return ACGrid(
      type: ACGridType.responsive,
      minColumns: 1,
      maxColumns: 3,
      minItemWidth: 300,
      aspectRatio: 1.2,
      padding: padding,
      shrinkWrap: true,
      children: children,
    );
  }
}
