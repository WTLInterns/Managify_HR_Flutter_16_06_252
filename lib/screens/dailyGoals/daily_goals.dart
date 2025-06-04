import 'package:flutter/material.dart';
import 'dart:math' as math;

class DailyGoalsScreen extends StatefulWidget {
  @override
  _DailyGoalsScreenState createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen>
    with TickerProviderStateMixin {
  late AnimationController _walkController;
  late AnimationController _ringController;
  late Animation<double> _walkAnimation;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();

    // Walking animation controller
    _walkController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Added reverse for smoother walk cycle

    _walkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _walkController,
      curve: Curves.easeInOutSine, // Changed curve for a more natural swing
    ));

    // Ring animation controller
    _ringController = AnimationController(
      duration: const Duration(seconds: 4), // Increased duration for a slower, more graceful rotation
      vsync: this,
    )..repeat();

    _ringAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _ringController,
      curve: Curves.linear, // Linear for continuous rotation
    ));
  }

  @override
  void dispose() {
    _walkController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a gradient background for a more attractive look
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A1B3A), // Dark purple-blue
              Color(0xFF0F102B), // Even darker purple-blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // Increased padding
            child: Column(
              children: [
                // Daily Goal Section
                Container(
                  padding: const EdgeInsets.all(24), // Increased padding
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2B4A).withOpacity(0.8), // Slightly transparent
                    borderRadius: BorderRadius.circular(25), // More rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DAILY GOAL',
                        style: TextStyle(
                          color: Color(0xFF81D4FA), // Lighter blue for better contrast
                          fontSize: 16, // Slightly larger
                          fontWeight: FontWeight.w700, // Bolder
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '87%',
                        style: TextStyle(
                          color: Color(0xFF81D4FA),
                          fontSize: 64, // Larger font size
                          fontWeight: FontWeight.w900, // Extra bold
                          height: 1, // Adjust line height
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Progress towards your daily target',
                        style: TextStyle(
                          color: Colors.white70, // Softer white
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40), // Increased spacing

                // Walking Boy with Animated Rings
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated Rings
                      AnimatedBuilder(
                        animation: _ringAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(300, 300), // Slightly larger rings
                            painter: RingPainter(_ringAnimation.value),
                          );
                        },
                      ),

                      // Walking Boy Animation
                      AnimatedBuilder(
                        animation: _walkAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              math.sin(_walkAnimation.value * 2 * math.pi) * 5, // More pronounced side-to-side
                              math.sin(_walkAnimation.value * 4 * math.pi) * 3, // More pronounced up-down
                            ),
                            child: WalkingBoy(walkPhase: _walkAnimation.value),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40), // Increased spacing

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly spaced
                  children: [
                    StatCard(
                      icon: Icons.local_fire_department_rounded, // Rounded icon
                      value: '946',
                      label: 'Calories',
                      color: const Color(0xFFFF8A65), // Warm orange
                    ),
                    StatCard(
                      icon: Icons.directions_walk_rounded, // Rounded icon
                      value: '2639',
                      label: 'Steps', // Capitalized for consistency
                      color: const Color(0xFF81D4FA), // Light blue
                    ),
                    StatCard(
                      icon: Icons.bedtime_rounded, // Rounded icon
                      value: '6h',
                      label: 'Sleep', // More descriptive label
                      color: const Color(0xFFC5E1A5), // Light green
                    ),
                  ],
                ),

                const SizedBox(height: 40), // Increased spacing

                // Bottom Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), // Adjusted padding
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2B4A).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60, // Larger icon container
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient( // Gradient for the icon background
                            colors: [Color(0xFFFF8A65), Color(0xFFF4511E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30), // Perfect circle
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF8A65).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_pizza_rounded, // Rounded icon
                          color: Colors.white,
                          size: 32, // Larger icon
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded( // Use Expanded to take available space
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'A Simple way to',
                              style: TextStyle(
                                color: Colors.white, // White text
                                fontSize: 18, // Larger font
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'stay healthy',
                              style: TextStyle(
                                color: Colors.white70, // Softer white
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded, // More modern arrow icon
                        color: Color(0xFF81D4FA), // Blue color
                        size: 24,
                      ),
                    ],
                  ),
                ),

                const Spacer(), // Pushes content to the top

                // Bottom Navigation
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2B4A).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30), // Highly rounded
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Column(
                        children: [
                          Icon(Icons.show_chart_rounded, color: Color(0xFF81D4FA), size: 28),
                          SizedBox(height: 4),
                          Text('Progress', style: TextStyle(color: Color(0xFF81D4FA), fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.access_time_rounded, color: Colors.white54, size: 28),
                          SizedBox(height: 4),
                          Text('History', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.person_outline_rounded, color: Colors.white54, size: 28),
                          SizedBox(height: 4),
                          Text('Profile', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WalkingBoy extends StatelessWidget {
  final double walkPhase;

  const WalkingBoy({Key? key, required this.walkPhase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(120, 140), // Slightly larger canvas for the boy
      painter: WalkingBigManPainter(walkPhase),
    );
  }
}

class WalkingBigManPainter extends CustomPainter {
  final double walkPhase;

  WalkingBigManPainter(this.walkPhase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2 + 10); // Adjusted center for better proportion

    // Shadow below the character
    paint.color = Colors.black.withOpacity(0.2);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 70), width: 60, height: 15),
      paint,
    );

    // Body (shirt)
    paint.color = const Color(0xFF42A5F5); // Blue shirt
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 60, height: 90), // Taller body
        const Radius.circular(15), // More rounded
      ),
      paint,
    );

    // Head
    paint.color = const Color(0xFFFFE0B2); // Skin tone
    canvas.drawCircle(Offset(center.dx, center.dy - 65), 30, paint); // Larger head

    // Hair (more stylized)
    paint.color = const Color(0xFF4E342E); // Dark brown hair
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy - 80), width: 55, height: 40),
        const Radius.circular(20),
      ),
      paint,
    );
    canvas.drawCircle(Offset(center.dx - 15, center.dy - 75), 10, paint); // Side hair
    canvas.drawCircle(Offset(center.dx + 15, center.dy - 75), 10, paint); // Side hair

    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(Offset(center.dx - 10, center.dy - 70), 4, paint);
    canvas.drawCircle(Offset(center.dx + 10, center.dy - 70), 4, paint);

    // Smile
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.color = Colors.black;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 55), width: 25, height: 15),
      0,
      math.pi,
      false,
      paint,
    );

    paint.style = PaintingStyle.fill;

    // Arms (swinging)
    paint.color = const Color(0xFFFFE0B2); // Skin tone
    double armSwing = math.sin(walkPhase * 2 * math.pi) * 30; // More swing

    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - 40, center.dy - 10 + armSwing),
          width: 15, // Wider arm
          height: 50, // Longer arm
        ),
        const Radius.circular(8),
      ),
      paint,
    );

    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 40, center.dy - 10 - armSwing),
          width: 15,
          height: 50,
        ),
        const Radius.circular(8),
      ),
      paint,
    );

    // Pants
    paint.color = const Color(0xFF1976D2); // Darker blue pants
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 45), width: 55, height: 60), // Taller pants
        const Radius.circular(10),
      ),
      paint,
    );

    // Legs
    paint.color = const Color(0xFFFFE0B2); // Skin tone
    double legSwing = math.sin(walkPhase * 2 * math.pi) * 35; // More swing

    // Left leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - 18, center.dy + 85 + legSwing),
          width: 15, // Wider leg
          height: 50, // Longer leg
        ),
        const Radius.circular(8),
      ),
      paint,
    );

    // Right leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 18, center.dy + 85 - legSwing),
          width: 15,
          height: 50,
        ),
        const Radius.circular(8),
      ),
      paint,
    );

    // Shoes
    paint.color = Colors.black;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - 18, center.dy + 115 + legSwing / 2),
          width: 25, // Wider shoe
          height: 12, // Taller shoe
        ),
        const Radius.circular(6),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 18, center.dy + 115 - legSwing / 2),
          width: 25,
          height: 12,
        ),
        const Radius.circular(6),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RingPainter extends CustomPainter {
  final double rotation;

  RingPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Outer ring (Blue)
    paint.shader = const LinearGradient(
      colors: [Color(0xFF2196F3), Color(0xFF0D47A1)], // Blue gradient
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    paint.strokeWidth = 10; // Thicker
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      rotation,
      math.pi * 1.6, // Slightly more than 1.5pi
      false,
      paint,
    );

    // Middle ring (Orange)
    paint.shader = const LinearGradient(
      colors: [Color(0xFFFF8A65), Color(0xFFE64A19)], // Orange gradient
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.4));
    paint.strokeWidth = 8; // Slightly thinner
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width * 0.8, height: size.height * 0.8),
      rotation + math.pi / 2, // Different starting point
      math.pi * 1.3, // Slightly more than 1.2pi
      false,
      paint,
    );

    // Inner ring (Light Blue)
    paint.shader = const LinearGradient(
      colors: [Color(0xFF00BCD4), Color(0xFF00838F)], // Cyan gradient
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.3));
    paint.strokeWidth = 6; // Thinnest
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width * 0.6, height: size.height * 0.6),
      rotation + math.pi, // Different starting point
      math.pi * 0.9, // Slightly less than pi
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjusted padding
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B4A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20), // More rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32), // Larger icon
          const SizedBox(height: 10), // Increased spacing
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22, // Larger font
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70, // Softer white
              fontSize: 13, // Slightly larger
            ),
          ),
        ],
      ),
    );
  }
}
