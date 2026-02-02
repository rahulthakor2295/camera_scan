enum ScanType { qrCode, barcode, both, none }

class ScannedImage {
  final String imagePath;
  final ScanType scanType;
  final String? scanData;
  final DateTime timestamp;
  final int qrCodeCount;
  final int barcodeCount;
  final List<String> scannedValues;

  ScannedImage({
    required this.imagePath,
    required this.scanType,
    this.scanData,
    required this.timestamp,
    this.qrCodeCount = 0,
    this.barcodeCount = 0,
    this.scannedValues = const [],
  });
}
