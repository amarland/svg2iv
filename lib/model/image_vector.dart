import 'package:svg2iv/extensions.dart';
import 'package:svg2iv/model/vector_group.dart';
import 'package:svg2iv/model/vector_node.dart';

class ImageVector {
  ImageVector._init(
    this.group,
    this.viewportWidth,
    this.viewportHeight,
    this.width,
    this.height, [
    String? name,
  ]) : name = name?.toPascalCase();

  final VectorGroup group;
  final String? name;
  final double width, height;
  final double viewportWidth, viewportHeight;

  ImageVector copyWith({
    VectorGroup? group,
    String? name,
    double? width,
    height,
    double? viewportWidth,
    viewportHeight,
  }) {
    return ImageVector._init(
      group ?? this.group,
      viewportWidth ?? this.viewportWidth,
      viewportHeight ?? this.viewportHeight,
      width ?? this.width,
      height ?? this.height,
      name?.toPascalCase() ?? this.name,
    );
  }
}

class ImageVectorBuilder {
  ImageVectorBuilder(
    this._viewportWidth,
    this._viewportHeight,
  );

  final VectorGroupBuilder _rootGroupBuilder = VectorGroupBuilder();

  final double _viewportWidth, _viewportHeight;
  String? _name;
  double? _width, _height;

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

  ImageVectorBuilder addNode(VectorNode node) {
    _rootGroupBuilder.addNode(node);
    return this;
  }

  ImageVector build() {
    return ImageVector._init(
      _rootGroupBuilder.build(),
      _viewportWidth,
      _viewportHeight,
      _width ?? _viewportWidth,
      _height ?? _viewportHeight,
      _name,
    );
  }
}
