import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion_pdf;

class PdfPreviewContent extends StatefulWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const PdfPreviewContent({
    super.key,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  State<PdfPreviewContent> createState() => _PdfPreviewContentState();
}

class _PdfPreviewContentState extends State<PdfPreviewContent> {
  ui.Image? _previewImage;
  bool _isLoading = true;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _generatePreview();
  }

  String _formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<void> _generatePreview() async {
    try {
      final syncfusion_pdf.PdfDocument document = syncfusion_pdf.PdfDocument(
        inputBytes: widget.pdfBytes,
      );

      final int pageCount = document.pages.count;
      document.dispose();

      final raster = await Printing.raster(
        widget.pdfBytes,
        pages: [0],
        dpi: 150,
      ).first;

      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        raster.pixels,
        raster.width,
        raster.height,
        ui.PixelFormat.rgba8888,
        (ui.Image result) {
          completer.complete(result);
        },
      );

      final image = await completer.future;

      if (mounted) {
        setState(() {
          _previewImage = image;
          _pageCount = pageCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao gerar preview ou ler PDF: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sharePdf() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/${widget.fileName}';
      final file = File(tempPath);
      await file.writeAsBytes(widget.pdfBytes);

      final xFile = XFile(tempPath);

      await Share.shareXFiles([xFile], text: 'Segue o relatório de auditoria.');
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          'Erro ao compartilhar PDF: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _savePdf() async {

    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Não foi possível encontrar o diretório para salvar.");
      }

      final filePath = '${directory.path}/${widget.fileName}';
      final file = File(filePath);

      await file.writeAsBytes(widget.pdfBytes);

      await OpenFilex.open(filePath);

    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          'Erro ao salvar PDF: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fileSizeFormatted = _formatBytes(
      widget.pdfBytes.lengthInBytes,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isLoading
              ? const ShimmerPlaceholder(height: 250)
              : _previewImage != null
              ? RawImage(
                  image: _previewImage,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                )
              : const Center(
                  child: Text(
                    'Falha ao carregar preview',
                    style: TextStyle(color: deleteRed),
                  ),
                ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: DetailItemCard(
                label: "Nº DE PÁGINAS",
                value: _pageCount.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(label: "TAMANHO", value: fileSizeFormatted),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Compart.",
                onPressed: _sharePdf,
                secondary: true,
                icon: Icons.share,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: "Download",
                onPressed: _savePdf,
                customIcon: 'assets/icons/download.svg',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
