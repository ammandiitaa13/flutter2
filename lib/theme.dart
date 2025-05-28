import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Colors.grey;
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black;
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Breakpoints para responsividad
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  // Estilos de texto
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: secondaryColor,
  );

  // Utilidades para detectar tipo de dispositivo
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Decoraciones adaptables
  static BoxDecoration getBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withAlpha((255 * 0.2).round()), // Usar withAlpha para mayor precisión
          spreadRadius: 2,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Estilos de botón adaptables
  static ButtonStyle getButtonStyle(BuildContext context) {
    final isDesktopSize = isDesktop(context);
    
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(primaryColor),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: isDesktopSize ? 24 : 16,
          vertical: isDesktopSize ? 16 : 12,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevation: WidgetStateProperty.all(2),
    );
  }

  // Estilo de botón por defecto (sin context)
  static ButtonStyle buttonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(primaryColor),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
  );

  // Decoración de input adaptable
  static InputDecoration getInputDecoration(BuildContext context, {String? hintText, Widget? label}) {
    return InputDecoration(
      hintText: hintText,
      label: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Decoración de input por defecto (sin context)
  static InputDecoration inputDecoration = InputDecoration(
    // labelText: 'Label por defecto', // Si quieres un label por defecto, ahora debería ser label: Text('Label por defecto')
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: primaryColor),
    ),
  );

  // Espaciado adaptable
  static double getSpacing(BuildContext context, {double mobile = 8, double tablet = 12, double desktop = 16}) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet;
    }
    return mobile;
  }

  // Padding adaptable
  static EdgeInsets getPadding(BuildContext context) {
    final spacing = getSpacing(context, mobile: 16, tablet: 24, desktop: 32);
    return EdgeInsets.all(spacing);
  }

  // Padding horizontal adaptable
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final spacing = getSpacing(context, mobile: 16, tablet: 24, desktop: 32);
    return EdgeInsets.symmetric(horizontal: spacing);
  }

  // Ancho máximo para contenido
  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 800; // Ancho máximo en desktop
    }
    return double.infinity;
  }

  // Número de columnas para grids
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 3; // 3 columnas en desktop
    } else if (isTablet(context)) {
      return 2; // 2 columnas en tablet
    }
    return 1; // 1 columna en móvil
  }

  // Tamaño de fuente adaptable
  static double getFontSize(BuildContext context, {double mobile = 16, double tablet = 18, double desktop = 20}) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet;
    }
    return mobile;
  }

  // Widget contenedor responsivo
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: getMaxWidth(context),
      padding: padding ?? getPadding(context),
      child: child,
    );
  }

  // Widget para centrar contenido en pantallas grandes
  static Widget centerContent({
    required BuildContext context,
    required Widget child,
  }) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: getMaxWidth(context)),
        child: child,
      ),
    );
  }

  // Decoración de caja por defecto (sin context)
  static BoxDecoration boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withAlpha((255 * 0.2).round()), // Usar withAlpha para mayor precisión
        spreadRadius: 2,
        blurRadius: 4,
      ),
    ],
  );
}