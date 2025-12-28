import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../notifiers/language_notifier.dart';
import '../../widgets/shared_widgets/snackbar.dart';
import 'services_screen.dart'; // Navigate to Services next

class IdUploadScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const IdUploadScreen({super.key, required this.themeNotifier});

  @override
  State<IdUploadScreen> createState() => _IdUploadScreenState();
}

class _IdUploadScreenState extends State<IdUploadScreen> {
  File? _idImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _idImage = File(image.path);
      });
    }
  }

  void _onNextTap() {
    if (_idImage == null) {
      CustomSnackBar.show(
        context,
        messageKey: 'required',
        dynamicText: ' - Please upload ID',
        backgroundColor: Colors.red,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicesScreen(
          themeNotifier: widget.themeNotifier,
          idCardImage: _idImage,
          isEdit: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageNotifier>(context);
    final isDark = widget.themeNotifier.isDarkMode;
    final primaryColor = const Color(0xFF2f6cfa);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.translate('uploadId'),
        ), // Add 'uploadId' to your translations
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Please upload a clear photo of your ID card for verification.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey : Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                  image: _idImage != null
                      ? DecorationImage(
                          image: FileImage(_idImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _idImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.upload_file,
                            size: 50,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            lang.translate('tapToUpload') ?? "Tap to Upload",
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _onNextTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                lang.translate('next'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
