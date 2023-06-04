import 'package:collection/collection.dart';
import 'package:svg2iv_common/models.dart';

import '../extensions.dart';

class ImageVector {
  static const defaultTintBlendMode = BlendMode.srcIn;

  ImageVector._(
    this.nodes,
    this.viewportWidth,
    this.viewportHeight,
    this.width,
    this.height, [
    String? name,
    this.tintColor,
    this.tintBlendMode,
  ]) : name = name?.toPascalCase();

  final List<VectorNode> nodes;
  final String? name;
  final double width, height;
  final double viewportWidth, viewportHeight;
  final int? tintColor;
  final BlendMode? tintBlendMode;

  ImageVector copyWith({
    List<VectorNode>? nodes,
    String? name,
    double? width,
    double? height,
    double? viewportWidth,
    double? viewportHeight,
    int? tintColor,
    BlendMode? tintBlendMode,
  }) {
    return ImageVector._(
      nodes ?? this.nodes,
      viewportWidth ?? this.viewportWidth,
      viewportHeight ?? this.viewportHeight,
      width ?? this.width,
      height ?? this.height,
      name?.toPascalCase() ?? this.name,
      tintColor ?? this.tintColor,
      tintBlendMode ?? this.tintBlendMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageVector &&
          runtimeType == other.runtimeType &&
          const ListEquality<VectorNode>().equals(nodes, other.nodes) &&
          name == other.name &&
          width == other.width &&
          height == other.height &&
          viewportWidth == other.viewportWidth &&
          viewportHeight == other.viewportHeight &&
          tintColor == other.tintColor &&
          tintBlendMode == other.tintBlendMode;

  @override
  int get hashCode =>
      const ListEquality<VectorNode>().hash(nodes) ^
      name.hashCode ^
      width.hashCode ^
      height.hashCode ^
      viewportWidth.hashCode ^
      viewportHeight.hashCode ^
      tintColor.hashCode ^
      tintBlendMode.hashCode;
}

class ImageVectorBuilder {
  ImageVectorBuilder(
    this._viewportWidth,
    this._viewportHeight,
  );

  final _nodes = <VectorNode>[];

  final double _viewportWidth, _viewportHeight;
  String? _name;
  double? _width, _height;
  int? _tintColor;
  BlendMode? _tintBlendMode;

  ImageVectorBuilder name(String name) {
    _name = name;
    return this;
  }

  ImageVectorBuilder width(double width) {
    _width = width;
    return this;
  }

  ImageVectorBuilder height(double height) {
    _height = height;
    return this;
  }

  ImageVectorBuilder tintColor(int tintColor) {
    _tintColor = tintColor;
    return this;
  }

  ImageVectorBuilder tintBlendMode(BlendMode tintBlendMode) {
    _tintBlendMode = tintBlendMode;
    return this;
  }

  ImageVectorBuilder addNode(VectorNode node) {
    if (node is VectorGroup && !node.definesTransformations) {
      _nodes.addAll(node.nodes);
    } else {
      _nodes.add(node);
    }
    return this;
  }

  ImageVector build() {
    return ImageVector._(
      _nodes,
      _viewportWidth,
      _viewportHeight,
      _width ?? _viewportWidth,
      _height ?? _viewportHeight,
      _name,
      _tintColor,
      _tintBlendMode,
    );
  }
}

enum BlendMode {
  srcOver,
  srcIn,
  srcAtop,
  modulate,
  screen,
  plus,
}
