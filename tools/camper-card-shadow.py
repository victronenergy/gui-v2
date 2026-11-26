#!/usr/bin/env python3
#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Generates images/camper/camper_card_shadow.png, the RV cards' drop shadow, as a 9-slice image.
# A pre-blurred image is used because a blur effect would cost a shader pass per card.
#
# Usage: tools/camper-card-shadow.py [output.png]
# Rerun it if the card radius or the design's shadow changes, and update the matching constants in
# components/camper/CamperDomainCard.qml.

import sys

from PIL import Image, ImageDraw, ImageFilter

# From the "Custom Illustrations" design, in design px. Figma's blur is twice the Gaussian sigma.
CARD_RADIUS = 8
SHADOW_BLUR = 4
SHADOW_OPACITY = 0.3

# Image px per design px, so that the shadow stays smooth when the scene is scaled up.
SCALE = 8

sigma = SHADOW_BLUR / 2
# The blur fades out within 3 sigma of the card's edge.
margin = 3 * sigma
# Each 9-slice border holds the outer fade plus the rounded corner, or the inner fade if wider.
border = margin + max(CARD_RADIUS, margin)
# One design px of flat middle between the borders.
size = int((2 * border + 1) * SCALE)

# Draw the card shape 4x oversampled for smooth corners, then blur it.
oversample = 4
shape = Image.new("L", (size * oversample, size * oversample), 0)
inset = margin * SCALE * oversample
ImageDraw.Draw(shape).rounded_rectangle(
    (inset, inset, size * oversample - inset - 1, size * oversample - inset - 1),
    radius=CARD_RADIUS * SCALE * oversample,
    fill=255,
)
shape = shape.resize((size, size), Image.LANCZOS)
shape = shape.filter(ImageFilter.GaussianBlur(sigma * SCALE))

alpha = shape.point(lambda v: round(v * SHADOW_OPACITY))
shadow = Image.new("LA", (size, size), 0)
shadow.putalpha(alpha)

output = sys.argv[1] if len(sys.argv) > 1 else "images/camper/camper_card_shadow.png"
shadow.save(output, optimize=True)
print(f"{output}: {size}x{size} px, border {int(border * SCALE)} px, margin {margin} design px, "
      f"scale {SCALE}")
