import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import '../../models/expense.dart';
import '../../utils/formatters.dart';
import '../../theme/colors.dart';
import 'apple_button.dart';

class TransactionDetailsSheet extends StatefulWidget {
  final Expense expense;
  final String currency;

  const TransactionDetailsSheet({super.key, required this.expense, required this.currency});

  @override
  State<TransactionDetailsSheet> createState() => _TransactionDetailsSheetState();
}

class _TransactionDetailsSheetState extends State<TransactionDetailsSheet> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (widget.expense.voiceMemoPath != null) {
        await _player.play(DeviceFileSource(widget.expense.voiceMemoPath!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.expense;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5, width: 40, 
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white10 : Colors.black12), 
                  borderRadius: BorderRadius.circular(10)
                )
              )
            ),
            const SizedBox(height: 25),
            
            Center(
              child: Text(
                Formatters.currency(e.amount, widget.currency),
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: (isDark ? Colors.white : Colors.black), letterSpacing: -1),
              ),
            ),
            Center(
              child: Text(
                e.category,
                style: const TextStyle(color: AppColors.textDim, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 30),
            
            _detailRow("Date", "${e.date.day}/${e.date.month}/${e.date.year}", LucideIcons.calendar, isDark),
            if (e.note.isNotEmpty) _detailRow("Note", e.note, LucideIcons.alignLeft, isDark),
            _detailRow("Funding Source", e.fundingSource == 'allowance' ? 'Monthly Budget' : (e.fundingSource == 'resources' ? 'Available Resources' : 'None'), LucideIcons.wallet, isDark),
            
            const SizedBox(height: 20),
            if (e.voiceMemoPath != null || e.receiptImagePath != null)
               Text("Attachments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: (isDark ? Colors.white : Colors.black))),
            const SizedBox(height: 10),
            
            if (e.voiceMemoPath != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: (isDark ? Colors.white10 : Colors.black12))),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: IconButton(
                        icon: Icon(_isPlaying ? LucideIcons.pause : LucideIcons.play, color: Theme.of(context).primaryColor),
                        onPressed: _toggleAudio,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Text("Voice Note", style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
  
            if (e.receiptImagePath != null)
               GestureDetector(
                 onTap: () {
                   showDialog(context: context, builder: (_) => Dialog(
                     backgroundColor: Colors.transparent,
                     insetPadding: EdgeInsets.zero,
                     child: GestureDetector(
                       onTap: () => Navigator.pop(context),
                       child: InteractiveViewer(
                         child: Image.file(File(e.receiptImagePath!))
                       ),
                     ),
                   ));
                 },
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(20),
                   child: Image.file(
                     File(e.receiptImagePath!),
                     width: double.infinity,
                     height: 200,
                     fit: BoxFit.cover,
                     errorBuilder: (ctx, err, stack) => Container(
                       height: 100,
                       color: Theme.of(context).cardColor,
                       child: const Center(child: Text("Receipt Image Not Found", style: TextStyle(color: AppColors.textDim))),
                     ),
                   ),
                 ),
               ),
               
            const SizedBox(height: 30),
            AppleButton(label: "Close", onTap: () => Navigator.pop(context)),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
  
  Widget _detailRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textDim),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: (isDark ? Colors.white : Colors.black))),
        ],
      ),
    );
  }
}
