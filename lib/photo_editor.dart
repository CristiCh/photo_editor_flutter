import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_editor/templates.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// https://pub.dev/packages/flutter_image_filters
// https://img.ly/blog/how-to-add-stickers-and-overlays-to-a-video-in-flutter-test/
// https://github.com/nataliakzm/Applying_Filters_and_Effects_to_Images_Flutter/tree/main

enum CornerEdge { topLeft, topRight, bottomLeft, bottomRight }

class PhotoEditorPage extends StatefulWidget {
  const PhotoEditorPage({super.key});

  @override
  State<PhotoEditorPage> createState() => _PhotoEditorPageState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  double selectedElementX = 0;
  double selectedElementY = 0;
  double initialPositionX = 0;
  double initialPositionY = 0;
  double selectedElementWidth = 0;
  double selectedElementHeight = 0;
  double initialPositionWidth = 0;
  double initialPositionHeight = 0;
  final Color pickerColor = Colors.black;
  int _counter = 0;
  bool _hideWidget = false;
  TemplateChild? _selectedItem = null;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController textFieldController = TextEditingController();
  final textController = TextEditingController(text: '#2F19DB');
  ScreenshotController screenshotController = ScreenshotController();
  Template template = Template(1, "Title", []);
  final picker = ImagePicker();

  void _updatePosition(TemplateChild child, Offset localPosition) {
    double elementX = initialPositionX + (localPosition.dx - selectedElementX);
    double elementY = initialPositionY + (localPosition.dy - selectedElementY);
    // print(localPosition.dx.toString() + " " + localPosition.dy.toString());
    _changeElementPosition(child.id, elementX, elementY);
  }

  void _setInitialPosition(TemplateChild child, Offset localPosition) {
    initialPositionX = child.positionX;
    initialPositionY = child.positionY;
    selectedElementX = localPosition.dx;
    selectedElementY = localPosition.dy;
    // print(localPosition.dx.toString() + " " + localPosition.dy.toString());
  }

  void _changeElementPosition(
      String elementId, double positionX, double positionY) {
    setState(() {
      template.children
          .firstWhere((element) => element.id == elementId)
          .positionX = positionX;
      template.children
          .firstWhere((element) => element.id == elementId)
          .positionY = positionY;
    });
  }

  void _updateSize(
      TemplateChildImage child, Offset localPosition, CornerEdge cornerEdge) {
    switch (cornerEdge) {
      case CornerEdge.topLeft:
        double width =
            initialPositionWidth + (-localPosition.dx + selectedElementWidth);
        double height =
            initialPositionHeight + (-localPosition.dy + selectedElementHeight);
        // print(localPosition.dx.toString() + " " + localPosition.dy.toString());
        _changeElementSize(child.id, width, height);
      case CornerEdge.topRight:
        double width =
            initialPositionWidth + (localPosition.dx - selectedElementWidth);
        double height =
            initialPositionHeight + (-localPosition.dy + selectedElementHeight);
        // print(localPosition.dx.toString() + " " + localPosition.dy.toString());
        _changeElementSize(child.id, width, height);
      case CornerEdge.bottomLeft:
        double width =
            initialPositionWidth + (-localPosition.dx + selectedElementWidth);

        double height =
            initialPositionHeight + (localPosition.dy - selectedElementHeight);
        // print(localPosition.dx.toString() + " " + localPosition.dy.toString());
        _changeElementSize(child.id, width, height);
      case CornerEdge.bottomRight:
        double width =
            initialPositionWidth + (localPosition.dx - selectedElementWidth);
        double height =
            initialPositionHeight + (localPosition.dy - selectedElementHeight);
        // print(localPosition.dx.toString() + " " + localPosition.dy.toString());
        _changeElementSize(child.id, width, height);
    }
  }

  void _setInitialSize(TemplateChildImage child, Offset localPosition) {
    initialPositionWidth = child.width;
    initialPositionHeight = child.height;
    selectedElementWidth = localPosition.dx;
    selectedElementHeight = localPosition.dy;
    // print(localPosition.dx.toString() + " " + localPosition.dy.toString());
  }

  void _changeElementSize(String elementId, double width, double height) {
    if (width > 0 && height > 0) {
      setState(() {
        // TemplateChildImage element =
        //     template.children.firstWhere((element) => element.id == elementId)
        //         as TemplateChildImage;
        // element.height = height;
        // element.width = width;
        template.children
            .whereType<TemplateChildImage>()
            // .map((e) => e as TemplateChildImage)
            .firstWhere((element) => element.id == elementId)
            .width = width;
        template.children
            .whereType<TemplateChildImage>()
            // .map((e) => e as TemplateChildImage)
            .firstWhere((element) => element.id == elementId)
            .height = height;
        // .firstWhere((element) => element.id == elementId)
        // .height = height;
      });
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _savePhoto() async {
    print("_savePhoto called");

    setState(() {
      _hideWidget = !_hideWidget;
    });
    await Future.delayed(const Duration(seconds: 1));

    screenshotController
        .capture(delay: Duration(milliseconds: 10))
        .then((capturedImage) async {
      ShowCapturedWidget(context, capturedImage!);
      setState(() {
        _hideWidget = !_hideWidget;
      });
    }).catchError((onError) {
      setState(() {
        _hideWidget = !_hideWidget;
      });
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {
              _savePhoto();
            },
          ),
        ],
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Photo Editor"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            // Center(
            //   child: _image == null
            //       ? Text('No Image selected')
            //       : Image.file(_image!),
            // ),
            Screenshot(
              controller: screenshotController,
              child: SizedBox(
                width: 400.0,
                height: 400.0,
                child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.red),
                    child: Stack(
                      children: template.children
                          .map((child) => convertToWidget(child))
                          .toList(),
                    )),
              ),
            ),
            Row(
              children: [
                TextButton(onPressed: onAddImage, child: Text("Add Image")),
                TextButton(onPressed: onAddText, child: Text("Add Text"))
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  onAddText() {
    setState(() {
      template.children.add(TemplateChildText(Uuid().v6(), 150, 150, 0,
          TemplateType.text, true, "Added text", "#123fff", 13, "Arial"));
    });
  }

  onAddImage() {
    setState(() {
      template.children.add(TemplateChildImage(
          Uuid().v6(), 120, 150, 0, TemplateType.image, true, null, 60, 40));
    });
  }

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(child: Image.memory(capturedImage as Uint8List)),
      ),
    );
  }

  Widget convertToWidget(TemplateChild child) {
    return Positioned(
        top: child.positionY,
        left: child.positionX,
        child: GestureDetector(
          onPanStart: (details) {
            _setInitialPosition(child, details.localPosition);
          },
          onPanUpdate: (details) {
            _updatePosition(child, details.localPosition);
          },
          child: addElement(child),
        ));
  }

  // Image(
  // image: NetworkImage(child.uri),
  // width: child.width,
  // height: child.height),

  Widget addElement(TemplateChild child) {
    if (child is TemplateChildImage) {
      return GestureDetector(
        onDoubleTap: () {
          setState(() {
            _selectedItem = child;
          });
          openBottomSheetImage();
        },
        child: SizedBox(
          width: child.width,
          height: child.height,
          child: Stack(children: [
            FittedBox(
              fit: BoxFit.fill,
              child: Container(
                width: child.width,
                height: child.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: child.uri != null
                        ? Image.file(File(child!.uri!)).image
                        : Image(image: AssetImage('assets/placeholder.png'))
                            .image,
                    fit: BoxFit.cover, // Change this to fit the container
                  ),
                ),
              ),
            ),
            resizer(0, 0, child, CornerEdge.topLeft),
            resizer(child.height - 10, child.width - 10, child,
                CornerEdge.bottomRight),
            resizer(0, child.width - 10, child, CornerEdge.topRight),
            resizer(child.height - 10, 0, child, CornerEdge.bottomLeft),
          ]),
        ),
      );
    } else if (child is TemplateChildText) {
      return GestureDetector(
        onDoubleTap: () {
          print(child);
          setState(() {
            _selectedItem = child;
          });
          openBottomSheetText();
        },
        onLongPress: () {
          print(child);
          setState(() {
            _selectedItem = child;
          });
          openBottomSheetText();
        },
        child:

            ///Set a property for the selected item, check if the selectedItem != nil & selectedItem.id == child.id show the textField
            ///on lost focus copy the changes of selectedItem on this child
            Text(
          child.text,
          style: TextStyle(
              color: child.color.convertToColor(),
              fontFamily: child.fontFamily,
              fontSize: child.size),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  openBottomSheetText() {
    const List<String> list = <String>[
      "10",
      "11",
      "12",
      "13",
      "14",
      "15",
      "16",
      "17",
      "18",
      "19",
      "20"
    ];
    textFieldController.text = (_selectedItem as TemplateChildText).text;
    final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
      list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
    );
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        const kCreateStoryTextFieldStyle = TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: Colors.white,
          fontFamily: 'Bekind',
        );
        return Container(
          height: 200,
          color: Colors.amber,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  children: [
                    Row(
                      children: [
                        DropdownMenu<String>(
                          initialSelection: (_selectedItem as TemplateChildText)
                              .size
                              .toInt()
                              .toString(), //list.first.toString(),
                          onSelected: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              // dropdownValue = value!;
                              template.children
                                  .whereType<TemplateChildText>()
                                  // .map((e) => e as TemplateChildImage)
                                  .firstWhere((element) =>
                                      element.id == _selectedItem?.id)
                                  .size = double.parse(value!);
                            });
                          },
                          dropdownMenuEntries: menuEntries,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    titlePadding: const EdgeInsets.all(0),
                                    contentPadding: const EdgeInsets.all(25),
                                    content: Column(
                                      children: [
                                        ColorPicker(
                                          pickerColor: pickerColor,
                                          onColorChanged: changeColor,
                                          colorPickerWidth: 300,
                                          pickerAreaHeightPercent: 0.7,
                                          enableAlpha: true,
                                          displayThumbColor: true,
                                          paletteType: PaletteType.hsvWithHue,
                                          labelTypes: const [],
                                          pickerAreaBorderRadius:
                                              const BorderRadius.only(
                                            topLeft: Radius.circular(2),
                                            topRight: Radius.circular(2),
                                          ),
                                          hexInputController: textController,
                                          portraitOnly: true,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 0, 16, 16),
                                          child: CupertinoTextField(
                                            controller: textController,
                                            prefix: const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8),
                                                child: Icon(Icons.tag)),
                                            autofocus: true,
                                            maxLength: 9,
                                            inputFormatters: [
                                              UpperCaseTextFormatter(),
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(kValidHexPattern)),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          child: const Text("Apply"),
                                          onPressed: () => copyToClipboard(
                                              textController.text),
                                        )
                                      ],
                                    ));
                              },
                            );
                          },
                          child: Icon(Icons.code,
                              color: useWhiteForeground(pickerColor)
                                  ? Colors.white
                                  : Colors.black),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pickerColor,
                            shadowColor: pickerColor.withOpacity(1),
                            elevation: 10,
                          ),
                        )
                      ],
                    ),
                    TextField(
                      onChanged: (newValue) {
                        setState(() {
                          template.children
                              .whereType<TemplateChildText>()
                              // .map((e) => e as TemplateChildImage)
                              .firstWhere(
                                  (element) => element.id == _selectedItem?.id)
                              .text = newValue;
                        });
                      },
                      onTapOutside: (event) {
                        _focusNode.unfocus();
                      },
                      style: kCreateStoryTextFieldStyle,
                      focusNode: _focusNode,
                      onSubmitted: (value) {
                        setState(() {
                          _focusNode.unfocus();
                        });
                      },
                      controller: textFieldController,
                      decoration: InputDecoration(
                          labelStyle: kCreateStoryTextFieldStyle,
                          // Label color
                          hintStyle: kCreateStoryTextFieldStyle,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.white, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          labelText: 'Update your text'),
                    ),
                    TextButton(
                      onPressed: removeItem,
                      child: const Text("Remove"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    ).whenComplete(onBottomSheetClosed);
  }

  openBottomSheetImage() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        const kCreateStoryTextFieldStyle = TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: Colors.white,
          fontFamily: 'Bekind',
        );
        return Container(
          height: 200,
          color: Colors.amber,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: showOptions,
                          child: const Text("Select Image"),
                        ),
                        TextButton(
                          onPressed: removeItem,
                          child: const Text("Remove"),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    ).whenComplete(onBottomSheetClosed);
  }

  void copyToClipboard(String input) {
    String textToCopy = input.replaceFirst('#', '').toUpperCase();
    if (textToCopy.startsWith('FF') && textToCopy.length == 8) {
      textToCopy = textToCopy.replaceFirst('FF', '');
    }

    setState(() {
      template.children
          .whereType<TemplateChildText>()
          .firstWhere((element) => element.id == _selectedItem?.id)
          .color = "#" + textToCopy;
    });
    Navigator.pop(context);
  }

  onBottomSheetClosed() {
    setState(() {
      _selectedItem = null;
    });
  }

  void changeColor(Color color) => setState(() => ());

  Widget resizer(double top, double left, TemplateChildImage child,
      CornerEdge cornerEdge) {
    if (!_hideWidget) {
      return Positioned(
        top: top,
        left: left,
        child: GestureDetector(
          onPanStart: (details) {
            _setInitialSize(child, details.localPosition);
            // print(details.localPosition);
          },
          onPanUpdate: (details) {
            _updateSize(child, details.localPosition, cornerEdge);
            // print(details.localPosition);
          },
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              // alternatively, do this:
              // borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
    } else {
      return const SizedBox(width: 0.0, height: 0.0);
    }
  }

  Future getImageFromSource(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(source: imageSource);

    setState(() {
      if (pickedFile != null) {
        template.children
            .whereType<TemplateChildImage>()
            .firstWhere((element) => element.id == _selectedItem?.id)
            .uri = pickedFile.path;
      }
    });
  }

  Future removeItem() async {
    setState(() {
      template.children
          .removeWhere((element) => element.id == _selectedItem?.id);
      _selectedItem = null;
    });
    Navigator.of(context).pop();
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromSource(ImageSource.gallery);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromSource(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }
}

extension ColorExtension on String {
  convertToColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}
