from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "docs/assets/github-social-preview.png"
ICON = ROOT / "Main/Resources/Assets/Images.xcassets/AppIcon.appiconset/icon-1024.png"
SCREENSHOT = ROOT / "docs/AppStore/Preview/en/04.png"

W, H = 1280, 640
REGULAR = "/System/Library/Fonts/Supplemental/Arial.ttf"
BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def font(path, size):
    return ImageFont.truetype(path, size)


canvas = Image.new("RGBA", (W, H), "#08090b")
pixels = canvas.load()
for y in range(H):
    for x in range(W):
        base = (8, 9, 11)
        distance = ((x - 880) / 720) ** 2 + ((y - 350) / 480) ** 2
        glow = max(0, min(1, 1 - distance)) * 0.21
        pixels[x, y] = (
            int(base[0] + (155 - base[0]) * glow),
            int(base[1] + (66 - base[1]) * glow),
            int(base[2] + (17 - base[2]) * glow),
        )

draw = ImageDraw.Draw(canvas)
draw.line((0, 509, 698, 509), fill="#202124", width=1)

# Sports heart-rate line.
ecg = [
    (64, 157), (118, 157), (133, 153), (148, 161), (163, 157),
    (178, 157), (190, 144), (205, 157), (218, 184), (235, 91), (253, 157),
    (273, 157), (287, 150), (303, 164), (320, 157), (580, 157),
]
draw.line(ecg, fill="#ff8a32", width=4, joint="curve")
draw.ellipse((59, 152, 69, 162), fill="#ff8a32")

icon_tile = Image.new("RGBA", (120, 120), (0, 0, 0, 0))
tile_draw = ImageDraw.Draw(icon_tile)
tile_draw.rounded_rectangle((0, 0, 119, 119), radius=31, fill="#1d1e21", outline="#ff7b25", width=2)
icon = Image.open(ICON).convert("RGBA").resize((90, 90), Image.Resampling.LANCZOS)
icon_tile.alpha_composite(icon, (15, 15))
canvas.alpha_composite(icon_tile, (64, 202))
draw.text((64, 350), "Fight Clock", font=font(BOLD, 76), fill="#ffffff", stroke_width=0)
draw.text((64, 451), "Boxing round timer for iPhone", font=font(REGULAR, 29), fill="#b7b7ba")

# Crop the real active-round screen from the App Store screenshot.
source = Image.open(SCREENSHOT).convert("RGBA")
content = source.crop((150, 520, 1092, 2500))
screen_size = (290, 610)
content = content.resize(screen_size, Image.Resampling.LANCZOS)
screen = Image.new("RGBA", screen_size, (0, 0, 0, 0))
mask = Image.new("L", screen_size, 0)
ImageDraw.Draw(mask).rounded_rectangle((0, 0, 289, 609), radius=29, fill=255)
screen.paste(content, (0, 0), mask)

position = (872, 15)
shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
shadow_mask = Image.new("L", screen_size, 0)
ImageDraw.Draw(shadow_mask).rounded_rectangle((0, 0, 289, 609), radius=29, fill=210)
shadow.paste((0, 0, 0, 185), (position[0], position[1]), shadow_mask)
shadow = shadow.filter(ImageFilter.GaussianBlur(22))
canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow)

halo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
ImageDraw.Draw(halo).rounded_rectangle((852, -5, 1182, 645), radius=51, outline=(239, 118, 40, 45), width=18)
halo = halo.filter(ImageFilter.GaussianBlur(20))
canvas = Image.alpha_composite(canvas, halo)
device = Image.new("RGBA", (330, 650), (0, 0, 0, 0))
device_draw = ImageDraw.Draw(device)
device_draw.rounded_rectangle((0, 0, 329, 649), radius=49, fill="#08090a", outline="#45474c", width=3)
device_draw.rounded_rectangle((9, 9, 320, 640), radius=41, fill="#15161a")
canvas.alpha_composite(device, (852, -5))
canvas.alpha_composite(screen, position)

edge = ImageDraw.Draw(canvas)

canvas.convert("RGB").save(OUT, "PNG", optimize=True, compress_level=9)
