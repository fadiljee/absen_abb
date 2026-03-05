import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart' hide Border; // Fix error Border
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/db_helper.dart';
import '../models/pegawai_model.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class AppColors {
  static const crimson     = Color(0xFFB71C1C);
  static const crimsonDeep = Color(0xFF7F0000);
  static const crimsonGlow = Color(0xFFEF5350);
  static const surface     = Color(0xFF121212);
  static const card        = Color(0xFF1E1E1E);
  static const cardBright  = Color(0xFF2A2A2A);
  static const onSurface   = Color(0xFFF5F5F5);
  static const muted       = Color(0xFF757575);
  static const accent      = Color(0xFFFF6B6B);

  // Status colors
  static const statusMasuk    = Color(0xFF4CAF50);
  static const statusTelat    = Color(0xFFFF9800);
  static const statusIzin     = Color(0xFF2196F3);
  static const statusCuti     = Color(0xFF9C27B0);
  static const statusSakit    = Color(0xFF00BCD4);
  static const statusDefault  = Color(0xFF455A64);
}

// ─────────────────────────────────────────────
//  STATUS HELPER (UPDATED DEFAULT TO MASUK)
// ─────────────────────────────────────────────
Color _statusColor(String? status) {
  String s = status ?? '';
  // Jika kosong atau belum absen, otomatis jadikan M (MASUK)
  if (s.isEmpty || s == 'BELUM ABSEN' || s == 'null') s = 'M (MASUK)';

  s = s.toUpperCase();
  if (s.startsWith('M ('))  return AppColors.statusMasuk;
  if (s.startsWith('T ('))  return AppColors.statusTelat;
  if (s.startsWith('IT'))   return AppColors.statusIzin;
  if (s.startsWith('S ('))  return AppColors.statusSakit;
  if (s.startsWith('C ('))  return AppColors.statusCuti;
  if (s.startsWith('L ('))  return AppColors.statusIzin;
  return AppColors.statusDefault;
}

String _statusLabel(String? status) {
  String s = status ?? '';
  // Jika kosong atau belum absen, otomatis jadikan M (MASUK)
  if (s.isEmpty || s == 'BELUM ABSEN' || s == 'null') s = 'M (MASUK)';

  final parts = s.split(' ');
  return parts.isNotEmpty ? parts.first : 'M';
}

// ─────────────────────────────────────────────
//  ANIMATED GRADIENT BACKGROUND
// ─────────────────────────────────────────────
class _AnimatedBackground extends StatefulWidget {
  final Widget child;
  const _AnimatedBackground({required this.child});
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = _ctrl.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -0.6 + 0.4 * math.sin(t * math.pi),
                -0.4 + 0.3 * math.cos(t * math.pi),
              ),
              radius: 1.4 + 0.2 * math.sin(t * math.pi * 2),
              colors: const [
                Color(0xFF2D0000),
                AppColors.surface,
                AppColors.surface,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────
//  STAGGERED LIST ITEM ANIMATION
// ─────────────────────────────────────────────
class _AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedListItem({required this.child, required this.index});
  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 40 * (widget.index % 15));
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ─────────────────────────────────────────────
//  PULSE ANIMATION FOR FAB
// ─────────────────────────────────────────────
class _PulseFab extends StatefulWidget {
  final VoidCallback onPressed;
  const _PulseFab({required this.onPressed});
  @override
  State<_PulseFab> createState() => _PulseFabState();
}

class _PulseFabState extends State<_PulseFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: FloatingActionButton.extended(
        backgroundColor: AppColors.crimson,
        onPressed: () {
          HapticFeedback.mediumImpact();
          widget.onPressed();
        },
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('Tambah Pegawai',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        elevation: 8,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Pegawai> _displayPegawai = [];
  bool _isLoading = false;
  bool _hasMore   = true;
  int  _currentPage = 0;
  final int _limit  = 20;

  String _searchQuery      = "";
  String _selectedJobdesk  = "Semua";
  String _sortBy           = "nama_asc";

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Header animation
  late AnimationController _headerCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  final List<String> _listJobdesk = [
    'Semua', 'Drafter', 'Teknisi', 'Junior Waspang', 'Helpdesk', 'Korlap', 'Staff'
  ];

  final List<String> _kategori = [
    'M (MASUK)', 'T (TERLAMBAT)', 'IT (IZIN TELAT)', 'TB (TIDAK BRIEFING)',
    'C (CUTI)', 'L (LIBUR)', 'S (SAKIT)', 'SS (SHIFT SIANG)',
    'KM (KERJA MALAM)', 'PD (SPPD)'
  ];

  @override
  void initState() {
    super.initState();

    _headerCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();

    _loadInitialData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Data fetching ───────────────────────────
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
      _displayPegawai = [];
    });
    await _fetchData();
  }

  Future<void> _loadMoreData() async {
    _currentPage++;
    await _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await DbHelper.instance.getPegawaiPro(
      limit: _limit,
      offset: _currentPage * _limit,
      search: _searchQuery,
      jobdesk: _selectedJobdesk == 'Semua' ? "" : _selectedJobdesk,
      sortBy: _sortBy,
    );
    setState(() {
      if (data.length < _limit) _hasMore = false;
      _displayPegawai.addAll(data.map((e) => Pegawai.fromMap(e)).toList());
      _isLoading = false;
    });
  }

  // ─── Add pegawai ─────────────────────────────
  void _showAddPegawaiDialog() {
    final nikCtrl  = TextEditingController();
    final namaCtrl = TextEditingController();
    String tempJob = "Teknisi";

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: _buildDialogCard(
          title: "Tambah Pegawai Baru",
          icon: Icons.person_add_alt_1_rounded,
          child: StatefulBuilder(
            builder: (_, setS) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nikCtrl,  "NIK",           Icons.badge_rounded),
                const SizedBox(height: 14),
                _buildTextField(namaCtrl, "Nama Lengkap",  Icons.person_rounded),
                const SizedBox(height: 14),
                _buildDropdown<String>(
                  value: tempJob,
                  label: "Jobdesk",
                  icon: Icons.work_rounded,
                  items: _listJobdesk.where((e) => e != 'Semua').toList(),
                  onChanged: (v) => setS(() => tempJob = v!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildOutlineBtn("Batal", () => Navigator.pop(ctx))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPrimaryBtn("Simpan", () async {
                        if (nikCtrl.text.isNotEmpty && namaCtrl.text.isNotEmpty) {
                          await DbHelper.instance.tambahPegawai(nikCtrl.text, namaCtrl.text, jobdesk: tempJob);
                          Navigator.pop(ctx);
                          _loadInitialData();
                        }
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Update status ────────────────────────────
  void _updateStatus(String nik, String status) async {
    HapticFeedback.selectionClick();
    await DbHelper.instance.simpanBatchAbsen([nik], status);
    _loadInitialData();
  }

  // ─── Reset dialog ─────────────────────────────
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: _buildDialogCard(
          title: "Reset Absensi",
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Semua data absensi hari ini akan dihapus.\nData pegawai tetap aman.",
                style: TextStyle(color: AppColors.muted, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildOutlineBtn("Batal", () => Navigator.pop(ctx))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDangerBtn("Reset", () async {
                      await DbHelper.instance.resetAbsensiHanya();
                      Navigator.pop(ctx);
                      _loadInitialData();
                      if (mounted) _showSnack("Data absen berhasil di-reset!", Colors.orange);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Export Excel ─────────────────────────────
  Future<void> _exportToExcel() async {
    setState(() => _isLoading = true);
    try {
      final data  = await DbHelper.instance.getLaporanAbsensiHariIni();
      final excel = Excel.createExcel();
      final sheet = excel['Absensi'];
      excel.setDefaultSheet('Absensi');

      sheet.appendRow([
        TextCellValue('NIK'), TextCellValue('Nama Lengkap'),
        TextCellValue('Jobdesk'), TextCellValue('Status Kehadiran'),
      ]);
      
      for (var row in data) {
        String st = row['status']?.toString() ?? '';
        
        // Ubah default ke M (MASUK) untuk laporan Excel
        if (st.isEmpty || st == 'BELUM ABSEN' || st == 'null') {
          st = 'M (MASUK)';
        }

        sheet.appendRow([
          TextCellValue(row['nik'].toString()),
          TextCellValue(row['nama'].toString()),
          TextCellValue(row['jobdesk'].toString()),
          TextCellValue(st),
        ]);
      }

      final bytes = excel.save();
      final dir   = await getApplicationDocumentsDirectory();
      final tgl   = DateTime.now().toIso8601String().split('T')[0];
      final path  = '${dir.path}/Laporan_Absensi_$tgl.xlsx';
      await File(path).writeAsBytes(bytes!);
      await Share.shareXFiles([XFile(path)], text: 'Laporan Absensi $tgl');
    } catch (e) {
      if (mounted) _showSnack("Gagal Export: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Sort bottom sheet ────────────────────────
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text("Urutkan", style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.onSurface, fontFamily: 'serif',
            )),
            const SizedBox(height: 16),
            ...[
              ("Nama A → Z", Icons.sort_by_alpha, "nama_asc"),
              ("Nama Z → A", Icons.sort_by_alpha, "nama_desc"),
              ("NIK",        Icons.tag,            "nik_asc"),
            ].map((item) => _buildSortTile(item.$1, item.$2, item.$3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSortTile(String label, IconData icon, String val) {
    final selected = _sortBy == val;
    return InkWell(
      onTap: () {
        _sortBy = val;
        Navigator.pop(context);
        _loadInitialData();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.crimson.withOpacity(0.15) : AppColors.cardBright,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: AppColors.crimson, width: 1.5) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.crimson : AppColors.muted, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(
              color: selected ? AppColors.onSurface : AppColors.muted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            )),
            const Spacer(),
            if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.crimson, size: 18),
          ],
        ),
      ),
    );
  }

  // ─── MAIN BUILD ───────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: _AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildJobdeskFilter(),
              _buildSummaryRow(),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
      floatingActionButton: _PulseFab(onPressed: _showAddPegawaiDialog),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ─── HEADER ───────────────────────────────────
  Widget _buildHeader() {
    final now   = DateTime.now();
    final bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final days  = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    final hari  = days[now.weekday - 1];
    final tgl   = '$hari, ${now.day} ${bulan[now.month - 1]} ${now.year}';

    return SlideTransition(
      position: _headerSlide,
      child: FadeTransition(
        opacity: _headerFade,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monogram badge
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.crimson, AppColors.crimsonGlow],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.crimson.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Manajemen Pegawai",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                          color: AppColors.onSurface, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    Text(tgl,
                      style: const TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.2)),
                  ],
                ),
              ),
              // Menu
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBright,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.onSurface),
                  color: AppColors.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (val) {
                    if (val == 'export') _exportToExcel();
                    else if (val == 'reset') _showResetDialog();
                  },
                  itemBuilder: (_) => [
                    _menuItem('export', Icons.file_download_rounded, "Export Excel", AppColors.statusMasuk),
                    _menuItem('reset',  Icons.refresh_rounded,       "Reset Absen",  AppColors.crimsonGlow),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String val, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: val,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.onSurface)),
        ],
      ),
    );
  }

  // ─── SEARCH BAR ───────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.cardBright,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) { _searchQuery = v; _loadInitialData(); },
          style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
          cursorColor: AppColors.crimson,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Cari NIK atau nama...",
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.muted, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _searchQuery = "";
                      _loadInitialData();
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  // ─── JOBDESK FILTER ───────────────────────────
  Widget _buildJobdeskFilter() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _listJobdesk.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _sortChip();
          }
          final job      = _listJobdesk[i - 1];
          final selected = _selectedJobdesk == job;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedJobdesk = job);
                _loadInitialData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? AppColors.crimson : AppColors.cardBright,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.crimson : Colors.white.withOpacity(0.06),
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: AppColors.crimson.withOpacity(0.3), blurRadius: 8)]
                      : null,
                ),
                child: Text(job,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? Colors.white : AppColors.muted,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sortChip() {
    return GestureDetector(
      onTap: _showSortSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBright,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: const Row(
          children: [
            Icon(Icons.tune_rounded, color: AppColors.muted, size: 14),
            SizedBox(width: 4),
            Text("Sortir", style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  // ─── SUMMARY ROW ──────────────────────────────
  Widget _buildSummaryRow() {
    final total = _displayPegawai.length;
    
    // Hadir = yang statusnya M, kosong, atau BELUM ABSEN
    final hadir = _displayPegawai.where((p) {
      final s = p.status ?? '';
      return s.isEmpty || s == 'BELUM ABSEN' || s == 'null' || s.startsWith('M');
    }).length;

    // Lainnya = Mereka yang tercatat Telat, Sakit, Izin, Cuti, dll
    final lainnya = total - hadir;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _summaryBadge("Total",  total.toString(),  AppColors.muted),
          const SizedBox(width: 8),
          _summaryBadge("Hadir",  hadir.toString(),  AppColors.statusMasuk),
          const SizedBox(width: 8),
          _summaryBadge("Lainnya", lainnya.toString(), AppColors.statusTelat),
          const Spacer(),
          if (_isLoading)
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.crimson,
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryBadge(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text("$label: $val",
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── LIST ─────────────────────────────────────
  Widget _buildList() {
    if (_displayPegawai.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: AppColors.muted.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text("Data tidak ditemukan",
              style: TextStyle(color: AppColors.muted, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: _displayPegawai.length + (_hasMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _displayPegawai.length) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: AppColors.crimson, strokeWidth: 2)),
          );
        }
        final p = _displayPegawai[i];
        return _AnimatedListItem(index: i, child: _buildCard(p));
      },
    );
  }

  Widget _buildCard(Pegawai p) {
    final color  = _statusColor(p.status);
    final label  = _statusLabel(p.status);
    final initials = p.nama.trim().split(' ')
        .take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: AppColors.crimson.withOpacity(0.08),
          highlightColor: Colors.white.withOpacity(0.03),
          onTap: () {}, // future detail page
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(initials,
                      style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nama,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(child: _infoChip(p.nik, Icons.badge_outlined)),
                          const SizedBox(width: 6),
                          Flexible(child: _infoChip(p.jobdesk, Icons.work_outline_rounded)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status selector
                PopupMenuButton<String>(
                  color: AppColors.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (val) => _updateStatus(p.nik, val),
                  itemBuilder: (_) => _kategori.map((e) {
                    final c = _statusColor(e);
                    return PopupMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          Container(width: 8, height: 8,
                            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                          const SizedBox(width: 10),
                          Text(e, style: const TextStyle(color: AppColors.onSurface, fontSize: 13)),
                        ],
                      ),
                    );
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 7, height: 7,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(label,
                          style: TextStyle(
                            color: color, fontSize: 12, fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          )),
                        const SizedBox(width: 4),
                        Icon(Icons.expand_more_rounded, color: color, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.muted),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  // ─── DIALOG HELPERS ───────────────────────────
  Widget _buildDialogCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color iconColor = AppColors.crimson,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.onSurface),
      cursorColor: AppColors.crimson,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.muted, size: 18),
        filled: true,
        fillColor: AppColors.cardBright,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.crimson, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBright,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: AppColors.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.muted, size: 18),
          border: InputBorder.none,
        ),
        items: items.map((e) => DropdownMenuItem(
          value: e,
          child: Text(e.toString(), style: const TextStyle(color: AppColors.onSurface, fontSize: 14)),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPrimaryBtn(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.crimson,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildOutlineBtn(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.muted,
        side: const BorderSide(color: AppColors.muted, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label),
    );
  }

  Widget _buildDangerBtn(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }
}