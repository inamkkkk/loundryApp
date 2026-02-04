import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:loundryapp/features/orders/domain/models/order_model.dart';
import 'package:loundryapp/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PdfService {
  Future<void> generateAndPrintInvoice(Order order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Thermal printer friendly width
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "LaundryFlow Local",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Order ID:"),
                  pw.Text(order.id.substring(0, 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Date:"),
                  pw.Text(
                    DateFormat('dd-MM-yyyy HH:mm').format(order.createdAt),
                  ),
                ],
              ),
              pw.Divider(),
              pw.Text("Customer: ${order.customerName}"),
              pw.Text("Phone: ${order.customerPhone}"),
              pw.Divider(),
              pw.Text("Items:"),
              ...order.items.map(
                (item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        "${item.quantity}x ${item.garmentName} (${item.serviceType})",
                      ),
                    ),
                    pw.Text(CurrencyFormatter.format(item.totalDataPrice)),
                  ],
                ),
              ),
              pw.Divider(),
              if (order.isUrgent)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Urgent Fee:"),
                    pw.Text(CurrencyFormatter.format(order.urgentFee)),
                  ],
                ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Total:",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    CurrencyFormatter.format(order.totalAmount),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: "Order:${order.id}|Amt:${order.totalAmount}",
                  width: 100,
                  height: 100,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(child: pw.Text("Scan to Pay or Track")),
            ],
          );
        },
      ),
    );

    // This opens the native share sheet which includes "Print" and "Share to WhatsApp" (via generic share)
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_${order.id.substring(0, 8)}.pdf',
    );
  }
}

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});
