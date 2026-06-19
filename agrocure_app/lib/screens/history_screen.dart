import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/botanica_theme.dart';
import '../models/prediction.dart';
import '../services/history_service.dart';
import '../widgets/buttons.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Prediction> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await HistoryService.load();
    if (!mounted) return;
    setState(() {
      _history = h;
      _loading = false;
    });
  }

  Future<void> _clear() async {
    await HistoryService.clear();
    setState(() => _history = []);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
              child: Row(
                children: [
                  CircleIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Text('History', style: Serif.style(18, c.ink)),
                  const Spacer(),
                  if (_history.isNotEmpty)
                    GestureDetector(
                      onTap: _clear,
                      child: Text('Clear',
                          style: TextStyle(color: c.terra, fontSize: 13)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: c.sage, strokeWidth: 2.5))
                  : _history.isEmpty
                      ? _empty(c)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                          itemCount: _history.length,
                          itemBuilder: (_, i) => _item(c, _history[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BotanicaColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined, color: c.line, size: 56),
          const SizedBox(height: 16),
          Text('No scans yet', style: Serif.style(20, c.ink, italic: true)),
          const SizedBox(height: 8),
          Text('Your diagnoses will appear here',
              style: TextStyle(color: c.ink3, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _item(BotanicaColors c, Prediction p) {
    final healthy = p.disease.toLowerCase().contains('healthy');
    final color = healthy ? c.sage : c.terra;
    final file = File(p.imagePath);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              width: 46,
              height: 46,
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover)
                  : Container(
                      color: c.surf2,
                      child: Icon(Icons.eco_outlined, color: color, size: 20),
                    ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.plant,
                    style: TextStyle(
                        color: c.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(p.disease, style: TextStyle(color: c.ink3, fontSize: 12)),
                const SizedBox(height: 2),
                Text(_date(p.timestamp),
                    style: TextStyle(color: c.ink3, fontSize: 10)),
              ],
            ),
          ),
          Text(p.confidencePct, style: Serif.style(15, color)),
        ],
      ),
    );
  }

  String _date(DateTime t) =>
      '${t.day}/${t.month}/${t.year}';
}
