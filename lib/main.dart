import 'package:flutter/material.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(KamalShareApp());
}

class KamalShareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KamalShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFF0D0D0D)),
      home: SplashScreen(),
    );
  }
}

// ─── Splash Screen ────────────────────────────────
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    _ctrl.forward();
    Future.delayed(Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFFE8FF47),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(Icons.wifi, color: Colors.black, size: 54),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Kamal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold)),
                  Text('Share',
                      style: TextStyle(
                          color: Color(0xFFE8FF47),
                          fontSize: 40,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Text('Phone to Phone File Transfer',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 14, letterSpacing: 1)),
              SizedBox(height: 60),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Color(0xFFE8FF47), strokeWidth: 2),
              ),
              SizedBox(height: 16),
              Text('Built by Kamal',
                  style: TextStyle(
                      color: Colors.white24, fontSize: 12, letterSpacing: 3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home Screen ──────────────────────────────────
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Kamal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                  Text('Share',
                      style: TextStyle(
                          color: Color(0xFFE8FF47),
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF161616),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text('v2.0',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text('No internet · No laptop · Just phones',
                  style: TextStyle(color: Colors.white38, fontSize: 13)),
              SizedBox(height: 48),

              // Send button
              _bigButton(
                context: context,
                icon: Icons.upload_rounded,
                iconColor: Colors.black,
                label: 'Send File',
                sublabel: 'Turn on hotspot and share',
                color: Color(0xFFE8FF47),
                textColor: Colors.black,
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => SenderScreen())),
              ),
              SizedBox(height: 16),

              // Receive button
              _bigButton(
                context: context,
                icon: Icons.download_rounded,
                iconColor: Colors.white,
                label: 'Receive File',
                sublabel: 'Scan QR code to connect',
                color: Color(0xFF161616),
                textColor: Colors.white,
                borderColor: Colors.white12,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ReceiverScreen())),
              ),

              Spacer(),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF161616),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How it works',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    _howRow('1', 'Sender taps Send File and turns on hotspot'),
                    _howRow('2', 'Receiver connects phone to sender hotspot'),
                    _howRow('3', 'Receiver taps Receive and scans QR code'),
                    _howRow('4', 'Select file and transfer instantly!'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'KAMALSHARE  ◆  ECE PROJECT  ◆  BUILT BY KAMAL',
                  style: TextStyle(
                      color: Colors.white24, fontSize: 10, letterSpacing: 1.5),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _howRow(String num, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(0xFFE8FF47).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(num,
                  style: TextStyle(
                      color: Color(0xFFE8FF47),
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _bigButton({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sublabel,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 3),
                Text(sublabel,
                    style: TextStyle(
                        color: textColor.withOpacity(0.5), fontSize: 12)),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios,
                color: textColor.withOpacity(0.4), size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Sender Screen ────────────────────────────────
class SenderScreen extends StatefulWidget {
  @override
  _SenderScreenState createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  String _ip = '192.168.43.1';
  int _port = 8080;
  HttpServer? _server;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  bool _loading = true;
  bool _fileSelected = false;
  int _downloadCount = 0;

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP() ??
          await info.getWifiGatewayIP() ??
          '192.168.43.1';
      setState(() {
        _ip = wifiIP;
        _loading = false;
      });

      final router = shelf_router.Router();

      router.get('/file', (shelf.Request request) async {
        if (_selectedFileBytes == null || _selectedFileName == null) {
          return shelf.Response.notFound('No file selected');
        }
        setState(() => _downloadCount++);
        return shelf.Response.ok(
          _selectedFileBytes!,
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Disposition': 'attachment; filename="$_selectedFileName"',
            'Content-Length': '${_selectedFileBytes!.length}',
          },
        );
      });

      router.get('/info', (shelf.Request request) {
        return shelf.Response.ok(
          jsonEncode({
            'filename': _selectedFileName ?? 'No file',
            'size': _selectedFileBytes?.length ?? 0,
            'ready': _selectedFileBytes != null,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      });

      router.get('/', (shelf.Request request) {
        return shelf.Response.ok(_buildHtml(),
            headers: {'Content-Type': 'text/html'});
      });

      final handler = const shelf.Pipeline()
          .addMiddleware(shelf.logRequests())
          .addHandler(router.call);

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, _port);
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _buildHtml() {
    final fname = _selectedFileName ?? 'No file selected';
    final ready = _selectedFileBytes != null;
    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>KamalShare</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:#0D0D0D;color:#F0F0F0;font-family:sans-serif;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:24px}
.card{background:#161616;border:1px solid rgba(255,255,255,0.1);border-radius:20px;padding:32px;width:100%;max-width:400px;text-align:center}
.logo{font-size:28px;font-weight:bold;margin-bottom:4px}
.logo span{color:#E8FF47}
.sub{color:#666;font-size:13px;margin-bottom:32px}
.file-name{background:#1E1E1E;border-radius:12px;padding:16px;font-size:14px;color:#ccc;margin-bottom:24px;word-break:break-all}
.btn{display:block;width:100%;padding:18px;background:#E8FF47;color:#000;border:none;border-radius:14px;font-size:16px;font-weight:bold;text-decoration:none;cursor:pointer}
.not-ready{background:#1E1E1E;color:#666;cursor:default}
.footer{margin-top:24px;font-size:11px;color:#333;letter-spacing:1px}
</style>
</head>
<body>
<div class="card">
  <div class="logo">Kamal<span>Share</span></div>
  <div class="sub">Wireless File Transfer by Kamal</div>
  <div class="file-name">${ready ? '📁 $fname' : '⏳ Waiting for file selection...'}</div>
  ${ready ? '<a class="btn" href="/file">⬇ Download $fname</a>' : '<div class="btn not-ready">No file selected yet</div>'}
  <div class="footer">KAMALSHARE · ECE PROJECT · BUILT BY KAMAL</div>
</div>
</body>
</html>''';
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFileBytes = result.files.single.bytes;
        _fileSelected = true;
        _downloadCount = 0;
      });
    }
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrData = 'http://$_ip:$_port';

    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Send File',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFE8FF47)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Status pill
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFF161616),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(0xFF47FFB2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Server active on $_ip:$_port',
                            style: TextStyle(
                                color: Color(0xFF47FFB2), fontSize: 12)),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Instructions
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFF161616),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      '1. Turn ON your mobile hotspot\n2. Tell receiver to connect to your hotspot\n3. Select file below\n4. Show QR code to receiver to scan',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 12, height: 1.8),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Pick file
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _fileSelected
                            ? Color(0xFF1A2A1A)
                            : Color(0xFF161616),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _fileSelected
                              ? Color(0xFF47FFB2)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _fileSelected
                                ? Icons.check_circle
                                : Icons.attach_file,
                            color: _fileSelected
                                ? Color(0xFF47FFB2)
                                : Colors.white54,
                            size: 24,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fileSelected
                                      ? _selectedFileName!
                                      : 'Tap to select file',
                                  style: TextStyle(
                                      color: _fileSelected
                                          ? Colors.white
                                          : Colors.white54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (_fileSelected)
                                  Text(
                                    '${(_selectedFileBytes!.length / 1024).toStringAsFixed(1)} KB',
                                    style: TextStyle(
                                        color: Colors.white38, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.white24),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // QR Code — ALWAYS SHOWS
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Color(0xFF161616),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _fileSelected
                              ? 'Show this QR to receiver'
                              : 'Select a file first, then show this QR',
                          style: TextStyle(
                              color: _fileSelected
                                  ? Colors.white70
                                  : Colors.white38,
                              fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 180,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            qrData,
                            style: TextStyle(
                                color: Color(0xFFE8FF47),
                                fontSize: 12,
                                fontFamily: 'monospace'),
                          ),
                        ),
                        if (_downloadCount > 0) ...[
                          SizedBox(height: 12),
                          Text(
                            '✓ File downloaded $_downloadCount time(s)',
                            style: TextStyle(
                                color: Color(0xFF47FFB2), fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// ─── Receiver Screen ──────────────────────────────
class ReceiverScreen extends StatefulWidget {
  @override
  _ReceiverScreenState createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  bool scanned = false;
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Receive File',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFF161616),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Connect your Wi-Fi to sender\'s hotspot first, then scan their QR code',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
              ),
            ),
          ),
          SizedBox(height: 24),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFE8FF47), width: 2),
            ),
            clipBehavior: Clip.hardEdge,
            child: AspectRatio(
              aspectRatio: 1,
              child: MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  if (!scanned && capture.barcodes.isNotEmpty) {
                    final url = capture.barcodes.first.rawValue;
                    if (url != null) {
                      scanned = true;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DownloadScreen(url: url)),
                      );
                    }
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 24),
          Text('Scanning automatically...',
              style: TextStyle(
                  color: Color(0xFF47FFB2), fontSize: 13, letterSpacing: 1)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

// ─── Download Screen ──────────────────────────────
class DownloadScreen extends StatefulWidget {
  final String url;
  const DownloadScreen({required this.url});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  String _status = 'Connecting...';
  String? _fileName;
  bool _downloading = false;
  bool _done = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _getFileInfo();
  }

  Future<void> _getFileInfo() async {
    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse('${widget.url}/info'));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final data = jsonDecode(body);
      setState(() {
        _fileName = data['filename'];
        _status = data['ready']
            ? 'Ready! Tap download below'
            : 'Sender has not selected a file yet';
      });
    } catch (e) {
      setState(() => _status = 'Connection failed. Check Wi-Fi hotspot.');
    }
  }

  Future<void> _downloadFile() async {
    setState(() {
      _downloading = true;
      _status = 'Downloading...';
      _progress = 0;
    });
    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse('${widget.url}/file'));
      final res = await req.close();
      final total = res.contentLength;
      int received = 0;
      final bytes = <int>[];
      await for (final chunk in res) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (total > 0) {
          setState(() => _progress = received / total);
        }
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      await file.writeAsBytes(bytes);
      setState(() {
        _done = true;
        _progress = 1;
        _status = 'Downloaded! Saved to app folder.';
      });
    } catch (e) {
      setState(() {
        _downloading = false;
        _status = 'Download failed. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Download File',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _done ? Color(0xFF1A2A1A) : Color(0xFF161616),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _done ? Color(0xFF47FFB2) : Colors.white12,
                ),
              ),
              child: Icon(
                _done ? Icons.check_circle : Icons.download_rounded,
                color: _done ? Color(0xFF47FFB2) : Colors.white54,
                size: 40,
              ),
            ),
            SizedBox(height: 24),
            if (_fileName != null)
              Text(_fileName!,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            SizedBox(height: 12),
            Text(_status,
                style: TextStyle(
                    color: _done ? Color(0xFF47FFB2) : Colors.white54,
                    fontSize: 14),
                textAlign: TextAlign.center),
            SizedBox(height: 24),
            if (_downloading || _done) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Color(0xFF1E1E1E),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8FF47)),
                  minHeight: 6,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: Color(0xFFE8FF47), fontSize: 13),
              ),
              SizedBox(height: 24),
            ],
            if (!_downloading && !_done && _fileName != null)
              GestureDetector(
                onTap: _downloadFile,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8FF47),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded,
                          color: Colors.black, size: 24),
                      SizedBox(width: 10),
                      Text('Download File',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            if (_done)
              GestureDetector(
                onTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF47FFB2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('Done! Go Home',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            SizedBox(height: 16),
            if (!_done)
              TextButton(
                onPressed: _getFileInfo,
                child: Text('Refresh', style: TextStyle(color: Colors.white38)),
              ),
          ],
        ),
      ),
    );
  }
}
