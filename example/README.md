# Aura Fashion - VTON Integration Sample App

A premium, production-grade Fashion E-commerce sample mobile application showcasing the seamless, single-line integration of the **SnapIT Virtual Try-On (VTON) Flutter SDK**.

---

## 🎨 Design & Aesthetics (Brutal-Luxe Dark)

Following the highest UI/UX standards for luxury fashion:
- **Color Theme**: Deep Onyx (`#0A0A0C`) workspace with structured Carbon (`#16161A`) sheets, highlighted by Electric Indigo (`#4F46E5`) for primary call-to-actions and Neon Cyan (`#06B6D4`) for interactive triggers.
- **Typography**: Paired high-end, contemporary **Outfit** typography for title headings, offering an editorial feel.
- **Micro-animations**: Smooth fluid transitions on entry (fade, slide) using `flutter_animate` and scaling feedback circles for interactive size selections.
- **Components**:
  - **Interactive Page Carousel**: Slide between 6 high-res product photos of the crop top with a fluid indicator, served directly from Firebase Storage.
  - **Size Selector Sheet**: Compact selector with a dynamically opening bottom sheet for the standard size guide.
  - **Verified Reviews**: Star ratings graph breakdown and real customer comment logs.
  - **Magic Try-On CTA**: A high-impact glowing button with a gradient overlay that triggers the SDK flow instantly.

---

## ⚙️ Environment Configuration & Run

This project is configured to automatically read your SnapIT API credentials dynamically from the `.env` or `.env.local` file inside the `example` directory at build/run time.

### Prerequisites
Make sure your `.env.local` inside the `example` directory contains the following fields:
```env
SNAPIT_SDK_API_KEY=your_api_key_here
SNAPIT_USER_ID=your_user_id_here
```

### Run Command
To launch the app on your simulator/device with the configuration injected automatically:
```bash
flutter run --dart-define-from-file=.env.local
```

If you compile/run without `--dart-define-from-file`, the app safely falls back to standard developer credentials pre-loaded inside `lib/config.dart`.

---

## 🛍️ Sample Product Specification
- **Product 1**: Elegant Green A-Line Dress
  - **Brand**: AURA LUXE
  - **Price**: ₹1,499 (MRP ₹2,999, 50% OFF)
  - **SKU**: `pid-1`
- **Product 2**: Classic White Net Top
  - **Brand**: AURA TRENDS
  - **Price**: ₹699 (MRP ₹1,399, 50% OFF)
  - **SKU**: `pid-2`

---

## 📦 SDK Integration Implementation Details

Inside `lib/screens/product_detail_screen.dart`, clicking the **TRY ON** button performs the following steps:
1. **Instant Launch**: Invokes the `SnapIT.launchTryOnFlow()` directly with the first Firebase Storage URL of the product. This skips the garment upload phase and launches the virtual try-on flow immediately, leading to a much smoother user experience.
