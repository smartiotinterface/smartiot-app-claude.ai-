// lib/core/ble_secrets.template.dart
// ══════════════════════════════════════════════════════════════════════════
//  [FIX-POP-1] Per-device BLE PoP — master key template
//
//  এই ফাইল কপি করে lib/core/ble_secrets.dart বানাও (সেই ফাইলটা .gitignore
//  করা আছে, কখনো GitHub-এ push হবে না)। নিচের placeholder-টা
//  esp32/SmartIoT_firmware/secrets.h-এর POP_MASTER_KEY_HEX-এর সাথে
//  EXACTLY same value হতে হবে — না হলে BLE provisioning কোনো device-এই
//  কাজ করবে না (app আর firmware আলাদা PoP বের করবে, mismatch হবে)।
//
//  কীভাবে নতুন key বানাবে (firmware আর app দুই জায়গায়ই একই key বসাও):
//    python3 -c "import secrets; print(secrets.token_hex(32))"
//
//  সেই 64-character hex string-টা নিচে আর secrets.h-এর
//  POP_MASTER_KEY_HEX দুই জায়গায় বসাও।
// ══════════════════════════════════════════════════════════════════════════

const String popMasterKeyHex =
    'REPLACE_WITH_64_HEX_CHARS_MATCHING_SECRETS_H_POP_MASTER_KEY_HEX';
