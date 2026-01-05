import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

import '../fertilizers/fertilizer_model.dart' show RichFertilizerOrder;

Future<void> generateAndSaveInvoice(
    BuildContext context, RichFertilizerOrder order) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: Card(
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 4),
              SizedBox(height: 16),
              Text(
                'Generating Invoice...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  try {
    final pdf = pw.Document();

    // Load your logo
    final logoData = await rootBundle.load("assets/NewLogo.png");
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // Load a Unicode font that supports ₹ (NotoSans works perfectly)
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final boldFontData =
        await rootBundle.load("assets/fonts/NotoSans-Bold.ttf");
    final unicodeFont = pw.Font.ttf(fontData);
    final boldUnicodeFont = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('INVOICE',
                          style: pw.TextStyle(
                            font: unicodeFont,
                            fontSize: 36,
                            fontWeight: pw.FontWeight.bold,
                          )),
                      pw.SizedBox(height: 10),
                      pw.Text('Order ID: ${order.orderId}',
                          style: pw.TextStyle(font: boldUnicodeFont)),
                      pw.Text('Date: ${order.formatDate()}',
                          style: pw.TextStyle(font: boldUnicodeFont)),
                      // pw.Text('Status: ${order.status}',
                      //     style: pw.TextStyle(
                      //       font: boldUnicodeFont,
                      //       fontSize: 14,
                      //     )),
                    ],
                  ),
                  pw.SizedBox(
                    width: 120,
                    height: 120,
                    child: pw.Image(logoImage),
                  ),
                ],
              ),

              pw.SizedBox(height: 5),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 5),

              // Company Info
              pw.Text('Sold by:', style: pw.TextStyle(font: boldUnicodeFont)),
              pw.Text('KisanDesk', style: pw.TextStyle(font: unicodeFont)),
              pw.Text('18-60, KisanDesk, Near to Bhangyavanti temple Nimbarga',
                  style: pw.TextStyle(font: unicodeFont)),
              pw.Text('Phone: +91 080-200143',
                  style: pw.TextStyle(font: unicodeFont)),
              pw.Text('Email: info@yourcompany.com',
                  style: pw.TextStyle(font: unicodeFont)),
              pw.SizedBox(height: 10),

              // Bill To (with new delivery address!)
              pw.Text('Bill to:', style: pw.TextStyle(font: boldUnicodeFont)),
              pw.Text(order.farmerName, style: pw.TextStyle(font: unicodeFont)),
              pw.Text(order.farmerPhone,
                  style: pw.TextStyle(font: unicodeFont)),
              pw.Text(order.farmerVillage,
                  style: pw.TextStyle(font: unicodeFont)),
              pw.SizedBox(height: 5),
              pw.Text('Delivery Address:',
                  style: pw.TextStyle(font: boldUnicodeFont, fontSize: 12)),
              pw.Text(order.deliveryAddress,
                  style: pw.TextStyle(font: unicodeFont, fontSize: 11)),
              pw.SizedBox(height: 30),

              // Products Table (UPDATED for new nested structure!)
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1), // S.No
                  1: const pw.FlexColumnWidth(4), // Product
                  2: const pw.FlexColumnWidth(1.2), // Qty x Unit
                  3: const pw.FlexColumnWidth(1.5), // Price
                  4: const pw.FlexColumnWidth(1.5), // Total
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _tableCell('S.No', bold: true, font: boldUnicodeFont),
                      _tableCell('Product', bold: true, font: boldUnicodeFont),
                      _tableCell('Qty x Unit',
                          bold: true, font: boldUnicodeFont),
                      _tableCell('Price', bold: true, font: boldUnicodeFont),
                      _tableCell('Total', bold: true, font: boldUnicodeFont),
                    ],
                  ),

                  // Items (NEW: Using order.products nested structure)
                  ...order.products.asMap().entries.map((entry) {
                    final i = entry.key;
                    final orderItem = entry.value;
                    final product = orderItem.product;
                    final qty = int.tryParse(orderItem.quantity) ?? 1;
                    final price = double.tryParse(product.sellPrice) ?? 0.0;
                    final total = qty * price;

                    return pw.TableRow(
                      children: [
                        _tableCell('${i + 1}', font: unicodeFont),
                        _tableCell(
                          '${product.productName}\n(${product.productCategory})',
                          font: unicodeFont,
                          size: 10,
                        ),
                        _tableCell('$qty × ${product.unit}', font: unicodeFont),
                        _tableCell('₹${price.toStringAsFixed(0)}',
                            font: unicodeFont),
                        _tableCell('₹${total.toStringAsFixed(0)}',
                            font: unicodeFont),
                      ],
                    );
                  }),

                  // Total Row
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      _tableCell('TOTAL', bold: true, font: boldUnicodeFont),
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
                      _tableCell('₹${order.amount}',
                          bold: true, font: boldUnicodeFont, size: 14),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 50),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(font: unicodeFont, fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Save file
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Invoice_${order.orderId}.pdf');
    await file.writeAsBytes(await pdf.save());

    // Close loading & open PDF automatically
    if (context.mounted) Navigator.pop(context); // close dialog
    await OpenFile.open(file.path);
  } catch (e) {
    if (context.mounted) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to generate invoice: $e')),
    );
  }
}

// Helper for clean table cells
pw.Widget _tableCell(String text,
    {bool bold = false,
    required pw.Font font,
    double size = 12,
    pw.TextAlign? align = pw.TextAlign.center}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        font: font,
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}
