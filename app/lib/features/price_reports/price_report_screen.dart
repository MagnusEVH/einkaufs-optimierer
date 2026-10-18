// app/lib/features/price_reports/price_report_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/store.dart';
import '../../core/services/supabase_service.dart';

class PriceReportItem {
  final String id;
  final SupermarketChain chain;
  final String reportType; // 'Kassenbon' or 'Regalschild'
  final String dateString;
  final String status;
  final String? note;

  const PriceReportItem({
    required this.id,
    required this.chain,
    required this.reportType,
    required this.dateString,
    required this.status,
    this.note,
  });
}

class PriceReportScreen extends StatefulWidget {
  const PriceReportScreen({super.key});

  @override
  State<PriceReportScreen> createState() => _PriceReportScreenState();
}

class _PriceReportScreenState extends State<PriceReportScreen> {
  SupermarketChain _selectedChain = SupermarketChain.lidl;
  String _reportType = 'Kassenbon';
  final TextEditingController _noteController = TextEditingController();
  bool _hasSelectedPhoto = false;
  String _mockPhotoName = '';
  bool _isUploading = false;

  final List<PriceReportItem> _history = [
    const PriceReportItem(
      id: 'rep-001',
      chain: SupermarketChain.rewe,
      reportType: 'Kassenbon',
      dateString: 'Heute, 17:45',
      status: 'pending_ocr',
      note: 'Wocheneinkauf 14 Artikel',
    ),
    const PriceReportItem(
      id: 'rep-002',
      chain: SupermarketChain.netto,
      reportType: 'Regalschild',
      dateString: 'Gestern, 12:10',
      status: 'pending_ocr',
      note: 'Heidelbeeren Aktionspreis',
    ),
  ];

  void _simulatePhotoCapture() {
    setState(() {
      _hasSelectedPhoto = true;
      _mockPhotoName = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Foto aufgenommen: $_mockPhotoName'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_hasSelectedPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte nimm zuerst ein Foto auf oder wähle eines aus.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Prepare metadata for Supabase Storage and database
    await Future.delayed(const Duration(milliseconds: 600)); // Network simulation

    final newReport = PriceReportItem(
      id: 'rep-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      chain: _selectedChain,
      reportType: _reportType,
      dateString: 'Gerade eben',
      status: 'pending_ocr',
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );

    setState(() {
      _history.insert(0, newReport);
      _hasSelectedPhoto = false;
      _mockPhotoName = '';
      _noteController.clear();
      _isUploading = false;
    });

    // In-App Notification Modal requested by user
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.check_circle_outline, color: Colors.teal, size: 48),
          title: const Text('Foto erfolgreich gespeichert!', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Dein Beleg wurde sicher archiviert.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.teal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Die automatische KI-Erkennung wird zeitnah freigeschaltet. Deine Einreichung wird automatisch verarbeitet, sobald das Modell aktiv ist.',
                        style: TextStyle(fontSize: 12, color: Colors.teal.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Verstanden'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preise & Bons melden', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Explanation Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.white, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foto-Preisreport (Community)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fotografiere Kassenbons oder Regalschilder. Die Fotos werden archiviert und stehen für die KI-Erkennung bereit.',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Upload Form
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. Beleg-Art & Supermarkt wählen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _reportType,
                          decoration: InputDecoration(
                            labelText: 'Typ',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Kassenbon', child: Text('Kassenbon')),
                            DropdownMenuItem(value: 'Regalschild', child: Text('Regalschild')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _reportType = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<SupermarketChain>(
                          value: _selectedChain,
                          decoration: InputDecoration(
                            labelText: 'Filiale',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: SupermarketChain.values.map((chain) {
                            return DropdownMenuItem(
                              value: chain,
                              child: Text(chain.displayName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedChain = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('2. Foto aufnehmen / hochladen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),

                  // Photo Capture Box
                  InkWell(
                    onTap: _simulatePhotoCapture,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        color: _hasSelectedPhoto ? Colors.teal.shade50 : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _hasSelectedPhoto ? Colors.teal : Colors.grey.shade400,
                          style: BorderStyle.solid,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasSelectedPhoto ? Icons.check_circle : Icons.camera_alt_outlined,
                              size: 40,
                              color: _hasSelectedPhoto ? Colors.teal : Colors.grey.shade700,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _hasSelectedPhoto ? 'Foto bereit: $_mockPhotoName' : 'Hier tippen für Kamera / Galerie',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _hasSelectedPhoto ? Colors.teal.shade900 : Colors.grey.shade700,
                              ),
                            ),
                            if (_hasSelectedPhoto)
                              const Text('Tippen zum Ändern', style: TextStyle(fontSize: 11, color: Colors.teal)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Optional Note
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Optionale Notiz (z. B. 3 Artikel im Angebot)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isUploading ? null : _submitReport,
                      icon: _isUploading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        _isUploading ? 'Wird gespeichert...' : 'Report jetzt speichern',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submitted Reports History
          Row(
            children: [
              const Icon(Icons.history, color: Colors.teal),
              const SizedBox(width: 8),
              Text('Eingereichte Belege (${_history.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),

          ..._history.map((rep) => Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade50,
                    child: const Icon(Icons.document_scanner_outlined, color: Colors.teal),
                  ),
                  title: Text('${rep.chain.displayName} - ${rep.reportType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${rep.dateString}${rep.note != null ? " • ${rep.note}" : ""}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: const Text(
                      'Erkennung vorbereitet',
                      style: TextStyle(color: Colors.brown, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
