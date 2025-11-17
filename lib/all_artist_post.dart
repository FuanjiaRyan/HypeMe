import 'package:flutter/material.dart';
import 'dart:math' as math;

class AllArtistPostScreen extends StatefulWidget {
  final bool? _showBackButton;
  
  const AllArtistPostScreen({
    super.key,
    bool? showBackButton,
  }) : _showBackButton = showBackButton;
  
  bool get showBackButton => _showBackButton ?? true;

  @override
  State<AllArtistPostScreen> createState() => _AllArtistPostScreenState();
}

class _AllArtistPostScreenState extends State<AllArtistPostScreen>
    with TickerProviderStateMixin {
  bool _contributeModeEnabled = true;
  late AnimationController _visualizerController;

  @override
  void initState() {
    super.initState();
    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _visualizerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Visualizer Background
            Center(
              child: AnimatedBuilder(
                animation: _visualizerController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                    painter: VisualizerPainter(
                      animationValue: _visualizerController.value,
                    ),
                  );
                },
              ),
            ),
            // Content Overlay
            Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.showBackButton
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            )
                          : const SizedBox(width: 48), // Spacer to center title
                      const Text(
                        'Synthwave Dreams',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '0.0012 Tokens',
                        style: TextStyle(
                          color: Color(0xFF00B4FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Central Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(Icons.refresh),
                    const SizedBox(width: 40),
                    _buildControlButton(Icons.skip_next),
                  ],
                ),
                const Spacer(),
                // Bottom Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Engagement Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildEngagementItem(
                            icon: Icons.favorite_outline,
                            count: '1.2k',
                          ),
                          const SizedBox(width: 24),
                          _buildEngagementItem(
                            icon: Icons.comment_outlined,
                            count: '256',
                          ),
                          const SizedBox(width: 24),
                          _buildEngagementItem(
                            icon: Icons.share_outlined,
                            count: '98',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Contribute Mode Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Text(
                                    'Contribute Mode',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.grey[400],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Earn more rewards.',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: _contributeModeEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _contributeModeEnabled = value;
                                });
                              },
                              activeColor: const Color(0xFF00B4FF),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Artist Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[800],
                                border: Border.all(
                                  color: const Color(0xFF00B4FF),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '@CyberVibes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Original Audio - Neon Grid',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Follow',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: (Colors.grey[900] ?? Colors.grey).withOpacity(0.7),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: () {},
      ),
    );
  }

  Widget _buildEngagementItem({
    required IconData icon,
    required String count,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// Custom Painter for Visualizer
class VisualizerPainter extends CustomPainter {
  final double animationValue;

  VisualizerPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.6;

    // Draw swirling tunnel effect
    for (int i = 0; i < 50; i++) {
      final progress = (i / 50) + (animationValue * 0.1);
      final radius = maxRadius * (1 - progress * 0.8);
      final angle = (progress * math.pi * 4) + (animationValue * math.pi * 2);

      if (radius < 20) continue;

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      // Color gradient from center to edge
      final colorProgress = i / 50;
      Color color;
      if (colorProgress < 0.25) {
        color = Color.lerp(
          const Color(0xFF00B4FF),
          const Color(0xFF00FFFF),
          colorProgress * 4,
        )!;
      } else if (colorProgress < 0.5) {
        color = Color.lerp(
          const Color(0xFF00FFFF),
          const Color(0xFFFFFF00),
          (colorProgress - 0.25) * 4,
        )!;
      } else if (colorProgress < 0.75) {
        color = Color.lerp(
          const Color(0xFFFFFF00),
          const Color(0xFFFF6B35),
          (colorProgress - 0.5) * 4,
        )!;
      } else {
        color = Color.lerp(
          const Color(0xFFFF6B35),
          const Color(0xFF00B4FF),
          (colorProgress - 0.75) * 4,
        )!;
      }

      final paint = Paint()
        ..color = color.withOpacity(0.6)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // Draw spiral segments
      final nextAngle = angle + 0.1;
      final nextX = center.dx + radius * math.cos(nextAngle);
      final nextY = center.dy + radius * math.sin(nextAngle);

      canvas.drawLine(Offset(x, y), Offset(nextX, nextY), paint);
    }

    // Draw central black void
    final voidPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: maxRadius * 0.3,
        height: maxRadius * 0.2,
      ),
      voidPaint,
    );
  }

  @override
  bool shouldRepaint(VisualizerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

