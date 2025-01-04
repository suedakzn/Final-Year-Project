import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_processing_page.dart';

class ChildDetailPage extends StatelessWidget {
  final int childId;
  final String childName;
  final String childImage;

  const ChildDetailPage({
    super.key,
    required this.childId,
    required this.childName,
    required this.childImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 230, 178, 239), // Canlı arka plan
      appBar: AppBar(
        title: Text(
          '$childName\'s Page',
          style: const TextStyle(
            fontFamily: 'ComicSans',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Çocuk Görseli - Eğlenceli Avatar
              CircleAvatar(
                radius: 90,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/$childImage',
                    fit: BoxFit.cover,
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Butonlar
              _buildCardButton(
                image: 'assets/blue_camera_button.png',
                title: 'Upload Shape Image',
                color: Colors.lightBlue,
                onTap: () async {
                  // Görüntü seçme ve işleme sayfasına geçiş
                  String? imagePath = await _pickImage();
                  if (imagePath != null) {
                    _navigateToImageProcessingPage(context, imagePath);
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildCardButton(
                image: 'assets/white_game_button.png',
                title: 'Play Game',
                color: Colors.lightGreen,
                onTap: () {
                  // Oyun Sayfası
                },
              ),
              const SizedBox(height: 20),
              _buildCardButton(
                image: 'assets/report_button.png',
                title: 'View Weekly Report',
                color: Colors.amber,
                onTap: () {
                  // Haftalık rapor
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Özelleştirilebilir Buton Widget'ı
  Widget _buildCardButton({
    required String image,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              // İkon görseli
              Image.asset(
                image,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 20),
              // Buton başlığı
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ComicSans',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Görüntü seçme fonksiyonu
  Future<String?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return image.path; // Seçilen görüntünün yolu
    } else {
      return null; // Görüntü seçilmedi
    }
  }

  // Görüntü işleme sayfasına geçiş
  void _navigateToImageProcessingPage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageProcessingPage(imagePath: imagePath),
      ),
    );
  }
}
