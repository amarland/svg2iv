import 'package:svg2va/model/vector_group.dart';
import 'package:svg2va/model/vector_node.dart';

class ImageVector {
  const ImageVector._init(
    this.group,
    this.viewportWidth,
    this.viewportHeight,
    this.width,
    this.height, {
    this.name,
  });

  final VectorGroup group;
  final String? name;
  final double width, height;
  final double viewportWidth, viewportHeight;
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
      name: _name,
    );
  }
}
