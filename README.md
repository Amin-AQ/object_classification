# 🖼️ Object Classification with Flutter and TensorFlow Lite

A fascinating Flutter project that brings object classification to your fingertips! 🚀 Utilizing TensorFlow Lite, this app can identify objects in images captured from the camera or selected from the gallery.

## 📱 App Overview

### Features:
- **Capture Image:** 📸 Use the device's camera to capture an image for object classification.
- **From Gallery:** 🖼️ Select an image from the gallery and get real-time object classification results.
- **TensorFlow Lite Model:** 🧠 Efficiently use the TensorFlow Lite model for image classification.
- **Object Labels:** 🏷️ Classify images such as 'leaf_waste', 'metal', 'paper', 'plastic', and 'wood_waste'.
- **User-friendly Interface:** 💻 An intuitive and easy-to-use interface for seamless user interaction.

## 🚀 Getting Started

### Prerequisites:
- Flutter installed on your development environment.

### Installation Steps:
1. Clone the repository.
2. Open the project in your preferred IDE.
3. Ensure you have the necessary dependencies by running `flutter pub get`.
4. Run the app on your emulator or physical device.

## 🎉 Usage

1. **Capture Image:** Click on the "Capture Image" button to use the device's camera and instantly classify objects.
2. **From Gallery:** Choose the "From Gallery" option to pick an image from your device's gallery for object classification.
3. **Result Display:** The app will provide real-time results, displaying the identified object label.

## 🛠️ Technical Details

### Tech Stack:
- Dart
- Flutter
- TensorFlow Lite

### Image Processing:
- Images are preprocessed before classification to ensure optimal results.
- The TensorFlow Lite model is used for efficient and accurate image classification.

## 🤖 Example Code Snippet

```dart
// Code snippet demonstrating the usage of the TensorFlow Lite model
// ...

// Capture Image
void _captureImage() async {
  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
  if (image != null && _modelLoaded) {
    _classifyImage(File(image.path));
  }
}

// From Gallery
void _pickFromGallery() async {
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image != null && _modelLoaded) {
    _classifyImage(File(image.path));
  }
}

// ...
```
