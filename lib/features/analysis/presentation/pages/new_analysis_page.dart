import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bonssight/core/theme/app_colors.dart';
import 'package:bonssight/core/di/injection_container.dart';
import 'package:bonssight/features/analysis/presentation/cubit/analysis_cubit.dart';
import 'package:bonssight/features/analysis/data/models/analysis_result_model.dart';
import 'package:bonssight/features/chat/presentation/pages/chat_page.dart';

class NewAnalysisPage extends StatelessWidget {
  final String uid;
  const NewAnalysisPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl.get<AnalysisCubit>(param1: uid),
      child: const _NewAnalysisView(),
    );
  }
}

class _NewAnalysisView extends StatefulWidget {
  const _NewAnalysisView();

  @override
  State<_NewAnalysisView> createState() => _NewAnalysisViewState();
}

class _NewAnalysisViewState extends State<_NewAnalysisView> {
  Uint8List? _imageBytes;
  String? _lastImagePath;

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _lastImagePath = image.path;
      });
      if (context.mounted) {
        context.read<AnalysisCubit>().selectImage(image);
      }
    }
  }

  Future<void> _loadBytesIfNeeded(XFile image) async {
    if (_lastImagePath != image.path) {
      final bytes = await image.readAsBytes();
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _lastImagePath = image.path;
        });
      }
    }
  }

  void _startAnalysis(BuildContext context, XFile image) {
    context.read<AnalysisCubit>().startAnalysis(image);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AnalysisCubit, AnalysisState>(
      listener: (context, state) {
        if (state is AnalysisCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text("Analysis complete!"),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state is AnalysisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final selectedImage = state is AnalysisImageSelected
            ? state.image
            : state is AnalysisProcessing
            ? state.image
            : state is AnalysisCompleted
            ? state.image
            : state is AnalysisError
            ? state.image
            : null;

        if (selectedImage != null) {
          _loadBytesIfNeeded(selectedImage);
        }

        final isAnalyzing = state is AnalysisProcessing;
        final isCompleted = state is AnalysisCompleted;

        final completedState = state is AnalysisCompleted ? state : null;
        final String? annotatedImageUrl = completedState?.result.imageResult;
        final Uint8List? annotatedImageBytes =
            completedState?.result.imageBytes;

        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'New Image Analysis',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (selectedImage != null && !isAnalyzing)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _imageBytes = null;
                          _lastImagePath = null;
                        });
                        context.read<AnalysisCubit>().reset();
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Start Over'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image panel
                    Expanded(
                      flex: 3,
                      child: _buildImagePanel(
                        context,
                        selectedImage,
                        isAnalyzing,
                        annotatedImageUrl,
                        annotatedImageBytes,
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right panel
                    Expanded(
                      flex: 2,
                      child: _buildRightPanel(
                        context,
                        state,
                        selectedImage,
                        isAnalyzing,
                        isCompleted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePanel(
    BuildContext context,
    XFile? selectedImage,
    bool isAnalyzing,
    String? annotatedImageUrl,
    Uint8List? annotatedImageBytes,
  ) {
    if (selectedImage == null) {
      return _buildUploadZone(context);
    }
    return _buildImagePreview(
      context,
      selectedImage,
      isAnalyzing,
      annotatedImageUrl,
      annotatedImageBytes,
    );
  }

  Widget _buildUploadZone(BuildContext context) {
    return InkWell(
      onTap: () => _pickImage(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryBrand.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: AppColors.primaryBrand.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Upload X-Ray Image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Click to select from gallery',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Browse Files',
                  style: TextStyle(
                    color: AppColors.primaryBrand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(
    BuildContext context,
    XFile image,
    bool isAnalyzing,
    String? annotatedImageUrl,
    Uint8List? annotatedImageBytes,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Priority: annotated bytes → annotated URL → original bytes
          if (annotatedImageBytes != null)
            Image.memory(
              annotatedImageBytes,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            )
          else if (annotatedImageUrl != null)
            Image.network(
              annotatedImageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white54),
                    ),
              // Server doesn't expose results/ publicly — show original image
              errorBuilder: (context, error, stackTrace) => _imageBytes != null
                  ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                  : const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
            )
          else if (_imageBytes != null)
            Image.memory(
              _imageBytes!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),

          // Analyzing overlay
          if (isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AI Analyzing...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detecting bone fractures',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Bottom info bar (when not analyzing)
          if (!isAnalyzing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        image.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(
    BuildContext context,
    AnalysisState state,
    XFile? selectedImage,
    bool isAnalyzing,
    bool isCompleted,
  ) {
    if (isCompleted && state is AnalysisCompleted) {
      return _buildResultsPanel(context, state);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedImage != null
                          ? (isAnalyzing ? Colors.orange : Colors.green)
                          : AppColors.border,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedImage == null
                        ? 'No image selected'
                        : isAnalyzing
                        ? 'Analyzing...'
                        : 'Image ready',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (selectedImage != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _infoRow(
                  Icons.insert_drive_file_outlined,
                  'File',
                  selectedImage.name,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Instructions when no image
        if (selectedImage == null) ...[
          _instructionItem(
            '1',
            'Upload an X-Ray image',
            'Click the panel on the left to select your image file.',
          ),
          const SizedBox(height: 12),
          _instructionItem(
            '2',
            'Review the image',
            'Ensure the image is clear and properly oriented.',
          ),
          const SizedBox(height: 12),
          _instructionItem(
            '3',
            'Start AI Analysis',
            'Click the button below to detect fractures.',
          ),
          const Spacer(),
        ],

        if (selectedImage != null && !isAnalyzing) const Spacer(),

        // Analyze button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: selectedImage == null || isAnalyzing
                ? null
                : () => _startAnalysis(context, selectedImage),
            icon: isAnalyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.biotech_outlined),
            label: Text(
              isAnalyzing
                  ? 'Analyzing...'
                  : selectedImage == null
                  ? 'Select an Image First'
                  : 'Start AI Analysis',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedImage == null
                  ? AppColors.border
                  : AppColors.primaryBrand,
              foregroundColor: selectedImage == null
                  ? AppColors.textSecondary
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: selectedImage != null ? 2 : 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsPanel(BuildContext context, AnalysisCompleted state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detection Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${state.result.detections.length} finding${state.result.detections.length != 1 ? 's' : ''} detected',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: state.result.detections.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final det = state.result.detections[index];
              final isSevere = det.severity == 'Severe';
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSevere
                        ? Colors.red.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            det.fractureType,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isSevere
                                  ? Colors.red.shade700
                                  : AppColors.primaryBrand,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSevere
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(det.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isSevere
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      det.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _tag(
                          'Severity: ${det.severity}',
                          isSevere ? Colors.red : Colors.orange,
                        ),
                        _tag(
                          'Treatment: ${det.treatment}',
                          AppColors.primaryBrand,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (state.result.detections.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openChat(context, state.result),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Discuss with AI'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBrand,
                side: const BorderSide(color: AppColors.primaryBrand),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _imageBytes = null;
                _lastImagePath = null;
              });
              context.read<AnalysisCubit>().reset();
            },
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('New Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openChat(BuildContext context, AnalysisResult result) {
    final buffer = StringBuffer();
    buffer.writeln(
      'I had an X-ray analyzed and the AI detected the following finding(s):',
    );
    for (final det in result.detections) {
      buffer.writeln(
        '- ${det.fractureType} (confidence ${(det.confidence * 100).toStringAsFixed(1)}%, '
        'severity: ${det.severity}). ${det.description} Suggested treatment: ${det.treatment}.',
      );
    }
    buffer.writeln(
      '\nCan you explain this condition in simple terms, what it means, and what I should know about it?',
    );

    final fractureTypes = result.detections.map((d) => d.fractureType).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          initialMessage: buffer.toString(),
          fractureTypes: fractureTypes,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _instructionItem(String step, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryBrand.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: AppColors.primaryBrand,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
