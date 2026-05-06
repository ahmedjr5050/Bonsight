import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bonssight/core/theme/app_colors.dart';
import 'package:bonssight/core/di/injection_container.dart';
import 'package:bonssight/features/analysis/presentation/cubit/analysis_cubit.dart';

class NewAnalysisPage extends StatelessWidget {
  const NewAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnalysisCubit>(),
      child: const _NewAnalysisView(),
    );
  }
}

class _NewAnalysisView extends StatelessWidget {
  const _NewAnalysisView();

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<AnalysisCubit>().selectImage(image);
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
            const SnackBar(content: Text("Analysis successful!")),
          );
        } else if (state is AnalysisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final selectedImage = state is AnalysisImageSelected ? state.image : (state is AnalysisProcessing ? state.image : (state is AnalysisCompleted ? state.image : (state is AnalysisError ? state.image : null)));
        final isAnalyzing = state is AnalysisProcessing;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Image Analysis',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: isAnalyzing ? null : () => _pickImage(context),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, size: 64, color: AppColors.primaryBrand.withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  const Text('Upload X-Ray Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 8),
                                  const Text('Click to select from Camera or Gallery', style: TextStyle(color: AppColors.textSecondary)),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                                  const SizedBox(height: 16),
                                  Text(selectedImage.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 8),
                                  const Text('Tap to change image', style: TextStyle(color: AppColors.textSecondary)),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state is AnalysisCompleted) ...[
                        const Text("Detection Results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.result.detections.length,
                            itemBuilder: (context, index) {
                              final det = state.result.detections[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                                color: AppColors.inputBackground,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              det.fractureType, 
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: det.severity == 'Severe' ? Colors.red : AppColors.primaryBrand),
                                            ),
                                          ),
                                          Text('${(det.confidence * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(det.description, style: const TextStyle(color: AppColors.textSecondary)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                            child: Text('Severity: ${det.severity}', style: const TextStyle(fontSize: 12)),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                            child: Text('Treatment: ${det.treatment}', style: const TextStyle(fontSize: 12)),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.read<AnalysisCubit>().reset(),
                            child: const Text('Start New Analysis'),
                          ),
                        )
                      ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: selectedImage == null || isAnalyzing ? null : () => _startAnalysis(context, selectedImage),
                          icon: isAnalyzing
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.location_on_outlined),
                          label: Text(isAnalyzing ? 'Analyzing...' : 'Start AI Analysis'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedImage == null ? AppColors.border : AppColors.primaryBrand,
                            foregroundColor: selectedImage == null ? AppColors.textSecondary : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                          ),
                        ),
                      )
                      ]
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
      },
    );
  }
}
