import 'package:web/web.dart' as web;

void downloadCsvFile(String content, String fileName) {
  final encoded = Uri.encodeComponent('\uFEFF$content');
  final anchor = web.HTMLAnchorElement()
    ..href = 'data:text/csv;charset=utf-8,$encoded'
    ..download = fileName.endsWith('.csv') ? fileName : '$fileName.csv';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}
