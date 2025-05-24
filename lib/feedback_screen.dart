import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 1; // mínimo 1
  final TextEditingController _commentController = TextEditingController();

  void _submitFeedback() async {
    final comentario = _commentController.text;
    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'rating': _rating,
        'comentario': comentario,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            '¡Gracias por tu opinión!',
            style: AppTheme.subtitleStyle.copyWith(color: AppTheme.primaryColor),
          ),
          content: Text(
            'Tu valoración se ha enviado correctamente.',
            style: AppTheme.bodyStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Cerrar'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppTheme.backgroundColor,
        ),
      );

      // Limpiar campos
      _commentController.clear();
      setState(() => _rating = 1);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar la valoración: $e'),
          backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Valora tu experiencia',
        style: AppTheme.titleStyle.copyWith(
          color: Colors.white,
          fontSize: AppTheme.getFontSize(context, mobile: 20, tablet: 22, desktop: 24),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: _buildGradientDecoration(),
      child: SafeArea(
        child: AppTheme.centerContent(
          context: context,
          child: SingleChildScrollView(
            padding: AppTheme.getPadding(context),
            child: _buildFeedbackCard(context),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 214, 190, 231),
          Color.fromARGB(255, 148, 111, 205)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    return Card(
      elevation: AppTheme.isDesktop(context) ? 12 : 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppTheme.isDesktop(context) ? 24 : 16,
        ),
      ),
      color: AppTheme.backgroundColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: AppTheme.getMaxWidth(context),
        ),
        padding: AppTheme.getPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIcon(context),
            SizedBox(height: AppTheme.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
            _buildTitle(context),
            SizedBox(height: AppTheme.getSpacing(context, mobile: 24, tablet: 28, desktop: 32)),
            _buildRatingBar(context),
            SizedBox(height: AppTheme.getSpacing(context, mobile: 32, tablet: 36, desktop: 40)),
            _buildCommentField(context),
            SizedBox(height: AppTheme.getSpacing(context, mobile: 32, tablet: 36, desktop: 40)),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final iconSize = AppTheme.isDesktop(context) 
        ? 80.0 
        : AppTheme.isTablet(context) 
            ? 70.0 
            : 60.0;

    return Icon(
      Icons.star_rate_rounded,
      size: iconSize,
      color: AppTheme.primaryColor,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      '¿Cómo valorarías la aplicación?',
      textAlign: TextAlign.center,
      style: AppTheme.titleStyle.copyWith(
        color: AppTheme.primaryColor,
        fontSize: AppTheme.getFontSize(
          context,
          mobile: 22,
          tablet: 26,
          desktop: 28,
        ),
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context) {
    final itemSize = AppTheme.isDesktop(context) 
        ? 50.0 
        : AppTheme.isTablet(context) 
            ? 45.0 
            : 40.0;

    return RatingBar.builder(
      initialRating: _rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemSize: itemSize,
      itemPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.getSpacing(context, mobile: 4, tablet: 6, desktop: 8),
      ),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() => _rating = rating);
      },
    );
  }

  Widget _buildCommentField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _commentController,
        decoration: AppTheme.getInputDecoration(
          context,
          hintText: 'Escribe aquí tu comentario...',
          label: const Text('¿Deseas dejar un comentario?'), // Usar Text widget para el label
        ).copyWith(
          prefixIcon: const Icon(
            Icons.comment,
            color: AppTheme.primaryColor,
          ),
        ),
        maxLines: AppTheme.isDesktop(context) ? 5 : 4,
        style: AppTheme.bodyStyle.copyWith(
          fontSize: AppTheme.getFontSize(context, mobile: 14, tablet: 16, desktop: 16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final buttonHeight = AppTheme.isDesktop(context) 
        ? 60.0 
        : AppTheme.isTablet(context) 
            ? 55.0 
            : 50.0;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: _submitFeedback,
        style: AppTheme.getButtonStyle(context).copyWith(
          elevation: WidgetStateProperty.all(5),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Enviar Valoración',
            style: TextStyle(
              fontSize: AppTheme.getFontSize(context, mobile: 16, tablet: 18, desktop: 20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}