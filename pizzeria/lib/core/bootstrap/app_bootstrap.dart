import 'package:pizzeria/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBootstrap {
  static bool isReady = false;

  static Future<void> init() async {
    if (!AppConfig.isSupabaseConfigured) return;
    if (isReady) return;

    try {
      try {
        Supabase.instance.client;
        isReady = true;
        return;
      } catch (_) {}

      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      isReady = true;
    } catch (_) {
      try {
        Supabase.instance.client;
        isReady = true;
      } catch (_) {
        isReady = false;
      }
    }
  }
}
