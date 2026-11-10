# Akshay & Wilma – Digital Wedding Invitation (Flutter Web)

An animated, mobile-first wedding invitation: wax-sealed envelope opening, calligraphy names,
parallax watercolour florals, floating petals, live countdown, parents' blessing,
venue featuring The Basilica of Our Lady of Ransom with Google Maps directions, and a thank-you section.

> **Status:** the code was written without a Flutter SDK available, so it has **not been compiled or
> viewed in a browser yet**. Run the steps in "Run locally" first; if the analyzer reports anything,
> it will be small and local. See "Things to check on first run" below.

## Wedding details
All wording, dates and venue details live in **`lib/core/config.dart`** (verbatim from the brief).
The countdown target is `DateTime.utc(2026, 12, 27, 5, 0)` which is **10:30 AM IST**.

## Run locally
```bash
# Flutter 3.22+ (stable) – https://docs.flutter.dev/get-started/install
flutter pub get
flutter analyze
flutter run -d chrome
```
To test on a phone on the same Wi-Fi:
```bash
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
# open http://<your-computer-ip>:8080 on the phone
```

## Replace the placeholders
| What | Where | Notes |
|---|---|---|
| Couple photos | Put files in `assets/images/gallery/`, then list them in `galleryPhotos` in `lib/core/config.dart` | e.g. `'assets/images/gallery/1.jpg'`. Use JPG/WebP, ~1000 px wide. Until then, "Photo coming soon" frames show. |
| WhatsApp / social preview image | Overwrite `web/og-image.png` | **Use 1200×630 px, under 300 KB.** The shipped file is a simple stand-in; export your real invitation image at this size. |
| Favicon / app icons | `web/favicon.png`, `web/icons/*.png` | Stand-ins with an "A&W" monogram. |
| Music | Overwrite `assets/audio/music.mp3` | The shipped loop is a short, original synthesised piano-style piece (no licensing issues). Replace with any soft instrumental you have rights to; keep it under ~3 MB. |

## Publish with GitHub Pages (public link for WhatsApp)
1. Create an empty repository on GitHub, e.g. `wedding-invitation` (public).
2. In this folder:
   ```bash
   git init
   git add .
   git commit -m "Wedding invitation"
   git branch -M main
   git remote add origin https://github.com/<your-username>/wedding-invitation.git
   git push -u origin main
   ```
3. On GitHub: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
4. Open the **Actions** tab; the "Deploy Flutter Web to GitHub Pages" run builds and publishes.
5. Your link will be `https://<your-username>.github.io/wedding-invitation/`. Share it on WhatsApp.

The workflow builds with the correct `--base-href` for your repository name and rewrites the
`__SITE_URL__` placeholders in `index.html`, so the WhatsApp preview image and title work automatically.

### Manual production build (any host)
```bash
flutter build web --release --base-href "/wedding-invitation/"   # use "/" for a custom domain
# upload build/web/ to your host; then replace __SITE_URL__ in build/web/index.html
# with your full URL (ending in "/")
```

## WhatsApp preview tips
* WhatsApp caches previews. After changing `og-image.png`, test with a fresh link such as
  `https://…/wedding-invitation/?v=2`, or refresh via Facebook's Sharing Debugger.
* Keep the preview image under ~300 KB or WhatsApp may skip it.
* Music starts only after the guest taps **Open Invitation** (browser autoplay rules). The
  **Music ON/OFF** pill is always visible top-right.

## Project structure
```
lib/
  main.dart, app.dart            entry point, theme, scroll behaviour, error guards
  core/config.dart               ALL wedding content
  core/theme.dart                colours, fonts (Great Vibes / Cormorant Garamond / Cinzel), responsive helpers
  services/music_service.dart    user-controlled looping audio
  screens/invitation_shell.dart  envelope ↔ invitation orchestration
  screens/envelope_screen.dart   wax-sealed envelope + opening animation
  screens/invitation_page.dart   hero, announcement, countdown, gallery, blessing, venue, thank-you
  widgets/                       reveal (scroll animations), floral (watercolour art + parallax), petals,
                                 countdown, church illustration + pin, ornaments, music button
web/                             index.html (SEO + share tags + splash), manifest, favicon, og-image
.github/workflows/deploy.yml     GitHub Pages deployment
```

## Performance notes
* Florals, church and envelope are drawn with Canvas – no large image downloads. Total shipped
  assets are ~0.6 MB (audio is the largest).
* Parallax moves a pre-painted layer (cheap); petals/sparkles are one painter driven by one controller.
* Animations are skipped when the device has "reduce motion" enabled.
* Fonts come from Google Fonts at first load (cached afterwards). To bundle them for offline use, download
  Great Vibes, Cormorant Garamond and Cinzel, add them under `assets/fonts/`, and declare them in `pubspec.yaml`.

## Things to check on first run
* Package versions in `pubspec.yaml` are recent as of writing; if `flutter pub get` complains, run
  `flutter pub upgrade` or loosen the version.
* Test inside the WhatsApp in-app browser on both an iPhone and a Samsung phone (audio start, Google Maps
  button, scrolling).
* The 3-D flap rotation in the envelope is the most "visual" part of the code – if it looks off on a device,
  tweak the `Interval` timings or the `setEntry(3, 2, .0012)` perspective value in `envelope_screen.dart`.
* The church photograph of The Basilica of Our Lady of Ransom, Vallarpadam is included in
  `assets/images/basilica_church.jpg` and rendered with a fade-in animation and subtle zoom effect
  in `ChurchIllustration`, preserving the full twin towers without cropping.
* Photo gallery sections have been removed per the brief.
* Invitation message uses: "wedding ceremony of our son".
