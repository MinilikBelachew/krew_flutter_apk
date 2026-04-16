import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/services/dispatch_tracking_service.dart';
import 'package:movers/core/utils/toast_service.dart';
import 'section_group.dart';
import 'settings_tile.dart';

class TrackingSection extends StatefulWidget {
  final DispatchTrackingService trackingService;

  const TrackingSection({super.key, required this.trackingService});

  @override
  State<TrackingSection> createState() => _TrackingSectionState();
}

class _TrackingSectionState extends State<TrackingSection> {
  bool _enabled = false;
  bool _loading = true;

  bool _biometricEnabled = false;
  bool _biometricLoading = true;
  static const _storage = FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const _trackingConsentKey = 'tracking_consent_v1';

  @override
  void initState() {
    super.initState();
    _load();
    _loadBiometric();
  }

  Future<void> _load() async {
    try {
      final enabled = await widget.trackingService.isEnabled();
      if (!mounted) return;
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _setEnabled(bool value) async {
    if (_loading) return;

    if (value) {
      final consent = await _storage.read(key: _trackingConsentKey);
      final hasConsent = consent == 'true';
      if (!hasConsent) {
        if (!mounted) return;
        final accepted = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Live location tracking',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
            content: Text(
              'When enabled, the app may collect and send your location periodically during active jobs so dispatch can track progress in real time. You can turn this off anytime in Settings.',
              style: GoogleFonts.inter(fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'I Agree',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );

        if (accepted != true) {
          if (mounted) setState(() => _enabled = false);
          return;
        }

        // Request OS level permissions explicitly
        try {
          final serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            throw Exception('Location services are disabled in OS settings');
          }

          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
            throw Exception('Location permission denied by user');
          }
        } catch (e) {
          if (mounted) {
            ToastService.showError(context, e.toString());
            setState(() => _enabled = false);
          }
          return;
        }

        await _storage.write(key: _trackingConsentKey, value: 'true');
      }
    }

    setState(() => _loading = true);

    try {
      await widget.trackingService.persistEnabled(value);
      if (mounted) {
        ToastService.showSuccess(
          context,
          value ? 'Tracking enabled' : 'Tracking disabled',
        );
      }
      if (!mounted) return;
      setState(() => _enabled = value);
    } catch (e) {
      if (mounted) ToastService.showError(context, e.toString());
      await widget.trackingService.persistEnabled(false);
      if (mounted) setState(() => _enabled = false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadBiometric() async {
    try {
      final v = await _storage.read(key: 'biometric_enabled');
      if (!mounted) return;
      setState(() {
        _biometricEnabled = v == 'true';
        _biometricLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _biometricLoading = false);
    }
  }

  Future<void> _setBiometricEnabled(bool value) async {
    if (_biometricLoading) return;
    setState(() => _biometricLoading = true);

    try {
      if (value) {
        final supported = await _localAuth.isDeviceSupported();
        final canCheck = await _localAuth.canCheckBiometrics;
        if (!supported || !canCheck) {
          throw Exception('Biometrics not available on this device');
        }

        final didAuth = await _localAuth.authenticate(
          localizedReason: 'Enable biometric login',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );

        if (!didAuth) throw Exception('Biometric authentication cancelled');
      }

      await _storage.write(
        key: 'biometric_enabled',
        value: value ? 'true' : 'false',
      );

      if (mounted) {
        ToastService.showSuccess(
          context,
          value ? 'Biometric login enabled' : 'Biometric login disabled',
        );
      }

      if (!mounted) return;
      setState(() => _biometricEnabled = value);
    } catch (e) {
      if (mounted) ToastService.showError(context, e.toString());
      await _storage.write(key: 'biometric_enabled', value: 'false');
      if (mounted) setState(() => _biometricEnabled = false);
    } finally {
      if (mounted) setState(() => _biometricLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionGroup(
      label: 'Privacy & Security',
      children: [
        SettingsTile(
          icon: Icons.location_on_outlined,
          title: 'Share Live Location',
          trailing: Switch.adaptive(
            value: _enabled,
            activeTrackColor: AppColors.primary,
            onChanged: _loading ? null : _setEnabled,
          ),
          onTap: _loading ? null : () => _setEnabled(!_enabled),
        ),
        SettingsTile(
          icon: Icons.fingerprint_rounded,
          title: 'Biometric Login',
          isLast: true,
          trailing: Switch.adaptive(
            value: _biometricEnabled,
            activeTrackColor: AppColors.primary,
            onChanged: _biometricLoading ? null : _setBiometricEnabled,
          ),
          onTap: _biometricLoading
              ? null
              : () => _setBiometricEnabled(!_biometricEnabled),
        ),
      ],
    );
  }
}
