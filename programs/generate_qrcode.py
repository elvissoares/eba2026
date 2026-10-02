import qrcode
from PIL import Image, ImageDraw

url = "https://raw.githubusercontent.com/elvissoares/eba2026/refs/heads/main/aux/Mapa_CT_restaurantes.png"

qr = qrcode.QRCode(
    version=None,
    error_correction=qrcode.constants.ERROR_CORRECT_H,
    box_size=12,
    border=4,
)

qr.add_data(url)
qr.make(fit=True)

qr_img = qr.make_image(
    fill_color="black",
    back_color="white"
).convert("RGBA")

logo = Image.open("Logo_EBA.png").convert("RGBA")

# Dimensões
W, H = qr_img.size

logo_max = int(W * 0.18)
logo.thumbnail((logo_max, logo_max), Image.Resampling.LANCZOS)

# Fundo branco um pouco maior que o logo
padding = int(W * 0.015)

box_w = logo.width + 2 * padding
box_h = logo.height + 2 * padding

x0 = (W - box_w) // 2
y0 = (H - box_h) // 2
x1 = x0 + box_w
y1 = y0 + box_h

draw = ImageDraw.Draw(qr_img)

draw.rounded_rectangle(
    (x0, y0, x1, y1),
    radius=padding,
    fill="white"
)

# Logo centralizado
logo_x = (W - logo.width) // 2
logo_y = (H - logo.height) // 2

qr_img.paste(
    logo,
    (logo_x, logo_y),
    logo
)

qr_img.save("qrcode_logo_restaurantes.png")