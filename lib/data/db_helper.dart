import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Versi v3 karena kita menambahkan banyak fitur baru
    _database = await _initDB('telkom_absen_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabel Master Pegawai
    await db.execute('''
      CREATE TABLE pegawai (
        nik TEXT PRIMARY KEY, 
        nama TEXT, 
        jobdesk TEXT
      )
    ''');

    // 2. Tabel Absensi (Riwayat)
    await db.execute('''
      CREATE TABLE absensi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nik TEXT,
        status TEXT,
        tanggal TEXT
      )
    ''');

    // 3. SEEDING SEMUA DATA PEGAWAI
    final batch = db.batch();
    
    final List<Map<String, String>> dataPegawai = [
      {'nik': '18970451', 'nama': 'RONAL BOAS HOTLAN ARIFSANTO TAMBUNAN', 'jobdesk': 'Team Leader Survey, Drawing & Inventory'},
      {'nik': '18940416', 'nama': 'EFAN KURNIAWAN', 'jobdesk': 'Drafter'},
      {'nik': '18880043', 'nama': 'NOURMA YULINTHIE,A.MD', 'jobdesk': 'Drafter'},
      {'nik': '18930544', 'nama': 'YULIS MARITA', 'jobdesk': 'Drafter PT-2'},
      {'nik': '20940937', 'nama': 'BUDI INDRAWAN', 'jobdesk': 'Drafter PT-2'},
      {'nik': '19910250', 'nama': 'REZA ANGKASA PAHLEVI', 'jobdesk': 'Surveyor'},
      {'nik': '21010068', 'nama': 'NURLAILA RIZKA RAMADONNA', 'jobdesk': 'Staff Project Admin & Control'},
      {'nik': '19970121', 'nama': 'IQBAL ANDEKA', 'jobdesk': 'Junior Waspang'},
      {'nik': '21030003', 'nama': 'YUDA RAIHAN RAMADHAN', 'jobdesk': 'Junior Waspang'},
      {'nik': '20961449', 'nama': 'ARIS PRATAMA', 'jobdesk': 'Junior Waspang'},
      {'nik': '18960035', 'nama': 'WILLY AMANCO ANDREAN', 'jobdesk': 'Junior Waspang'},
      {'nik': '25980116', 'nama': 'GALANG SAPUTRA', 'jobdesk': 'Junior Waspang'},
      {'nik': '25020140', 'nama': 'MUHAMMAD RIFQI FIRDAUS', 'jobdesk': 'Junior Waspang'},
      {'nik': '25000120', 'nama': 'NADYA GUSTINI', 'jobdesk': 'Staff Project Admin & Control'},
      {'nik': '25010123', 'nama': 'SALWA DETA MEDIANA', 'jobdesk': 'Staff Project Admin & Control'},
      {'nik': '25010124', 'nama': 'NUGRAH DELA CAHYANI', 'jobdesk': 'Staff Project Admin & Control'},
      {'nik': '20971597', 'nama': 'ANANDA SATRIO RAMADHAN', 'jobdesk': 'Junior Waspang'},
      {'nik': '19940017', 'nama': 'HOIRI', 'jobdesk': 'Junior Waspang'},
      {'nik': '20921054', 'nama': 'DIMAS TEGUH PRAKOSO', 'jobdesk': 'Officer 3 Project Supervision'},
      {'nik': '20900003', 'nama': 'ALFI HADIN', 'jobdesk': 'Officer 3 Project Support'},
      {'nik': '20900385', 'nama': 'HERAWAN', 'jobdesk': 'Officer 3 Project Support'},
      {'nik': '20931071', 'nama': 'ANISA SAFUTRY', 'jobdesk': 'Helpdesk BGES'},
      {'nik': '20961121', 'nama': 'YOUBI RESNANDA', 'jobdesk': 'Helpdesk BGES'},
      {'nik': '19940086', 'nama': 'MOHAMMAD RIZKY', 'jobdesk': 'Teknisi BGES Services'},
      {'nik': '19930343', 'nama': 'RISKY NOVRIANDY', 'jobdesk': 'Teknisi BGES Services'},
      {'nik': '19920306', 'nama': 'ALAMSYAH PRAWIRA', 'jobdesk': 'Teknisi BGES Services'},
      {'nik': '19970111', 'nama': 'AUR DURI SYAPUTRA', 'jobdesk': 'Teknisi BGES Services'},
      {'nik': '18960725', 'nama': 'DERY SAPUTRA', 'jobdesk': 'Teknisi BGES Services'},
      {'nik': '20890225', 'nama': 'BAGUS WIJAYA SHULUR', 'jobdesk': 'Teknisi BGES Services'},
      {'nik': '22970091', 'nama': 'MUHAMMAD ROMI SETIAWAN', 'jobdesk': 'Teknisi BGES Services'},
      {'nik': '19910249', 'nama': 'RIANSYAH', 'jobdesk': 'Teknisi BGES Services'},
      {'nik': '18920292', 'nama': 'SUSANTO', 'jobdesk': 'Teknisi MO SPBU'},
      {'nik': '20981002', 'nama': 'FERDY IKHLAS MUTTAQIN', 'jobdesk': 'Teknisi MO SPBU'},
      {'nik': '20931068', 'nama': 'AGUNG WIDIO UTOMO', 'jobdesk': 'Teknisi MO SPBU'},
      {'nik': '19900207', 'nama': 'SUPRATNO', 'jobdesk': 'Teknisi MO SPBU'},
      {'nik': '18920336', 'nama': 'WANDA SAPUTRA', 'jobdesk': 'Teknisi MO SPBU'},
      {'nik': '19790014', 'nama': 'ACHMAD RIZKIN', 'jobdesk': 'Team Leader Operation B2B'},
      {'nik': '24960037', 'nama': 'TERY YOLANDA', 'jobdesk': 'Helpdesk Data Management'},
      {'nik': '24950041', 'nama': 'MEIRY HIDAYATI', 'jobdesk': 'Helpdesk Data Management'},
      {'nik': '18940403', 'nama': 'APUNG SEFTIAWAN', 'jobdesk': 'Teknisi Wifi'},
      {'nik': '18940213', 'nama': 'FIRMANDA DEKA PUTRA', 'jobdesk': 'Teknisi Wifi'},
      {'nik': '19970363', 'nama': 'TRI INDAH JAYA', 'jobdesk': 'Teknisi Wifi'},
      {'nik': '24920024', 'nama': 'CISKA YOLANDA AGUSTIA', 'jobdesk': 'Helpdesk Data Management'},
      {'nik': '24920025', 'nama': 'OSTI BERTA SIAHAAN', 'jobdesk': 'Helpdesk Data Management'},
      {'nik': '21980077', 'nama': 'RANDA RISMUNANDAR', 'jobdesk': 'Helpdesk Provisioning BGES'},
      {'nik': '18950500', 'nama': 'DZULMI SUJANA', 'jobdesk': 'Teknisi Provisioning BGES'},
      {'nik': '19940287', 'nama': 'DEPENDRA PRATAMA PUTRA', 'jobdesk': 'Teknisi Provisioning BGES'},
      {'nik': '19950348', 'nama': 'BARIN FALO', 'jobdesk': 'Head Of Service Area'},
      {'nik': '22970098', 'nama': 'ACHMAD TRYBUANA KURNIASANDY', 'jobdesk': 'Helpdesk B2C'},
      {'nik': '866150', 'nama': 'JUFRIANDI', 'jobdesk': 'Officer 3 Service Area'},
      {'nik': '19950349', 'nama': 'PRASETYO', 'jobdesk': 'Korlap B2C'},
      {'nik': '20931069', 'nama': 'NOVA YANTI AMBARITA', 'jobdesk': 'Helpdesk B2C'},
      {'nik': '24900027', 'nama': 'GERRI AGUSTIAN PRATAMA', 'jobdesk': 'Korlap B2C'},
      {'nik': '23040001', 'nama': 'MUHAMMAD IB ROZHI FITRIANSYAH', 'jobdesk': 'Helpdesk B2C'},
      {'nik': '22010058', 'nama': 'PRISKA FUJIANTI', 'jobdesk': 'Staff B2C'},
      {'nik': '17750359', 'nama': 'MEDIYONO', 'jobdesk': 'Korlap B2C'},
      {'nik': '20961186', 'nama': 'SUPIRIYANTO', 'jobdesk': 'Teknisi Wilsus'},
      {'nik': '19950080', 'nama': 'DIO PIRNANDOS M', 'jobdesk': 'Teknisi Wilsus'},
      {'nik': '19960334', 'nama': 'RAMA FITRIZAR', 'jobdesk': 'Teknisi Wilsus'},
      {'nik': '22010125', 'nama': 'ARI SYABANI', 'jobdesk': 'Teknisi Wilsus'},
      {'nik': '20971713', 'nama': 'SAINUDIN', 'jobdesk': 'Teknisi Wilsus'},
      {'nik': '20951301', 'nama': 'NURHAYATI', 'jobdesk': 'Staff Commerce'},
      {'nik': '20981075', 'nama': 'MOHAMMAD REZA', 'jobdesk': 'Staff Inventory & Asset Management Area'},
      {'nik': '22020054', 'nama': 'FADHLURROHMAN ARROSYID RAMADHAN', 'jobdesk': 'Staff Inventory & Asset Management Area'},
      {'nik': '20920907', 'nama': 'FAISAL', 'jobdesk': 'Staff Warehouse SO'},
      {'nik': '21960118', 'nama': 'NOVIANDY LIANSYAH', 'jobdesk': 'Staff Warehouse SO'},
      {'nik': '20951211', 'nama': 'RYAN SAPUTRA', 'jobdesk': 'Staff Warehouse SO'},
      {'nik': '20961192', 'nama': 'M. YUSUF MAULANA', 'jobdesk': 'Staff Warehouse SO'},
      {'nik': '19890054', 'nama': 'RIAMA ROSALINA PASARIBU', 'jobdesk': 'Staff Warehouse SO'},
      {'nik': '835924', 'nama': 'DERI ALDES', 'jobdesk': 'Officer 3 Commercial & Supply Chain'},
      {'nik': '19930074', 'nama': 'NICO ELFANZA', 'jobdesk': 'Staff Fiber Expert & Marshal Area'},
      {'nik': '20860002', 'nama': 'MOCH. PRIMA SUTEJA', 'jobdesk': 'Staff Procurement & Partnership'},
      {'nik': '20980998', 'nama': 'SAZKYA LESTARI', 'jobdesk': 'Staff Finance & Bilco'},
      {'nik': '20920008', 'nama': 'ROBIYAS HIDAYAT', 'jobdesk': 'Staff HCM & Culture'},
      {'nik': '18930272', 'nama': 'AGUSTIAR', 'jobdesk': 'Staff Fiber Academy'},
      {'nik': '19900140', 'nama': 'FADLI', 'jobdesk': 'Officer 3 Business Support'},
      {'nik': '19960095', 'nama': 'MUHAMMAD SYAMSU ABDILLAH', 'jobdesk': 'Officer 3 Operation'},
      {'nik': '24940037', 'nama': 'RIZKI ARYSANDI', 'jobdesk': 'Helpdesk Data Management'},
      {'nik': '24960036', 'nama': 'MUHAMMAD NURHUDA', 'jobdesk': 'Helpdesk Data Management'},
      {'nik': '19940286', 'nama': 'NOVAN ARDIYANTO', 'jobdesk': 'Helpdesk TSEL'},
      {'nik': '20951006', 'nama': 'DONI LESMANA', 'jobdesk': 'Teknisi OLO'},
      {'nik': '18940015', 'nama': 'EKO SANJAYA', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '18920332', 'nama': 'APRIADI SUGIANTORO', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '18970415', 'nama': 'ZALIL IKRAM IZZUDIN', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '18950498', 'nama': 'MUHAMAD RIDUAN', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '20951007', 'nama': 'MARWANSYAH', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '19980085', 'nama': 'SCIFO EFRYAN SIREGAR', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '19970364', 'nama': 'RIO AFRIANDI', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '18960635', 'nama': 'ANGGA SAPUTRA', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '20951008', 'nama': 'MUHAMMAD RIZKY SEPTIAN', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '21960064', 'nama': 'FARIZ NURTIAWAN', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '20010092', 'nama': 'SAPRI WAHYUDI', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '19940087', 'nama': 'ADIMARNO SIHOMBING', 'jobdesk': 'Teknisi TSEL'},
      {'nik': '19960333', 'nama': 'MUHAMMAD DICKI ARMANDO', 'jobdesk': 'Teknisi MS Mitratel'},
      {'nik': '20010091', 'nama': 'RAMADHANI', 'jobdesk': 'Teknisi Provisioning WIBS'},
      {'nik': '20000078', 'nama': 'AJIE RIDWAN', 'jobdesk': 'Teknisi Provisioning WIBS'},
      {'nik': '18950755', 'nama': 'DENY SAPUTRA', 'jobdesk': 'Teknisi Provisioning WIBS'},
      {'nik': '19950325', 'nama': 'KURNIAWAN', 'jobdesk': 'Team Leader Operation B2B'},
      {'nik': '18920274', 'nama': 'RIKI MEIGAR', 'jobdesk': 'Teknisi FTM'},
      {'nik': '19880045', 'nama': 'YAHYA SUHENDRA TARIGAN', 'jobdesk': 'Teknisi FTM'},
      {'nik': '22980145', 'nama': 'KEVIN KURNIAWAN', 'jobdesk': 'Teknisi Patroli Aset'},
      {'nik': '24790001', 'nama': 'UNDIRA', 'jobdesk': 'Teknisi Patroli Aset'},
      {'nik': '18950849', 'nama': 'DEVI SETIAWATI', 'jobdesk': 'Helpdesk NE'},
      {'nik': '22000100', 'nama': 'MEYZA BAROKAH', 'jobdesk': 'Teknisi NE'},
      {'nik': '18940507', 'nama': 'LEVI PRAHARA', 'jobdesk': 'Teknisi NE'},
      {'nik': '20940895', 'nama': 'PUSPA SARI', 'jobdesk': 'Logic On Desk'},
      {'nik': '21990087', 'nama': 'MUHAMMAD REZEKI', 'jobdesk': 'Logic On Desk'},
      {'nik': '20980939', 'nama': 'PUJI MARSELA', 'jobdesk': 'Staff Corrective Maintenance & QE'},
      {'nik': '20931008', 'nama': 'MUHAMMAH LEO', 'jobdesk': 'Teknisi Corrective Maintenance & QE'},
      {'nik': '20961124', 'nama': 'RAKHMAD ARMAYUDA', 'jobdesk': 'Teknisi Corrective Maintenance & QE'},
      {'nik': '19970013', 'nama': 'FATHQUL HADI', 'jobdesk': 'Teknisi Corrective Maintenance & QE'},
      {'nik': '916406', 'nama': 'WAHYU PURWANTO', 'jobdesk': 'Head Of Service Area'},
      {'nik': '17910541', 'nama': 'YOHANNES EKA PRATOMO', 'jobdesk': 'Officer 3 Service Area'},
      {'nik': '87240009', 'nama': 'ARI ARSUKARA', 'jobdesk': 'Korlap B2C'},
      {'nik': '21980062', 'nama': 'YOGIE SAPUTRA', 'jobdesk': 'Staff B2C'},
      {'nik': '18950484', 'nama': 'SUNARTI', 'jobdesk': 'Helpdesk B2C'},
      {'nik': '20951009', 'nama': 'EDIANTO', 'jobdesk': 'Korlap B2C'},
      {'nik': '19930012', 'nama': 'AYU WIDYA ASTUTI', 'jobdesk': 'Helpdesk B2C'},
      {'nik': '20990229', 'nama': 'RIZKI ADITYA', 'jobdesk': 'Teknisi B2C'},
      {'nik': '93240024', 'nama': 'DESRA GASFAN', 'jobdesk': 'Korlap B2C'},
      {'nik': '22960122', 'nama': 'JEKI KURNIA', 'jobdesk': 'Teknisi Wilsus'},
      {'nik': '22040017', 'nama': 'ANDRIAN FERNANDO', 'jobdesk': 'Teknisi Wilsus'},
      {'nik': '22010126', 'nama': 'ALAMSYAH', 'jobdesk': 'Teknisi Wilsus'},
      {'nik': '20990126', 'nama': 'ERFINDA TERUNA JAYA', 'jobdesk': 'Teknisi Wilsus'},
      {'nik': '22980078', 'nama': 'MUHAMMAD ALI REZA', 'jobdesk': 'Teknisi Wilsus'},
      {'nik': '25000263', 'nama': 'ZWELA NOVARIO', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25980245', 'nama': 'DENI YULIANTO', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25930152', 'nama': 'GUSMAWAN', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25020253', 'nama': 'RENDI ANDI SUPUTRA', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25940169', 'nama': 'GAMTHA MUHAMMAD IKHTIARSA', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25050148', 'nama': 'HERU PRANATA', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25030254', 'nama': 'CAHYA TRI HARINOWO', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25040175', 'nama': 'ABANG HAFIZ FATURRAHMAN', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25020252', 'nama': 'JUNANDAR', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25010239', 'nama': 'REFAN FERDIAN', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25990247', 'nama': 'DENI ULMAN', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25050147', 'nama': 'JUANDA', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25000262', 'nama': 'EKA SAPUTRA', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25000257', 'nama': 'ADITYA PRASETYO', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25020249', 'nama': 'RIZALDI GIMASTIAR', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25000258', 'nama': 'MOHAMMAD ABDUL AZIES', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25050144', 'nama': 'MUHAMMAD REZA', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25000259', 'nama': 'RESKI PUTRA', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25050145', 'nama': 'RIZKY RAHMADANI', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25040174', 'nama': 'JANUAR EPENDI', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25970215', 'nama': 'SUKRI', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25060166', 'nama': 'ALDI', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25060167', 'nama': 'KAKA AGUSTIAR', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25050143', 'nama': 'RAFDI REYHAN MAHSYA', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25000256', 'nama': 'MUHAMMAD IQBAL ROMADHAN', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25940168', 'nama': 'ARIS SUTIONO', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25950189', 'nama': 'ROZALI', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25880061', 'nama': 'EKO ALAMSYAH', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25790028', 'nama': 'AFRIZAL', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25000260', 'nama': 'JUKARDI AFRIYANSYAH', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25730022', 'nama': 'SUPRIYANTO', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25020251', 'nama': 'AKBAR PRAYOGI', 'jobdesk': 'Teknisi B2C Pangkalpinang'},
      {'nik': '25060168', 'nama': 'ZULIO EXCEL PRAMUDETA', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25030252', 'nama': 'REYHAN ABRAR', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25030253', 'nama': 'BIMA PRAMUDETA', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25970216', 'nama': 'RACHMAD HIDAYAT', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25060169', 'nama': 'ADIT PRASETIO', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
      {'nik': '25050146', 'nama': 'YUSUF MAZI', 'jobdesk': 'Teknisi Provisioning & Migrasi'},
    ];

    for (var data in dataPegawai) {
      batch.insert('pegawai', data);
    }
    await batch.commit(noResult: true);
  }

  // --- 1. Reset hanya tabel absensi (Data Pegawai aman) ---
  Future<void> resetAbsensiHanya() async {
    final db = await instance.database;
    await db.delete('absensi');
  }

  // --- 2. Reset Total (Hapus semua pegawai dan absen) ---
  Future<void> resetTotal() async {
    final db = await instance.database;
    await db.delete('absensi');
    await db.delete('pegawai');
  }

  // --- FITUR EXPORT EXCEL (Ambil semua data hari ini tanpa limit) ---
  Future<List<Map<String, dynamic>>> getLaporanAbsensiHariIni() async {
    final db = await instance.database;
    String tglHariIni = DateTime.now().toIso8601String().split('T')[0];

    return await db.rawQuery('''
      SELECT p.nik, p.nama, p.jobdesk,
      COALESCE(
        (SELECT a.status FROM absensi a 
         WHERE a.nik = p.nik AND a.tanggal = ? 
         ORDER BY a.id DESC LIMIT 1), 
         'BELUM ABSEN'
      ) as status
      FROM pegawai p
      ORDER BY p.nama ASC
    ''', [tglHariIni]);
  }

  // --- QUERY CANGGIH: PAGINATION, FILTER, SORTIR ---
  Future<List<Map<String, dynamic>>> getPegawaiPro({
    required int limit,
    required int offset,
    String search = "",
    String jobdesk = "",
    String sortBy = "nama_asc",
  }) async {
    final db = await instance.database;
    String tglHariIni = DateTime.now().toIso8601String().split('T')[0];

    // Logika Pengurutan
    String orderQuery = "p.nama ASC";
    if (sortBy == "nama_desc") orderQuery = "p.nama DESC";
    if (sortBy == "nik_asc") orderQuery = "p.nik ASC";

    // Logika Pencarian & Filter
    String whereClause = "WHERE 1=1";
    List<dynamic> args = [tglHariIni];
    
    if (search.isNotEmpty) {
      whereClause += " AND (p.nama LIKE ? OR p.nik LIKE ?)";
      args.add("%$search%");
      args.add("%$search%");
    }
    
    if (jobdesk.isNotEmpty && jobdesk != "Semua") {
      whereClause += " AND p.jobdesk LIKE ?";
      args.add("%$jobdesk%");
    }

    return await db.rawQuery('''
      SELECT p.nik, p.nama, p.jobdesk,
      (SELECT a.status FROM absensi a 
       WHERE a.nik = p.nik AND a.tanggal = ? 
       ORDER BY a.id DESC LIMIT 1) as status
      FROM pegawai p
      $whereClause
      ORDER BY $orderQuery
      LIMIT $limit OFFSET $offset
    ''', args);
  }

  // --- SIMPAN ABSENSI ---
  Future<void> simpanBatchAbsen(List<String> nics, String status) async {
    final db = await instance.database;
    final batch = db.batch();
    String tgl = DateTime.now().toIso8601String().split('T')[0];

    for (var nik in nics) {
      batch.insert('absensi', {
        'nik': nik, 
        'status': status, 
        'tanggal': tgl
      });
    }
    await batch.commit(noResult: true);
  }

  // --- TAMBAH PEGAWAI MANUAL ---
  Future<int> tambahPegawai(String nik, String nama, {String jobdesk = "-"}) async {
    final db = await instance.database;
    return await db.insert('pegawai', {
      'nik': nik, 
      'nama': nama, 
      'jobdesk': jobdesk
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}