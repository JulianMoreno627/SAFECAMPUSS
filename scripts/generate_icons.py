"""
Generate properly formatted app icons from the SafeCampus logo.
Creates square icons with proper padding and matching background colors.
"""
from PIL import Image, ImageDraw
import os

LOGO_PATH = "assets/images/logo.png"
OUTPUT_DIR = "assets/images"

# App colors from app_colors.dart
# primary: #1A237E (deep indigo)
# secondary: #0D47A1 (dark blue)
# accent: #00BCD4 (cyan)
# background: #0A0E21 (very dark blue)
# surface: #1D1F33

# Use primary (#1A237E) as the icon background - matches the app and looks formal
BG_COLOR = (26, 35, 126, 255)  # #1A237E - primary indigo


def create_square_icon(logo_img, size, padding_ratio=0.12):
    """Create a square icon with the logo centered and padded."""
    canvas = Image.new("RGBA", (size, size), BG_COLOR)

    # Calculate the available area after padding
    padding = int(size * padding_ratio)
    available = size - (2 * padding)

    # Resize logo maintaining aspect ratio to fit in available area
    logo_w, logo_h = logo_img.size
    ratio = min(available / logo_w, available / logo_h)
    new_w = int(logo_w * ratio)
    new_h = int(logo_h * ratio)

    resized_logo = logo_img.resize((new_w, new_h), Image.LANCZOS)

    # Center the logo
    x = (size - new_w) // 2
    y = (size - new_h) // 2

    canvas.paste(resized_logo, (x, y), resized_logo)
    return canvas


def create_adaptive_foreground(logo_img, size=1024):
    """
    Create an adaptive icon foreground.
    Android adaptive icons have a 108dp canvas with a 72dp safe zone (66.67%).
    The outer 18dp on each side may be masked. So we need ~33% padding.
    """
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    # Safe zone is inner 66.67%, so padding is 16.67% on each side
    safe_padding = int(size * 0.20)  # A bit more padding for comfort
    available = size - (2 * safe_padding)

    logo_w, logo_h = logo_img.size
    ratio = min(available / logo_w, available / logo_h)
    new_w = int(logo_w * ratio)
    new_h = int(logo_h * ratio)

    resized_logo = logo_img.resize((new_w, new_h), Image.LANCZOS)

    x = (size - new_w) // 2
    y = (size - new_h) // 2

    canvas.paste(resized_logo, (x, y), resized_logo)
    return canvas


def main():
    logo = Image.open(LOGO_PATH)
    print(f"Original logo: {logo.size} {logo.mode}")

    # 1. Standard icon (for iOS / Android legacy / web)
    icon_1024 = create_square_icon(logo, 1024, padding_ratio=0.10)
    icon_path = os.path.join(OUTPUT_DIR, "app_icon.png")
    icon_1024.save(icon_path, "PNG")
    print(f"Created: {icon_path} ({icon_1024.size})")

    # 2. Adaptive icon foreground (transparent bg, properly padded)
    fg = create_adaptive_foreground(logo, 1024)
    fg_path = os.path.join(OUTPUT_DIR, "app_icon_foreground.png")
    fg.save(fg_path, "PNG")
    print(f"Created: {fg_path} ({fg.size})")

    # 3. iOS icon (no alpha channel allowed)
    ios_icon = icon_1024.convert("RGB")
    ios_path = os.path.join(OUTPUT_DIR, "app_icon_ios.png")
    ios_icon.save(ios_path, "PNG")
    print(f"Created: {ios_path} ({ios_icon.size})")

    print("\n✅ All icons generated successfully!")
    print(f"   Background color: #1A237E (primary indigo)")


if __name__ == "__main__":
    main()
