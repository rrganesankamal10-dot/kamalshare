import 'package:flutter/material.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'dart:convert';

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

const String kRecentKey = 'recent_transfers';

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

// ─── Notification helper ───────────────────────────
Future<void> initNotifications() async {
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await notifications.initialize(settings);
}

Future<void> showDownloadNotification(String fileName, String path) async {
  const androidDetails = AndroidNotificationDetails(
    'kamalshare_downloads',
    'KamalShare Downloads',
    channelDescription: 'Notifies when a file is received via KamalShare',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );
  const details = NotificationDetails(android: androidDetails);
  await notifications.show(
    fileName.hashCode,
    'Download complete',
    fileName,
    details,
    payload: path,
  );
}

// ─── Recent transfers storage ──────────────────────
class RecentFile {
  final String name;
  final String path;
  final int size;
  final String direction; // 'sent' or 'received'
  final DateTime time;

  RecentFile({
    required this.name,
    required this.path,
    required this.size,
    required this.direction,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'size': size,
        'direction': direction,
        'time': time.toIso8601String(),
      };

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
        name: json['name'],
        path: json['path'],
        size: json['size'],
        direction: json['direction'],
        time: DateTime.parse(json['time']),
      );
}

Future<List<RecentFile>> loadRecentFiles() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList(kRecentKey) ?? [];
  final list = raw
      .map((s) => RecentFile.fromJson(jsonDecode(s)))
      .toList();
  list.sort((a, b) => b.time.compareTo(a.time));
  return list;
}

Future<void> addRecentFile(RecentFile file) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList(kRecentKey) ?? [];
  raw.insert(0, jsonEncode(file.toJson()));
  if (raw.length > 30) raw.removeRange(30, raw.length);
  await prefs.setStringList(kRecentKey, raw);
}

String formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

String fileIcon(String name) {
  final ext = name.split('.').last.toLowerCase();
  const map = {
    'jpg': '🖼️', 'jpeg': '🖼️', 'png': '🖼️', 'gif': '🖼️', 'webp': '🖼️',
    'mp4': '🎬', 'mkv': '🎬', 'mov': '🎬', 'avi': '🎬',
    'mp3': '🎵', 'wav': '🎵', 'm4a': '🎵',
    'pdf': '📄', 'doc': '📝', 'docx': '📝', 'txt': '📝',
    'zip': '📦', 'rar': '📦', 'apk': '📱',
  };
  return map[ext] ?? '📁';
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
    _setup();
  }

  Future<void> _setup() async {
    await initNotifications();
    await Permission.notification.request();
    if (Platform.isAndroid) {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
    }
    await Future.delayed(Duration(milliseconds: 2000));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => HomeScreen()));
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
                width: 100, height: 100,
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
                      color: Colors.white38,
                      fontSize: 14,
                      letterSpacing: 1)),
              SizedBox(height: 60),
              SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                    color: Color(0xFFE8FF47), strokeWidth: 2),
              ),
              SizedBox(height: 16),
              Text('Built by Kamal',
                  style: TextStyle(
                      color: Colors.white24,
                      fontSize: 12,
                      letterSpacing: 3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home Screen ──────────────────────────────────
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RecentFile> _recent = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final list = await loadRecentFiles();
    setState(() => _recent = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: SafeArea(
        child: RefreshIndicator(
          color: Color(0xFFE8FF47),
          backgroundColor: Color(0xFF161616),
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.all(24),
            children: [
              SizedBox(height: 10),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF161616),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text('v3.0',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 12)),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text('No internet · No laptop · Just phones',
                  style:
                      TextStyle(color: Colors.white38, fontSize: 13)),
              SizedBox(height: 40),

              _bigButton(
                context: context,
                icon: Icons.upload_rounded,
                iconColor: Colors.black,
                label: 'Send File',
                sublabel: 'Turn on hotspot and share',
                color: Color(0xFFE8FF47),
                textColor: Colors.black,
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SenderScreen()));
                  _refresh();
                },
              ),
              SizedBox(height: 16),

              _bigButton(
                context: context,
                icon: Icons.download_rounded,
                iconColor: Colors.white,
                label: 'Receive File',
                sublabel: 'Scan QR code to connect',
                color: Color(0xFF161616),
                textColor: Colors.white,
                borderColor: Colors.white12,
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => ReceiverScreen()));
                  _refresh();
                },
              ),

              SizedBox(height: 32),

              // Recent transfers
              Row(
                children: [
                  Text('Recent transfers',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Spacer(),
                  if (_recent.isNotEmpty)
                    Text('${_recent.length}',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 12)),
                ],
              ),
              SizedBox(height: 12),

              if (_recent.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFF161616),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Center(
                    child: Text(
                      'No files shared yet\nSend or receive a file to see it here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white38, fontSize: 12, height: 1.6),
                    ),
                  ),
                )
              else
                ..._recent.map((f) => _recentTile(f)).toList(),

              SizedBox(height: 24),
              Center(
                child: Text(
                  'KAMALSHARE  ◆  ECE PROJECT  ◆  BUILT BY KAMAL',
                  style: TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                      letterSpacing: 1.5),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentTile(RecentFile f) {
    return GestureDetector(
      onTap: () {
        if (f.direction == 'received') {
          OpenFilex.open(f.path);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Text(fileIcon(f.name), style: TextStyle(fontSize: 22)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 2),
                  Text('${formatSize(f.size)} · ${f.direction}',
                      style: TextStyle(
                          color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            Icon(
              f.direction == 'sent'
                  ? Icons.north_east_rounded
                  : Icons.south_west_rounded,
              color: f.direction == 'sent'
                  ? Color(0xFFE8FF47)
                  : Color(0xFF47FFB2),
              size: 18,
            ),
          ],
        ),
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
          border: borderColor != null
              ? Border.all(color: borderColor)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
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
                        color: textColor.withOpacity(0.5),
                        fontSize: 12)),
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
// Streams the file from disk in chunks instead of loading it
// fully into memory — this is what lets large videos (500MB-1GB+)
// transfer without crashing the app.
class SenderScreen extends StatefulWidget {
  @override
  _SenderScreenState createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  String _ip = '192.168.43.1';
  final int _port = 8080;
  HttpServer? _server;
  String? _selectedFileName;
  String? _selectedFilePath;
  int _selectedFileSize = 0;
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

      // Streams the file in chunks straight from disk —
      // works for files of any size, including 1GB+ videos.
      router.get('/file', (shelf.Request request) async {
        if (_selectedFilePath == null) {
          return shelf.Response.notFound('No file selected');
        }
        final file = File(_selectedFilePath!);
        if (!await file.exists()) {
          return shelf.Response.notFound('File missing');
        }
        final length = await file.length();
        setState(() => _downloadCount++);
        return shelf.Response.ok(
          file.openRead(),
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Disposition':
                'attachment; filename="$_selectedFileName"',
            'Content-Length': '$length',
          },
        );
      });

      router.get('/info', (shelf.Request request) {
        return shelf.Response.ok(
          jsonEncode({
            'filename': _selectedFileName ?? 'No file',
            'size': _selectedFileSize,
            'ready': _selectedFilePath != null,
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

      _server = await shelf_io.serve(
          handler, InternetAddress.anyIPv4, _port);
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _buildHtml() {
    final fname = _selectedFileName ?? 'No file selected';
    final ready = _selectedFilePath != null;
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
  <div class="file-name">${ready ? '📁 $fname (${formatSize(_selectedFileSize)})' : '⏳ Waiting for file selection...'}</div>
  ${ready ? '<a class="btn" href="/file">⬇ Download $fname</a>' : '<div class="btn not-ready">No file selected yet</div>'}
  <div class="footer">KAMALSHARE · ECE PROJECT · BUILT BY KAMAL</div>
</div>
</body>
</html>''';
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final size = await File(path).length();
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFilePath = path;
        _selectedFileSize = size;
        _fileSelected = true;
        _downloadCount = 0;
      });
    }
  }

  Future<void> _onSentOnce() async {
    if (_selectedFileName == null || _selectedFilePath == null) return;
    await addRecentFile(RecentFile(
      name: _selectedFileName!,
      path: _selectedFilePath!,
      size: _selectedFileSize,
      direction: 'sent',
      time: DateTime.now(),
    ));
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
          ? Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFE8FF47)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
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
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: Color(0xFF47FFB2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Server active on $_ip:$_port',
                            style: TextStyle(
                                color: Color(0xFF47FFB2),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFF161616),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      '1. Turn ON your mobile hotspot\n2. Tell receiver to connect to your hotspot\n3. Select any file — photo, video, doc, even 1GB+\n4. Show QR code to receiver to scan',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.8),
                    ),
                  ),
                  SizedBox(height: 20),
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
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fileSelected
                                      ? _selectedFileName!
                                      : 'Tap to select any file (photo, video, doc)',
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
                                    formatSize(_selectedFileSize),
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: Colors.white24),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
                                color: Color(0xFF47FFB2),
                                fontSize: 13),
                          ),
                          if (_downloadCount == 1) ...[
                            Builder(builder: (_) {
                              _onSentOnce();
                              return SizedBox.shrink();
                            }),
                          ],
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
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.5),
              ),
            ),
          ),
          SizedBox(height: 24),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Color(0xFFE8FF47), width: 2),
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
                            builder: (_) =>
                                DownloadScreen(url: url)),
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
                  color: Color(0xFF47FFB2),
                  fontSize: 13,
                  letterSpacing: 1)),
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
// Streams the response to disk in chunks instead of buffering
// the whole file in RAM — required so 1GB+ videos don't crash.
class DownloadScreen extends StatefulWidget {
  final String url;
  const DownloadScreen({required this.url});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  String _status = 'Connecting...';
  String? _fileName;
  int _totalSize = 0;
  bool _downloading = false;
  bool _done = false;
  double _progress = 0;
  String _savedPath = '';

  @override
  void initState() {
    super.initState();
    _getFileInfo();
  }

  Future<void> _getFileInfo() async {
    try {
      final client = HttpClient();
      final req =
          await client.getUrl(Uri.parse('${widget.url}/info'));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final data = jsonDecode(body);
      setState(() {
        _fileName = data['filename'];
        _totalSize = data['size'] ?? 0;
        _status = data['ready']
            ? 'Ready! Tap download below'
            : 'Sender has not selected a file yet';
      });
    } catch (e) {
      setState(() =>
          _status = 'Connection failed. Check Wi-Fi hotspot.');
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
      final req =
          await client.getUrl(Uri.parse('${widget.url}/file'));
      final res = await req.close();
      final total = res.contentLength > 0 ? res.contentLength : _totalSize;

      final downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      final file = File('${downloadDir.path}/$_fileName');
      final sink = file.openWrite();

      int received = 0;
      await for (final chunk in res) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          setState(() => _progress = received / total);
        }
      }
      await sink.flush();
      await sink.close();

      await addRecentFile(RecentFile(
        name: _fileName!,
        path: file.path,
        size: received,
        direction: 'received',
        time: DateTime.now(),
      ));

      await showDownloadNotification(_fileName!, file.path);

      setState(() {
        _done = true;
        _progress = 1;
        _savedPath = file.path;
        _status = 'Saved to Downloads folder!';
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
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _done
                    ? Color(0xFF1A2A1A)
                    : Color(0xFF161616),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _done
                      ? Color(0xFF47FFB2)
                      : Colors.white12,
                ),
              ),
              child: Icon(
                _done
                    ? Icons.check_circle
                    : Icons.download_rounded,
                color:
                    _done ? Color(0xFF47FFB2) : Colors.white54,
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
            if (_totalSize > 0) ...[
              SizedBox(height: 4),
              Text(formatSize(_totalSize),
                  style: TextStyle(
                      color: Colors.white38, fontSize: 12)),
            ],
            SizedBox(height: 12),
            Text(_status,
                style: TextStyle(
                    color: _done
                        ? Color(0xFF47FFB2)
                        : Colors.white54,
                    fontSize: 14),
                textAlign: TextAlign.center),
            if (_done) ...[
              SizedBox(height: 8),
              Text('Files app → Download → $_fileName',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.center),
            ],
            SizedBox(height: 24),
            if (_downloading || _done) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Color(0xFF1E1E1E),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFE8FF47)),
                  minHeight: 6,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    color: Color(0xFFE8FF47), fontSize: 13),
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
            if (_done) ...[
              GestureDetector(
                onTap: () => OpenFilex.open(_savedPath),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFF161616),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF47FFB2)),
                  ),
                  child: Center(
                    child: Text('Open File',
                        style: TextStyle(
                            color: Color(0xFF47FFB2),
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.popUntil(
                    context, (route) => route.isFirst),
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
            ],
            SizedBox(height: 16),
            if (!_done)
              TextButton(
                onPressed: _getFileInfo,
                child: Text('Refresh',
                    style: TextStyle(color: Colors.white38)),
              ),
          ],
        ),
      ),
    );
  }
}
