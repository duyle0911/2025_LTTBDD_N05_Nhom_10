import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;

    final members = [
      {"name": "Lê Đức Duy - 23010772", "image": "assets/images/trong.png"},
      {"name": "Nguyễn Văn Trọng - 23010817", "image": "assets/images/duy.png"},
    ];

    final tasks = <_Task>[
      _Task("Thu thập phân tích yêu cầu", "Viết tài liệu yêu cầu SRS",
          "Lê Đức Duy"),
      _Task("Thu thập phân tích yêu cầu", "Tìm hiểu các nhóm chức năng",
          "Nguyễn Văn Trọng"),
      _Task("Phân tích thiết kế hệ thống", "Thiết kế sơ đồ Use-case",
          "Lê Đức Duy"),
      _Task("Phân tích thiết kế hệ thống",
          "Thiết kế sơ đồ tuần tự các chức năng", ""),
      _Task("Phân tích thiết kế hệ thống",
          "Thiết kế sơ đồ hoạt động các chức năng", "Lê Đức Duy"),
      _Task("Phân tích thiết kế hệ thống", "Thiết kế giao diện", ""),
      _Task(
          "Triển khai giải pháp (Xây dựng phần mềm)",
          "Triển khai R1–R2: Đăng ký, đăng nhập, CRUD danh mục",
          "Nguyễn Văn Trọng"),
      _Task(
          "Triển khai giải pháp (Xây dựng phần mềm)",
          "Triển khai R3–R5: CRUD giao dịch, cập nhật số dư, dashboard/biểu đồ, quản lý ví",
          "Lê Đức Duy"),
      _Task("Kiểm thử & Đánh giá hệ thống", "Lập kế hoạch kiểm thử",
          "Lê Đức Duy"),
      _Task("Kiểm thử & Đánh giá hệ thống", "Kiểm thử giao diện", ""),
      _Task("Kiểm thử & Đánh giá hệ thống", "Kiểm thử tích hợp & chức năng",
          "Nguyễn Văn Trọng"),
      _Task("Kiểm thử & Đánh giá hệ thống", "Kiểm thử phi chức năng", ""),
      _Task("Báo cáo & Trình bày sản phẩm", "Chuẩn bị video demo",
          "Nguyễn Văn Trọng"),
      _Task("Báo cáo & Trình bày sản phẩm",
          "Tổng kết, viết báo cáo cuối, slide", "Lê Đức Duy"),
    ];

    final bgTop = const Color(0xFF34C1F5);
    final bgMid = const Color(0xFF5E7BEF);
    final bgBot = const Color(0xFF1ED6A3);

    return Scaffold(
      appBar: AppBar(title: Text(t.about_title)),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgMid, bgBot],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  "assets/images/team_banner.png",
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: t.about_members_title,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final m = members[index];
                    return _MemberTile(
                        imagePath: m["image"]!, name: m["name"]!);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: "Phân công công việc",
                child: _SplitAssignmentTable(
                  tasks: tasks,
                  leftName: "Lê Đức Duy",
                  rightName: "Nguyễn Văn Trọng",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(.6), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String imagePath;
  final String name;
  const _MemberTile({required this.imagePath, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(imagePath,
                width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Task {
  final String group;
  final String desc;
  final String who;
  _Task(this.group, this.desc, this.who);
}

class _SplitAssignmentTable extends StatelessWidget {
  final List<_Task> tasks;
  final String leftName;
  final String rightName;
  const _SplitAssignmentTable({
    required this.tasks,
    required this.leftName,
    required this.rightName,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <String, Map<String, List<String>>>{};
    for (final t in tasks) {
      groups.putIfAbsent(t.group, () => {leftName: [], rightName: []});
      if (t.who == leftName) {
        groups[t.group]![leftName]!.add(t.desc);
      } else if (t.who == rightName) {
        groups[t.group]![rightName]!.add(t.desc);
      }
    }

    String bullets(List<String> items) =>
        items.isEmpty ? "—" : items.map((e) => "• $e").join("\n");

    final headerStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(fontWeight: FontWeight.w800);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: headerStyle,
        dataTextStyle: const TextStyle(fontSize: 13),
        columnSpacing: 22,
        headingRowColor: WidgetStateProperty.all(Colors.black.withOpacity(.04)),
        border: TableBorder.symmetric(
          inside: const BorderSide(color: Color(0xFFE6E6E6)),
          outside: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        columns: [
          const DataColumn(label: Text('Nhóm công việc')),
          DataColumn(label: Text(leftName)),
          DataColumn(label: Text(rightName)),
        ],
        rows: groups.entries.map((e) {
          final left = bullets(e.value[leftName] ?? []);
          final right = bullets(e.value[rightName] ?? []);
          return DataRow(cells: [
            DataCell(SizedBox(width: 240, child: Text(e.key))),
            DataCell(SizedBox(width: 320, child: Text(left))),
            DataCell(SizedBox(width: 320, child: Text(right))),
          ]);
        }).toList(),
      ),
    );
  }
}
