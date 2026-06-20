// lib/services/country_code_service.dart
// ══════════════════════════════════════════════════════════════════════════════
//  SmartIoT v1.0.2 — Auto Country Code Detection
//  [FIX-COUNTRY-1] Detects SIM/network/locale country automatically
//  [FIX-COUNTRY-2] Prefills phone E.164 prefix in login screen
//
//  Priority: SIM Country → Network Country → Device Locale → Default (+880)
// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CountryCodeService {
  CountryCodeService._();

  static const _channel = MethodChannel('com.smartiot/country');

  /// Returns the E.164 dialing prefix for the device's SIM/network country.
  ///
  /// Priority:
  ///   1. SIM card country ISO (most reliable)
  ///   2. Network operator country ISO
  ///   3. Device locale country
  ///   4. Default: +880 (Bangladesh — primary market)
  ///
  /// Examples: "+880" (BD), "+91" (IN), "+1" (US), "+44" (UK)
  static Future<String> getDialCode() async {
    if (kIsWeb) return '+880';
    try {
      final result = await _channel.invokeMethod<String>('getPhoneDialCode');
      return result ?? '+880';
    } on MissingPluginException {
      // Web or unsupported platform
      return '+880';
    } catch (e) {
      if (kDebugMode) debugPrint('[CountryCode] getDialCode failed: $e');
      return '+880';
    }
  }

  /// Returns the ISO country code for the device (e.g. "bd", "in", "us").
  static Future<String> getIsoCode() async {
    if (kIsWeb) return 'bd';
    try {
      final result = await _channel.invokeMethod<String>('getSimIsoCountry');
      return result ?? 'bd';
    } catch (_) {
      return 'bd';
    }
  }

  /// Normalises a phone number to E.164 format.
  ///
  /// Rules:
  ///   - Already has '+' → returned as-is (user knows what they typed)
  ///   - Starts with '00' → replace '00' with '+'
  ///   - Otherwise → strip a single leading national trunk '0' (standard
  ///     ITU convention: the trunk prefix is dropped when prepending a
  ///     country code — true for BD, UK, IN, and most other countries),
  ///     then prepend [dialCode].
  ///
  /// [FIX-E164-2] Previously only Bangladesh (+880) had the leading-0
  /// strip; every other country in the picker (UK 07xxx, India 0xxx
  /// landlines, etc.) got a broken number like "+4407911123456" instead
  /// of "+447911123456". Now applies uniformly to any country.
  ///
  /// [dialCode] defaults to '+880' (Bangladesh).
  static String normalizeE164(String raw, {String dialCode = '+880'}) {
    final trimmed = raw.trim().replaceAll(RegExp(r'\s'), '');
    if (trimmed.isEmpty) return trimmed;

    // Already E.164
    if (trimmed.startsWith('+')) return trimmed;

    // 00-prefix international format
    if (trimmed.startsWith('00')) return '+${trimmed.substring(2)}';

    var digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    // Strip a single leading trunk '0' — applies to BD (01XXXXXXXXX),
    // UK (07XXXXXXXXX), India landlines (0XXXXXXXXXX), etc.
    if (digits.startsWith('0') && digits.length > 1) {
      digits = digits.substring(1);
    }
    return '$dialCode$digits';
  }
}
