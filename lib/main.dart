
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _result = '';
  final labels=['leaf_waste', 'metal', 'paper', 'plastic', 'wood_waste'];
  var progress=0.0;
  Interpreter? _interpreter;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("assets/new_model.tflite");

      setState(() {
        _modelLoaded = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Set loading state to true
        _result = 'Error loading Model: $e'; // Clear previous result
      });
    }
  }

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    // Process the captured image (e.g., perform image classification)
    if (image != null && _modelLoaded) {
      _classifyImage(File(image.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // Process the selected image (e.g., perform image classification)
    if (image != null && _modelLoaded) {
      _classifyImage(File(image.path));
    }
  }

  Future<void> _classifyImage(File image) async {
    setState(() {
      _isLoading = true; // Set loading state to true
      _result = ''; // Clear previous result
    });

    if (image.existsSync()) {
      try {
        // Preprocess the image
        var inputImage = await preprocessImage(image);

        // Run inference
        var outputs = List.filled(1*5,0).reshape([1,5]);
        _interpreter!.run(inputImage, outputs);
        List<num> results=outputs[0].cast<num>();
        int maxIndex=0;
        for (int i=1; i<5; i++) {
          if (results[i]>results[maxIndex]) {
            maxIndex=i;
          }
        }
        String predictedClassLabel = labels[maxIndex];
        setState(() {
          _result = predictedClassLabel;
          _isLoading = false; // Set loading state to false after processing
        });

      } catch (e) {
        setState(() {
          _result = 'Error, please try again.\n$e';
          _isLoading = false; // Set loading state to false after processing
        });
      }
    }
  }

  Future<List<List<List<Float32List>>>> preprocessImage(File imageFile) async {
    try {
      // Read image bytes from file
      final imageData = await imageFile.readAsBytes();

      // Decode image using package:image/image.dart
      var image = img.decodeImage(imageData);

      // Resize the image to the desired dimensions (256x256 in this case)
      var resizedImage = img.copyResize(image!, width: 224, height: 224);

      // Normalize the pixel values to [0, 1] and store in a 4D array
      final buffer = List.generate(1, (_) =>
                    List.generate(224, (_)=>
                     List.generate(224, (_)=> Float32List(3))));
      for (var i = 0; i < 224; i++) {
        for (var j = 0; j < 224; j++) {
          var pixel = resizedImage.getPixel(i, j);
          buffer[0][i][j][0] = pixel.r / 255.0;
          buffer[0][i][j][1] = pixel.g / 255.0;
          buffer[0][i][j][2] = pixel.b / 255.0;
        }
      }

      return buffer;
    } catch (e) {
      setState(() {
        _result = 'Error, please try again.\n$e';
        _isLoading = false; // Set loading state to false after processing
      });
      return [[[]],[[]]];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              color: Colors.white, // Set the background color to white
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text(
                  "Processing . . .",
                  style: TextStyle(
                    color: Colors.blue, // Set the text color to blue
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Classification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('From Gallery'),
            ),
            const SizedBox(height: 16),
            Text(
              'Result: $_result',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_interpreter != null) _interpreter!.close();
    super.dispose();
  }
}
