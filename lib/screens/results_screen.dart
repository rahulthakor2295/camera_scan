import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../models/scanned_image.dart';

class ResultsScreen extends StatefulWidget {
  final List<String> imagePaths;

  const ResultsScreen({super.key, required this.imagePaths});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? _expandedIndex;
  List<ScannedImage> _scannedImages = [];
  bool _isScanning = true;
  final BarcodeScanner _barcodeScanner = BarcodeScanner(
    formats: [BarcodeFormat.all],
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scanAllImages();
  }

  Future<void> _scanAllImages() async {
    for (int i = 0; i < widget.imagePaths.length; i++) {
      final imagePath = widget.imagePaths[i];

      ScanType scanType = ScanType.none;
      int qrCount = 0;
      int barcodeCount = 0;
      List<String> values = [];

      try {
        final inputImage = InputImage.fromFilePath(imagePath);

        List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

        if (barcodes.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 100));
          barcodes = await _barcodeScanner.processImage(inputImage);
        }

        if (barcodes.isNotEmpty) {
          for (var barcode in barcodes) {
            if (barcode.displayValue != null &&
                barcode.displayValue!.isNotEmpty) {
              values.add(barcode.displayValue!);
            }

            if (barcode.format == BarcodeFormat.qrCode) {
              qrCount++;
            } else {
              barcodeCount++;
            }
          }

          if (qrCount > 0 && barcodeCount > 0) {
            scanType = ScanType.both;
          } else if (qrCount > 0) {
            scanType = ScanType.qrCode;
          } else if (barcodeCount > 0) {
            scanType = ScanType.barcode;
          }
        }
      } catch (e) {}

      final scannedImage = ScannedImage(
        imagePath: imagePath,
        scanType: scanType,
        scanData: null,
        timestamp: DateTime.now(),
        qrCodeCount: qrCount,
        barcodeCount: barcodeCount,
        scannedValues: values,
      );

      setState(() {
        _scannedImages.add(scannedImage);
      });
    }

    setState(() {
      _isScanning = false;
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  Color _getColorForScanType(ScanType type) {
    switch (type) {
      case ScanType.qrCode:
        return Colors.blue;
      case ScanType.barcode:
        return Colors.green;
      case ScanType.both:
        return Colors.purple;
      case ScanType.none:
        return Colors.grey;
    }
  }

  IconData _getIconForScanType(ScanType type) {
    switch (type) {
      case ScanType.qrCode:
        return Icons.qr_code_2;
      case ScanType.barcode:
        return Icons.barcode_reader;
      case ScanType.both:
        return Icons.qr_code_scanner;
      case ScanType.none:
        return Icons.image;
    }
  }

  String _getLabelForScanType(ScanType type, ScannedImage image) {
    switch (type) {
      case ScanType.qrCode:
        return image.qrCodeCount > 1
            ? '${image.qrCodeCount} QR Codes'
            : 'QR Code';
      case ScanType.barcode:
        return image.barcodeCount > 1
            ? '${image.barcodeCount} Barcodes'
            : 'Barcode';
      case ScanType.both:
        return 'QR + Barcode';
      case ScanType.none:
        return 'Image';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.blue.shade900,
              Colors.teal.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Scan Results',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.imagePaths.length} ${widget.imagePaths.length == 1 ? 'Image' : 'Images'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scanning indicator or Statistics
              if (_isScanning)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scanning ${_scannedImages.length}/${widget.imagePaths.length} images...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        'QR Codes',
                        _scannedImages
                            .where((img) => img.scanType == ScanType.qrCode)
                            .length,
                        Icons.qr_code_2,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Barcodes',
                        _scannedImages
                            .where((img) => img.scanType == ScanType.barcode)
                            .length,
                        Icons.barcode_reader,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Plain',
                        _scannedImages
                            .where((img) => img.scanType == ScanType.none)
                            .length,
                        Icons.image,
                        Colors.grey,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Images List
              Expanded(
                child: _isScanning
                    ? const SizedBox()
                    : AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _scannedImages.length,
                            itemBuilder: (context, index) {
                              final image = _scannedImages[index];
                              final isExpanded = _expandedIndex == index;

                              return FadeTransition(
                                opacity:
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      (index / _scannedImages.length) * 0.5,
                                      ((index + 1) / _scannedImages.length) *
                                              0.5 +
                                          0.5,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                ),
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _animationController,
                                      curve: Interval(
                                        (index / _scannedImages.length) * 0.5,
                                        ((index + 1) / _scannedImages.length) *
                                                0.5 +
                                            0.5,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                  ),
                                  child:
                                      _buildImageCard(image, index, isExpanded),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isScanning
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('New Scan'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple.shade900,
            ),
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(ScannedImage image, int index, bool isExpanded) {
    final color = _getColorForScanType(image.scanType);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? null : index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.file(
                    File(image.imagePath),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconForScanType(image.scanType),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getLabelForScanType(image.scanType, image),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(image.timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: color,
                      ),
                    ],
                  ),
                  if (isExpanded && image.scanType != ScanType.none) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: color, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Valid codes detected:',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (image.qrCodeCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: Text(
                                '• ${image.qrCodeCount} QR Code${image.qrCodeCount > 1 ? 's' : ''}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          if (image.barcodeCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: Text(
                                '• ${image.barcodeCount} Barcode${image.barcodeCount > 1 ? 's' : ''}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),

                          // Show decoded values
                          if (image.scannedValues.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.data_object, color: color, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Decoded Values:',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...image.scannedValues.asMap().entries.map((entry) {
                              final index = entry.key;
                              final value = entry.value;
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 26, bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${index + 1}. ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: SelectableText(
                                        value,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade800,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (isExpanded && image.scanType == ScanType.none) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'No QR code or barcode detected',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute:$second';
  }
}
