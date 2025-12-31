import 'package:flutter/material.dart';

/// Professional color palette for Modbus RS485 Communication App
class AppColors {
  AppColors._();

  // Primary Colors - Vibrant Blue Gradient
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryGradientStart = Color(0xFF2196F3);
  static const Color primaryGradientEnd = Color(0xFF1976D2);

  // Accent Colors
  static const Color accent = Color(0xFF00BCD4);
  static const Color accentLight = Color(0xFF4DD0E1);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);

  // Connection Status
  static const Color connected = Color(0xFF4CAF50);
  static const Color disconnected = Color(0xFFF44336);
  static const Color connecting = Color(0xFFFF9800);

  // Background Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF0A0E27);
  static const Color backgroundLight = Color(0xFF1A1F3A);
  static const Color surface = Color(0xFF1E2746);
  static const Color surfaceLight = Color(0xFF2A3154);

  // Card & Components
  static const Color cardBackground = Color(0xFF1E2746);
  static const Color cardBackgroundLight = Color(0xFF2A3154);

  // Glassmorphism
  static Color glassBackground = Colors.white.withOpacity(0.1);
  static Color glassBorder = Colors.white.withOpacity(0.2);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B9D3);
  static const Color textTertiary = Color(0xFF8A91B4);
  static const Color textDisabled = Color(0xFF5A5F7F);

  // Divider & Borders
  static const Color divider = Color(0xFF2A3154);
  static const Color border = Color(0xFF3A4162);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.1);
  static Color shadowMedium = Colors.black.withOpacity(0.2);
  static Color shadowHeavy = Colors.black.withOpacity(0.3);

  // Overlay Colors
  static Color overlay = Colors.black.withOpacity(0.5);
  static Color overlayLight = Colors.black.withOpacity(0.3);
}
/*
  Giải thích chi tiết các thành phần trong file AppColors:

  1. AppColors Class (Lớp Tiện Ích Màu Sắc):
     - Mục đích: Tập trung quản lý toàn bộ hệ thống màu sắc của ứng dụng tại một nơi duy nhất, giúp dễ dàng bảo trì và thay đổi theme.
     - Thiết kế: Sử dụng pattern Singleton ẩn hoặc Utility Class thuần túy với constructor private `AppColors._()` để ngăn chặn việc tạo instance vô ý.

  2. Bảng Màu Cơ Bản (Base Palette):
     - Primary Colors: Màu chủ đạo định danh thương hiệu (Brand Identity).
       + `primary`: Màu chính dùng cho nút bấm, thanh điều hướng.
       + `primaryLight/Dark`: Các biến thể sáng/tối để tạo chiều sâu hoặc trạng thái hover/active.
     - Semantic Colors (Màu Ngữ Nghĩa): Dùng để thông báo trạng thái hệ thống.
       + `success` (Xanh lá): Hoàn thành, thành công, an toàn.
       + `error` (Đỏ): Lỗi nghiêm trọng, thất bại, nguy hiểm.
       + `warning` (Vàng/Cam): Cảnh báo cần chú ý.
       + `info` (Xanh dương): Thông tin bổ sung.

  3. Màu Nền & Bề Mặt (Background & Surface):
     - Thiết kế cho Dark Mode (Giao diện tối):
       + `backgroundDark`: Màu nền chính, thường là màu tối nhất.
       + `surface`: Màu nền cho các thẻ (Cards), Dialog, Sheet, sáng hơn nền chính để tạo lớp (layer).
       + `surfaceHighlight`: Dùng để làm nổi bật một vùng cụ thể trên bề mặt.

  4. Typography Colors (Màu Văn Bản):
     - `textPrimary`: Màu sáng nhất (thường là trắng hoặc gần trắng) cho tiêu đề, nội dung chính.
     - `textSecondary`: Màu xám nhạt cho phụ đề, mô tả ngắn.
     - `textDisabled`: Màu tối hơn hoặc độ mờ cao cho các thành phần không khả dụng.

  5. Gradients (Dải Màu Chuyển Sắc):
     - `primaryGradient`: Tạo điểm nhấn thị giác mạnh mẽ, thường dùng cho nút CTA (Call to Action) hoặc Header.
     - `backgroundGradient`: Giúp nền không bị đơn điệu, tạo cảm giác hiện đại.

  6. Hiệu Ứng & Lớp Phủ (Effects & Overlays):
     - `shadow...`: Các mức độ bóng đổ để tạo độ nổi (elevation) cho UI.
     - `overlay`: Lớp phủ mờ dùng khi hiển thị Modal hoặc Dialog để làm tối nền phía sau.
     - `glassBackground`: Hiệu ứng kính mờ (Glassmorphism) hiện đại.
*/

