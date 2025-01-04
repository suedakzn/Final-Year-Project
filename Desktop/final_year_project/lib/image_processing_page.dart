import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart'
    as img; // Image işleme için ek bir kütüphane kullanabilirsiniz

class ImageProcessingPage extends StatefulWidget {
  final String imagePath;

  const ImageProcessingPage({super.key, required this.imagePath});

  @override
  State<ImageProcessingPage> createState() => _ImageProcessingPageState();
}

class _ImageProcessingPageState extends State<ImageProcessingPage> {
  String imageInfo = "Görüntü bilgisi yükleniyor...";

  @override
  void initState() {
    super.initState();
    _loadImageInfo();
  }

  // Görüntü bilgilerini yükleme fonksiyonu
  Future<void> _loadImageInfo() async {
    final file = File(widget.imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image != null) {
      setState(() {
        imageInfo = "Görüntü boyutları: ${image.width}x${image.height}";
      });
    } else {
      setState(() {
        imageInfo = "Görüntü okunamadı!";
      });
    }
  }

  // Görüntü işleme simülasyonu
  void _processImage() {
    setState(() {
      imageInfo = "Görüntü işleniyor...";
    });

    // Görüntü işleme kodu burada çalıştırılabilir
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        imageInfo = "Görüntü başarıyla işlendi!";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Image'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(File(widget.imagePath)), // Seçilen görüntüyü göster
            const SizedBox(height: 20),
            Text(
              imageInfo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _processImage,
              child: const Text('Analyze'),
            ),
          ],
        ),
      ),
    );
  }
}
