import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Create image with numChannels: 4 for RGBA
  final image = img.Image(width: 200, height: 200, numChannels: 4);
  
  // Clear to transparent
  
  
  final pixelSize = 5;
  
  void drawPixel(int x, int y, int r, int g, int b, {double opacity = 1.0}) {
    final color = img.ColorRgba8(r, g, b, (opacity * 255).round());
    for (int i = 0; i < pixelSize; i++) {
      for (int j = 0; j < pixelSize; j++) {
        final px = x * pixelSize + i;
        final py = y * pixelSize + j;
        if (px < 200 && py < 200) {
          image.setPixelRgba(px, py, r, g, b, (opacity * 255).round());
        }
      }
    }
  }

  // Ears
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
      drawPixel(8 + i, 9 + j, 31, 41, 55);
      drawPixel(27 + i, 9 + j, 31, 41, 55);
    }
  }
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      drawPixel(9 + i, 10 + j, 55, 65, 81);
      drawPixel(28 + i, 10 + j, 55, 65, 81);
    }
  }
  drawPixel(10, 11, 75, 85, 99);
  drawPixel(29, 11, 75, 85, 99);

  // Head
  for (int i = 0; i < 16; i++) {
    for (int j = 0; j < 14; j++) {
      drawPixel(12 + i, 12 + j, 31, 41, 55);
    }
  }
  for (int i = 0; i < 14; i++) {
    for (int j = 0; j < 12; j++) {
      drawPixel(13 + i, 13 + j, 55, 65, 81);
    }
  }
  for (int i = 0; i < 12; i++) {
    for (int j = 0; j < 10; j++) {
      drawPixel(14 + i, 14 + j, 75, 85, 99);
    }
  }

  // Eyes
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      drawPixel(15 + i, 17 + j, 0, 0, 0);
    }
  }
  drawPixel(15, 17, 16, 185, 129);
  drawPixel(16, 17, 16, 185, 129);
  drawPixel(16, 18, 110, 231, 183);

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      drawPixel(22 + i, 17 + j, 0, 0, 0);
    }
  }
  drawPixel(22, 17, 16, 185, 129);
  drawPixel(23, 17, 16, 185, 129);
  drawPixel(23, 18, 110, 231, 183);

  // Snout
  for (int i = 0; i < 6; i++) {
    for (int j = 0; j < 4; j++) {
      drawPixel(17 + i, 22 + j, 107, 114, 128);
    }
  }
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 2; j++) {
      drawPixel(18 + i, 23 + j, 156, 163, 175);
    }
  }
  drawPixel(19, 23, 31, 41, 55);
  drawPixel(20, 23, 31, 41, 55);
  drawPixel(19, 24, 31, 41, 55);
  drawPixel(20, 24, 31, 41, 55);

  // Fangs
  drawPixel(17, 25, 229, 231, 235);
  drawPixel(22, 25, 229, 231, 235);

  // Body
  for (int i = 0; i < 12; i++) {
    for (int j = 0; j < 8; j++) {
      drawPixel(14 + i, 26 + j, 31, 41, 55);
    }
  }
  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 6; j++) {
      drawPixel(15 + i, 27 + j, 55, 65, 81);
    }
  }
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 4; j++) {
      drawPixel(16 + i, 28 + j, 75, 85, 99);
    }
  }

  // Emerald heart
  drawPixel(19, 29, 16, 185, 129);
  drawPixel(20, 29, 16, 185, 129);
  drawPixel(19, 30, 16, 185, 129);
  drawPixel(20, 30, 16, 185, 129);
  drawPixel(18, 30, 16, 185, 129, opacity: 0.6);
  drawPixel(21, 30, 16, 185, 129, opacity: 0.6);
  drawPixel(19, 31, 5, 150, 105);
  drawPixel(20, 31, 5, 150, 105);

  // Arms
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      drawPixel(10 + i, 28 + j, 31, 41, 55);
    }
  }
  drawPixel(11, 29, 55, 65, 81);
  drawPixel(12, 29, 55, 65, 81);

  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      drawPixel(26 + i, 28 + j, 31, 41, 55);
    }
  }
  drawPixel(27, 29, 55, 65, 81);
  drawPixel(28, 29, 55, 65, 81);

  // Claws
  for (int i = 0; i < 3; i++) {
    drawPixel(9 + i, 32, 209, 213, 219);
    drawPixel(9 + i, 33, 209, 213, 219);
    drawPixel(9 + i, 32, 16, 185, 129, opacity: 0.4);
  }

  for (int i = 0; i < 3; i++) {
    drawPixel(28 + i, 32, 209, 213, 219);
    drawPixel(28 + i, 33, 209, 213, 219);
    drawPixel(28 + i, 32, 16, 185, 129, opacity: 0.4);
  }

  // Legs
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      drawPixel(14 + i, 34 + j, 31, 41, 55);
      drawPixel(23 + i, 34 + j, 31, 41, 55);
    }
  }
  drawPixel(15, 35, 55, 65, 81);
  drawPixel(24, 35, 55, 65, 81);

  // Save with explicit PNG format
  final directory = Directory('assets/images');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  final pngBytes = img.encodePng(image, level: 6);
  File('assets/images/pixel_bear.png').writeAsBytesSync(pngBytes);
  
  print('✓ Bear exported to assets/images/pixel_bear.png with transparency');
}