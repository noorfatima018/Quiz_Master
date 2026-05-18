import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../core/theme/app_theme.dart';
import '../models/quiz_settings.dart';
import '../providers/quiz_provider.dart';
import 'active_quiz_screen.dart';

class QuizStartScreen extends StatefulWidget {
  final String subjectTitle;
  final IconData subjectIcon;
  final Color subjectColor;
  final String? initialMode; // 'Topic' or 'File'

  const QuizStartScreen({
    super.key,
    required this.subjectTitle,
    required this.subjectIcon,
    required this.subjectColor,
    this.initialMode,
  });

  @override
  State<QuizStartScreen> createState() => _QuizStartScreenState();
}

class _QuizStartScreenState extends State<QuizStartScreen> {
  double _questionCount = 10;
  int _timePerQuestion = 30;
  bool _allowBack = true;
  late String _generationMode;
  final TextEditingController _topicController = TextEditingController();
  String? _selectedFileName;
  String? _extractedText;
  bool _isParsingFile = false;

  @override
  void initState() {
    super.initState();
    _generationMode = widget.initialMode ?? 'Subject';
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _isParsingFile = true;
      });

      try {
        if (result.files.single.extension == 'pdf') {
          final PdfDocument document = PdfDocument(inputBytes: result.files.single.bytes);
          String text = PdfTextExtractor(document).extractText();
          document.dispose();

          if (text.trim().isEmpty) {
            throw Exception('The PDF appears to be empty or contains only images (OCR not supported).');
          }

          setState(() {
            _extractedText = text;
          });
        } else if (result.files.single.extension == 'txt') {
          final bytes = result.files.single.bytes;
          if (bytes == null) throw Exception('Could not read file data.');

          String text = utf8.decode(bytes); // Use utf8 for better compatibility

          if (text.trim().isEmpty) {
            throw Exception('The text file is empty.');
          }

          setState(() {
            _extractedText = text;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reading file: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        setState(() {
          _isParsingFile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: _buildConfigCard(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.subjectColor, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Expanded(
                child: Text(
                  'Quiz Settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
            ),
            child: Icon(widget.subjectIcon, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            widget.subjectTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Generation Mode'),
          const SizedBox(height: 16),
          _buildModeSelector(),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_generationMode),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_generationMode == 'Topic') ...[
                  const SizedBox(height: 24),
                  _buildTopicInput(),
                ] else if (_generationMode == 'File') ...[
                  const SizedBox(height: 24),
                  _buildFileUpload(),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionTitle('Questions: ${_questionCount.round()}'),
          Slider(
            value: _questionCount,
            min: 5,
            max: 20,
            divisions: 3,
            activeColor: widget.subjectColor,
            inactiveColor: widget.subjectColor.withValues(alpha: 0.25),
            onChanged: (val) => setState(() => _questionCount = val),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Time / Question'),
          const SizedBox(height: 16),
          _buildTimeSelector(),

          const SizedBox(height: 32),
          _buildBackNavigationToggle(),

          const SizedBox(height: 48),
          _buildStartButton(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: ['Subject', 'Topic', 'File'].map((mode) {
          bool isSelected = _generationMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _generationMode = mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? widget.subjectColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [
                    BoxShadow(color: widget.subjectColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ] : [],
                ),
                child: Text(
                  mode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (AppColors.textGrey),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopicInput() {
    return TextField(
      controller: _topicController,
      style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: 'e.g. Quantum Computing',
        hintStyle: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.5)),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.psychology_rounded, color: widget.subjectColor),
      ),
    );
  }

  Widget _buildFileUpload() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.subjectColor.withValues(alpha: 0.2), width: 2),
          color: widget.subjectColor.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            _isParsingFile
                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: widget.subjectColor))
                : Icon(Icons.cloud_upload_rounded, color: widget.subjectColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _isParsingFile ? 'Analyzing Content...' : (_selectedFileName ?? 'Upload PDF/TXT'),
                style: TextStyle(
                  color: _selectedFileName != null
                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color)
                      : (AppColors.textGrey),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Row(
      children: [15, 30, 60].map((sec) {
        bool isSelected = _timePerQuestion == sec;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _timePerQuestion = sec),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? widget.subjectColor : (Colors.transparent),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? widget.subjectColor : (Colors.grey.withValues(alpha: 0.2)), width: 2),
              ),
              child: Text(
                '${sec}s',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textGrey,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBackNavigationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BACKTRACKING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, color: Theme.of(context).textTheme.bodyLarge?.color)),
            Text('Allow going to previous Qs', style: TextStyle(fontSize: 11, color: AppColors.textGrey.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
          ],
        ),
        Switch(
          value: _allowBack,
          activeThumbColor: widget.subjectColor,
          onChanged: (val) => setState(() => _allowBack = val),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.subjectColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: quizProvider.isLoading ? null : () async {
              final settings = QuizSettings(
                questionCount: _questionCount.round(),
                timePerQuestion: _timePerQuestion,
                allowBack: _allowBack,
                topic: _generationMode == 'Topic' ? _topicController.text : null,
                filePath: _generationMode == 'File' ? _selectedFileName : null,
              );

              quizProvider.updateSettings(settings);

              if (_generationMode == 'File' && _extractedText != null) {
                await quizProvider.loadAIQuestionsFromText(_extractedText!);
              } else {
                await quizProvider.loadQuestions(widget.subjectTitle);
              }

              if (context.mounted && quizProvider.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(quizProvider.errorMessage!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: AppColors.wrongRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }

              if (context.mounted && quizProvider.questions.isNotEmpty) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ActiveQuizScreen(
                      subjectTitle: widget.subjectTitle,
                      subjectColor: widget.subjectColor,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.subjectColor,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: quizProvider.isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : Text(
              'START CHALLENGE',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: widget.subjectColor == Colors.amber ? Colors.black87 : Colors.white, letterSpacing: 2),
            ),
          ),
        );
      },
    );
  }
}
