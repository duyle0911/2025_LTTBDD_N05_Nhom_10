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

    return Scaffold(
      appBar: AppBar(
        title: Text(t.about_title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                "assets/images/team_banner.png",
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t.about_members_title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final member = members[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          member["image"]!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          member["name"]!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
