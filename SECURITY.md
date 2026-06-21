# 🔐 SECURITY.md — SmartIoT v1.0.4

এই ফাইলটা নতুন developer বা deployment-এর সময় অবশ্যই পড়তে হবে।

---

## ১. Firebase Database Secret — REVOKE করুন এখনই

এই ZIP distribution-এর আগের version-এ `FIREBASE_DB_SECRET` exposed হয়েছে।

**Firebase Console → Project Settings → Service Accounts → Database Secrets**
- পুরনো secret: **REVOKE** করুন
- নতুন secret generate করুন
- `esp32/SmartIoT_v15/secrets.h`-এ `FIREBASE_DB_SECRET`-এ paste করুন

---

## ২. AES-256 Key — নতুন generate করুন

```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

Output (64 hex chars) `secrets.h`-এর `AES_BACKUP_KEY_HEX`-এ রাখুন।
⚠️ প্রতিটি ESP32 device-এর জন্য **আলাদা unique key**।

---

## ৩. Android Release Keystore — নতুন তৈরি করুন

এই ZIP-এ `.jks` ফাইল নেই (নিরাপত্তার জন্য বাদ দেওয়া হয়েছে)।
নতুন keystore তৈরি করুন:

```bash
keytool -genkey -v \
  -keystore android/app/smartiot-release.jks \
  -alias smartiot \
  -keyalg RSA -keysize 2048 \
  -validity 10000
```

তারপর `android/key.properties`-এ password দিন।
⚠️ `.jks` এবং `key.properties` কখনো Git-এ push করবেন না।

---

## ৪. BLE Proof-of-Possession (PoP) — ✅ [FIX-POP-1] এখন per-device, fixed

**আগে:** `PROV_POP`/`kPoP` একটাই static string ছিল, সব device-এ same। App-এর
APK decompile করলে এই string বের করা যেত, আর সেটা দিয়ে theoretically যেকোনো
device provision/hijack করার চেষ্টা করা যেত — কারণ সব device-এর PoP একই।

**এখন:** প্রতিটা device নিজের serial (g_chipSerial, eFuse MAC থেকে আসা,
প্রতি device-এ আলাদা) আর একটা shared master key দিয়ে SHA256 হ্যাশ করে নিজের
আলাদা PoP বানায়। App একই algorithm দিয়ে BLE-তে দেখা serial থেকে মিলিয়ে
PoP বের করে। একটা device-এর PoP জানা থাকলেও অন্য device-এর PoP আলাদা থাকে।

`esp32/SmartIoT_v15/secrets.h`-এর `POP_MASTER_KEY_HEX` এবং
`lib/core/ble_secrets.dart`-এর `popMasterKeyHex` — দুটো **EXACTLY একই**
64-character hex value রাখতে হবে (দুটোই .gitignore-এ আছে, GitHub-এ যায় না)।

নতুন master key বানাতে: `python3 -c "import secrets; print(secrets.token_hex(32))"`
— তারপর সেই value firmware আর app দুই জায়গাতেই বসান (একসাথে, একটাই বসালে
PoP mismatch হয়ে কোনো device provision হবে না)।

⚠️ **সততার সাথে বলা দরকার:** এই fix master key-কে app/firmware binary-র
ভেতরেই রাখে — অর্থাৎ যথেষ্ট দক্ষ একজন reverse-engineer একটা copy থেকে
master key বের করে ফেললে সেটা দিয়ে অন্য সব device-এর PoP-ও গণনা করে ফেলতে
পারবে (কারণ serial আগে থেকেই BLE-তে খোলাখুলি প্রচার হয়)। এটা truly
unbreakable না — কিন্তু আগের মতো "একটা plaintext string বের করলেই সব শেষ"
অবস্থা থেকে অনেক বেশি কঠিন একটা obstacle তৈরি করে। সম্পূর্ণ সমাধানের জন্য
physical label/QR code per device (manufacturing-এ) অথবা server-mediated
PoP লাগবে — দুটোই এই project-এর scale-এ এখন practical না।

---

## ৫. Google Services API Key — Restrict করুন

`android/app/google-services.json`-এর API key:
Firebase Console → Project Settings → API Keys → Restrict করুন
(Android apps only, package: `com.smartiot.smart_iot_interface`)

---

## ৬. secrets.h — কখনো Git-এ push করবেন না

`.gitignore`-এ আছে। Double-check করুন:
```bash
git status --short | grep secrets.h  # কিছু না দেখালে নিরাপদ
```

---

## ৭. Firmware Production Build

`esp32/SmartIoT_v15/SmartIoT_v15.ino`-এ নিশ্চিত করুন:
```cpp
#define PRODUCTION_MODE 1  // ← 1 হতে হবে, 0 না
```
`0` হলে সব debug info UART-এ expose হবে।
