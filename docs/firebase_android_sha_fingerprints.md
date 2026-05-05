# Firebase Phone OTP (Android) — SHA-1 & SHA-256

Firebase **Phone Auth (OTP)** on **Android** requires your app’s signing certificate
fingerprints to be added in the Firebase Console.

You usually add:
- **Debug** SHA‑1 + SHA‑256 (for local development)
- **Release** SHA‑1 + SHA‑256 (for Play Store / production builds)

> Note: iOS does not use SHA fingerprints; Android does.

---

## Option A (Recommended): Gradle signing report

From project root:

```bash
cd android
./gradlew signingReport
```

On Windows (PowerShell):

```powershell
cd android
.\gradlew signingReport
```

Look for these sections in the output:
- `Variant: debug`
- `Variant: release`

Copy values for:
- `SHA1: ...`
- `SHA-256: ...`

---

## Option B: Using `keytool`

### Debug keystore (default)

```bash
keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android
```

It will print both:
- `SHA1: ...`
- `SHA256: ...`

### Release keystore (your own)

Replace:
- `<path-to-release-keystore>`
- `<alias>`

```bash
keytool -list -v -alias <alias> -keystore "<path-to-release-keystore>"
```

If it asks for password, enter your keystore password.

---

## Where to add in Firebase Console

Firebase Console → **Project settings** → **Your apps** → **Android app** → **SHA certificate fingerprints**

Add **both**:
- SHA‑1
- SHA‑256

Do this for:
- Debug (development)
- Release (production)

After adding fingerprints, download the updated `google-services.json` and place it in:
- `android/app/google-services.json`

Then run:

```bash
flutter clean
flutter pub get
flutter run
```

---

## Fill this in (for your records)

### Debug
- **SHA‑1**: `PASTE_HERE`
- **SHA‑256**: `PASTE_HERE`

### Release
- **SHA‑1**: `PASTE_HERE`
- **SHA‑256**: `PASTE_HERE`

