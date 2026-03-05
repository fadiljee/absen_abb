import 'package:flutter/material.dart';

class Pegawai {
  final String nik;
  final String nama;
  final String jobdesk;
  String status;

  Pegawai({
    required this.nik,
    required this.nama,
    required this.jobdesk,
    this.status = "BELUM ABSEN",
  });

  // --- MENGUBAH MAP DARI SQLITE MENJADI OBJECT PEGAWAI ---
  factory Pegawai.fromMap(Map<String, dynamic> map) {
    return Pegawai(
      nik: map['nik']?.toString() ?? '',
      nama: map['nama']?.toString() ?? '',
      jobdesk: map['jobdesk']?.toString() ?? '-',
      status: map['status'] ?? "BELUM ABSEN",
    );
  }

  // --- LOGIKA WARNA BERDASARKAN STATUS ABSENSI ---
  Color get statusColor {
    switch (status) {
      case 'M (MASUK)': 
        return Colors.green[700]!;
      case 'T (TERLAMBAT)': 
      case 'IT (IZIN TELAT)': 
        return Colors.orange[800]!;
      case 'S (SAKIT)': 
        return Colors.blue[700]!;
      case 'C (CUTI)': 
      case 'L (LIBUR)': 
        return Colors.purple[700]!;
      case 'TB (TIDAK BRIEFING)':
      case 'KM (KERJA MALAM)':
        return Colors.red[800]!;
      case 'PD (SPPD)':
        return Colors.teal[700]!;
      case 'SS (SHIFT SIANG)':
        return Colors.amber[900]!;
      default: 
        return Colors.grey[600]!; // Default untuk warna "BELUM ABSEN"
    }
  }
}