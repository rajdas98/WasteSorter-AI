import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CertificateScreen extends StatelessWidget {
  const CertificateScreen({
    super.key,
    required this.userName,
    required this.totalKg,
    required this.completionDate,
  });

  final String userName;
  final double totalKg;
  final DateTime completionDate;

  @override
  Widget build(BuildContext context) {
    final String dateText =
        '${completionDate.day.toString().padLeft(2, '0')}/${completionDate.month.toString().padLeft(2, '0')}/${completionDate.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Eco-Champion Certificate')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFFFFFCEB),
                      Color(0xFFEFFFF7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFB88A16),
                    width: 3,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF169A6F).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Certificate of Achievement',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D3B2E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Presented to',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF127C5B),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'For diverting ${totalKg.toStringAsFixed(1)} kg of waste from landfills.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.4,
                          color: Color(0xFF1E3D34),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF169A6F).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF169A6F),
                          ),
                        ),
                        child: const Column(
                          children: <Widget>[
                            Text(
                              'WasteSorter AI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0E3D2F),
                              ),
                            ),
                            Text(
                              'Digital Signature',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Date: $dateText',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0E3D2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final String shareText =
                      'I earned my Eco-Champion Certificate on WasteSorter AI! '
                      'I have diverted ${totalKg.toStringAsFixed(1)} kg waste from landfills.';
                  await Share.share(
                    shareText,
                    subject: 'My WasteSorter AI Certificate',
                  );
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share Certificate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
