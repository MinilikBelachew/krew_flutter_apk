import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/network/dio_client.dart';
import 'package:movers/core/utils/toast_service.dart';
import 'package:movers/features/job_details/presentation/widgets/signature_input_dialog.dart';

class ContractPage extends StatefulWidget {
  final String jobId;
  const ContractPage({super.key, required this.jobId});

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  Uint8List? _signatureBytes;
  bool _isSubmitting = false;
  bool _isLoadingContract = true;
  String? _contractContent;

  @override
  void initState() {
    super.initState();
    _fetchContract();
  }

  Future<void> _fetchContract() async {
    try {
      final dioClient = context.read<DioClient>();
      final endpoint = '/api/v1/dispatch/settings/contract-text';
      final resp = await dioClient.dio.get(endpoint);

      debugPrint('================================================');
      debugPrint('📄 [Contract] GET $endpoint');
      if (resp.data is Map) {
        final keys = (resp.data as Map).keys.toList();
        debugPrint('Response keys: $keys');
      } else {
        debugPrint('Response type: ${resp.data.runtimeType}');
      }
      debugPrint('================================================');

      final data = resp.data;
      final agreementText = (data is Map<String, dynamic>)
          ? data['text']?.toString()
          : null;

      setState(() {
        _contractContent = agreementText ?? '';
        _isLoadingContract = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contractContent = '';
        _isLoadingContract = false;
      });
      ToastService.showError(context, 'Failed to load contract');
    }
  }

  Future<void> _submitSignature() async {
    if (_signatureBytes == null) return;

    setState(() => _isSubmitting = true);
    try {
      final dioClient = context.read<DioClient>();
      final base64Sig = base64Encode(_signatureBytes!);
      final signatureData = 'data:image/png;base64,$base64Sig';

      await dioClient.dio.post(
        '/api/v1/dispatch/jobs/${widget.jobId}/sign-contract',
        data: {'signatureData': signatureData},
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String message = 'Failed to submit contract signature';
        debugPrint('================================================');
        debugPrint(
          '✍️ [Contract] POST /api/v1/dispatch/jobs/${widget.jobId}/sign-contract failed',
        );
        debugPrint(e.toString());
        if (e is DioException) {
          debugPrint('Status: ${e.response?.statusCode}');
          debugPrint('Data: ${e.response?.data}');
          if (e.response?.data is Map &&
              (e.response?.data as Map)['message'] != null) {
            message = '${(e.response?.data as Map)['message']}';
          }
        }
        debugPrint('================================================');
        ToastService.showError(context, message);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptivePageBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.adaptiveCardBackground(context),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close,
            color: AppColors.adaptiveTextPrimary(context),
          ),
        ),
        title: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.adaptiveNeutralBackground(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Contract and policies',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.adaptiveTextPrimary(context),
              ),
            ),
          ),
        ),
        actions: [
          const SizedBox(width: 48), // Balancing leading
        ],
      ),
      bottomNavigationBar: _signatureBytes != null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitSignature,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Finish',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingContract)
              const Padding(
                padding: EdgeInsets.only(top: 24, bottom: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.adaptiveNeutralBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.adaptiveBorder(context)),
                ),
                child: Text(
                  (_contractContent ?? '').isNotEmpty
                      ? _contractContent!
                      : 'No contract content configured.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.adaptiveTextPrimary(context),
                    height: 1.5,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            Text(
              'Client signature',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.adaptiveTextPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final result = await showDialog<Uint8List?>(
                  context: context,
                  builder: (context) => const SignatureInputDialog(),
                );
                if (result != null) {
                  setState(() {
                    _signatureBytes = result;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.adaptiveNeutralBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.adaptiveBorder(context)),
                ),
                child: _signatureBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _signatureBytes!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.gesture,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
