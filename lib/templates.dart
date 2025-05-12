import 'dart:ffi';

import 'package:flutter/cupertino.dart';

enum TemplateType { text, image }

abstract class TemplateChild {
  TemplateChild(this.id, this.positionX, this.positionY, this.visible,
      this.rotation, this.type);
  String id;
  double positionX;
  double positionY;
  bool visible;
  int rotation;
  TemplateType type;

  /// element01 position X:0 Y:0
  /// visible: true
  /// rotation: 0
  /// type: Text
  /// text: "Lorem ipsum"
  /// color: 0xfffa12ab
  /// size: 13 dp
  /// fontFamily: RobotoRegular
}

class TemplateChildText implements TemplateChild {
  @override
  // TODO: implement the ID
  String id;

  @override
  // TODO: implement positionX
  double positionX;

  @override
  // TODO: implement positionY
  double positionY;

  @override
  // TODO: implement rotation
  int rotation;

  @override
  // TODO: implement type
  TemplateType type;

  @override
  // TODO: implement visible
  bool visible;
  String text;
  String color;
  double size;
  String fontFamily;

  TemplateChildText(
      this.id,
      this.positionX,
      this.positionY,
      this.rotation,
      this.type,
      this.visible,
      this.text,
      this.color,
      this.size,
      this.fontFamily);
}

class TemplateChildImage implements TemplateChild {
  @override
  // TODO: implement the ID
  String id;

  @override
  // TODO: implement positionX
  double positionX;

  @override
  // TODO: implement positionY
  double positionY;

  @override
  // TODO: implement rotation
  int rotation;

  @override
  // TODO: implement type
  TemplateType type;

  @override
  // TODO: implement visible
  bool visible;
  String uri;
  double width;
  double height;

  TemplateChildImage(this.id, this.positionX, this.positionY, this.rotation,
      this.type, this.visible, this.uri, this.width, this.height);
}

class Template {
  int id;
  String title;
  List<TemplateChild> children;

  Template(this.id, this.title, this.children);
}
