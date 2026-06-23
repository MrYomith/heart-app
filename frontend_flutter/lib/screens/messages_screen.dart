import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/message.dart';
import '../utils/responsive.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _activeCategory = 'All';
  ChatMessage? _selected;

  final List<String> _categories = ['All', 'Appointments', 'Lab Results', 'Prescriptions', 'Education', 'Alerts', 'Support'];

  List<ChatMessage> get _filtered {
    if (_activeCategory == 'All') return messages;
    return messages.where((m) => m.category == _activeCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isTablet(context) || Responsive.isFoldable(context);
    return isWide ? _buildWideLayout(context) : _buildPhoneLayout(context);
  }

  // ── Phone layout ──────────────────────────────────────────
  Widget _buildPhoneLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _appBar(),
      body: Column(
        children: [
          _careTeamBanner(context),
          _categoryChips(),
          Expanded(child: _messageList(context)),
          if (_selected != null) _detailPane(context),
          _smartCheckIn(context),
        ],
      ),
    );
  }

  // ── Tablet master-detail layout ───────────────────────────
  Widget _buildWideLayout(BuildContext context) {
    final listWidth = Responsive.isLarge(context) ? 380.0 : 320.0;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _appBar(),
      body: Row(
        children: [
          // Master list panel
          Container(
            width: listWidth,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                _careTeamBanner(context),
                _categoryChips(),
                Expanded(child: _messageList(context)),
                _smartCheckIn(context),
              ],
            ),
          ),
          // Detail panel
          Expanded(
            child: _selected != null
                ? _detailPanelFull(context)
                : _emptyDetail(context),
          ),
        ],
      ),
    );
  }

  AppBar _appBar() => AppBar(
    backgroundColor: AppColors.bgCard,
    automaticallyImplyLeading: false,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Messages', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        Text('Your care team communication', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(Icons.edit_rounded, color: AppColors.textDark, size: 22),
      ),
    ],
  );

  Widget _careTeamBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      color: AppColors.bgBanner,
      child: Row(
        children: [
          _Avatar('👩‍⚕️'),
          Transform.translate(offset: const Offset(-10, 0), child: _Avatar('👨‍⚕️')),
          Transform.translate(offset: const Offset(-20, 0), child: _Avatar('👩‍🔬')),
          const SizedBox(width: 4),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Care Team', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text('3 specialists · ~2h response', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
            child: Text('+ New', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _categoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final active = cat == _activeCategory;
          return GestureDetector(
            onTap: () => setState(() => _activeCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: active ? AppColors.teal : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? AppColors.teal : AppColors.border),
              ),
              child: Text(cat, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textMedium)),
            ),
          );
        },
      ),
    );
  }

  Widget _messageList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _filtered.length,
      itemBuilder: (context, i) {
        final msg = _filtered[i];
        return GestureDetector(
          onTap: () => setState(() => _selected = msg),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: _selected?.id == msg.id ? Border.all(color: AppColors.teal, width: 1.5) : null,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tealLight),
                  child: Center(child: Text(msg.avatar, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(msg.sender, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        Text(msg.sentAt, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight)),
                      ],
                    ),
                    Text(msg.subject, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal)),
                    Text(msg.preview, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                ),
                if (!msg.isRead)
                  Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.only(top: 4, left: 4),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Phone inline detail pane
  Widget _detailPane(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(_selected!.subject, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark))),
          GestureDetector(onTap: () => setState(() => _selected = null), child: const Icon(Icons.close, size: 18, color: AppColors.textLight)),
        ]),
        Text('From: ${_selected!.sender}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
        const SizedBox(height: 8),
        Text(_selected!.body.isNotEmpty ? _selected!.body : _selected!.preview, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark, height: 1.5)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () {}, child: Text('Reply', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.teal))),
        ]),
      ]),
    );
  }

  // Tablet full detail panel
  Widget _detailPanelFull(BuildContext context) {
    final pad = Responsive.hp(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tealLight),
            child: Center(child: Text(_selected!.avatar, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_selected!.sender, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text(_selected!.sentAt, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight)),
          ])),
          GestureDetector(
            onTap: () => setState(() => _selected = null),
            child: const Icon(Icons.close_rounded, color: AppColors.textLight),
          ),
        ]),
        const SizedBox(height: 16),
        Text(_selected!.subject, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.teal)),
        const SizedBox(height: 12),
        Container(height: 1, color: AppColors.border),
        const SizedBox(height: 16),
        Text(
          _selected!.body.isNotEmpty ? _selected!.body : _selected!.preview,
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textDark, height: 1.7),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text('Reply', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
            child: Text('Archive', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
          ),
        ]),
      ]),
    );
  }

  Widget _emptyDetail(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('💬', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text('Select a message to read', style: GoogleFonts.inter(fontSize: 15, color: AppColors.textMedium)),
      ]),
    );
  }

  Widget _smartCheckIn(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        const Text('📋', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Smart Check-in', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.tealDark)),
          Text('Send your daily vitals to your care team', style: GoogleFonts.inter(fontSize: 11, color: AppColors.teal)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(20)),
          child: Text('Send', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ]),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String emoji;
  const _Avatar(this.emoji);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tealLight, border: Border.all(color: Colors.white, width: 2)),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
    );
  }
}
