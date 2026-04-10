import pygame
import sys
from pythonosc import udp_client

# --- OSC ---
osc_client = udp_client.SimpleUDPClient("127.0.0.1", 57120)

# --- Music ---
NOTES = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
SCALES = {
    "Major":      [0,2,4,5,7,9,11],
    "Minor":      [0,2,3,5,7,8,10],
    "Dorian":     [0,2,3,5,7,9,10],
    "Mixolydian": [0,2,4,5,7,9,10],
}
QUALITIES = {
    "Major":      ["maj","min","min","maj","maj","min","dim"],
    "Minor":      ["min","dim","maj","min","min","maj","maj"],
    "Dorian":     ["min","min","maj","maj","min","dim","maj"],
    "Mixolydian": ["maj","min","dim","maj","min","min","maj"],
}
CHORD_SEMIS = {"maj":[0,4,7], "min":[0,3,7], "dim":[0,3,6]}
ROMAN = ["I","II","III","IV","V","VI"]

def get_chord(root, scale, degree, octave=4):
    semi = SCALES[scale][degree]
    qual = QUALITIES[scale][degree]
    return [(octave+1)*12 + root + semi + i for i in CHORD_SEMIS[qual]]

def pad_label(root, scale, degree):
    semi = SCALES[scale][degree]
    qual = QUALITIES[scale][degree]
    note = NOTES[(root + semi) % 12]
    suffix = "" if qual == "maj" else ("m" if qual == "min" else "°")
    roman = ROMAN[degree] if qual == "maj" else ROMAN[degree].lower()
    return f"{roman}  {note}{suffix}"

# --- Pygame ---
pygame.init()
W, H = 900, 640
screen = pygame.display.set_mode((W, H))
pygame.display.set_caption("Chord Grid")
clock = pygame.time.Clock()
font_big = pygame.font.SysFont("Arial", 28, bold=True)
font_sm  = pygame.font.SysFont("Arial", 14)

# State
root       = 0
scale      = "Major"
active     = -1
root_open  = False
scale_open = False

HEADER = 70
PAD    = 16
GAP    = 10

def pad_rects():
    gw = W - 2*PAD
    gh = H - HEADER - PAD
    pw = (gw - GAP) // 3
    ph = (gh - GAP) // 2
    rects = []
    for i in range(6):
        c, r = i % 3, i // 3
        rects.append(pygame.Rect(PAD + c*(pw+GAP), HEADER + r*(ph+GAP), pw, ph))
    return rects

def draw_dropdown(surf, x, y, w, label, options, is_open):
    box = pygame.Rect(x, y, w, 34)
    pygame.draw.rect(surf, (30,30,28), box, border_radius=5)
    pygame.draw.rect(surf, (80,80,70), box, 1, border_radius=5)
    surf.blit(font_sm.render(label, True, (220,215,200)), (x+10, y+9))
    if is_open:
        for i, opt in enumerate(options):
            r = pygame.Rect(x, y+34+i*30, w, 30)
            pygame.draw.rect(surf, (40,40,36), r)
            pygame.draw.rect(surf, (70,70,60), r, 1)
            surf.blit(font_sm.render(opt, True, (220,215,200)), (r.x+10, r.y+7))

running = True
while running:
    screen.fill((14,14,12))
    mx, my = pygame.mouse.get_pos()
    rects = pad_rects()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
            running = False

        elif event.type == pygame.MOUSEBUTTONDOWN:
            clicked = False

            # root dropdown
            root_box = pygame.Rect(PAD, 18, 68, 34)
            if root_box.collidepoint(mx, my):
                root_open = not root_open; scale_open = False; clicked = True
            elif root_open:
                for i, n in enumerate(NOTES):
                    if pygame.Rect(PAD, 52+i*30, 68, 30).collidepoint(mx, my):
                        root = i; root_open = False; clicked = True
                if not clicked:
                    root_open = False; clicked = True

            # scale dropdown
            scale_box = pygame.Rect(PAD+78, 18, 140, 34)
            if not clicked and scale_box.collidepoint(mx, my):
                scale_open = not scale_open; root_open = False; clicked = True
            elif not clicked and scale_open:
                for i, s in enumerate(SCALES):
                    if pygame.Rect(PAD+78, 52+i*30, 140, 30).collidepoint(mx, my):
                        scale = s; scale_open = False; clicked = True
                if not clicked:
                    scale_open = False; clicked = True

            # pads
            if not clicked and not root_open and not scale_open:
                for i, rect in enumerate(rects):
                    if rect.collidepoint(mx, my) and active != i:
                        active = i
                        msg = [NOTES[root], scale, i+1]
                        osc_client.send_message("/chord", msg)
                        print(f"/chord {msg}")

        elif event.type == pygame.KEYDOWN:
            for idx, key in enumerate([pygame.K_1,pygame.K_2,pygame.K_3,pygame.K_4,pygame.K_5,pygame.K_6]):
                if event.key == key and active != idx:
                    active = idx
                    msg = [NOTES[root], scale, idx+1]
                    osc_client.send_message("/chord", msg)
                    print(f"/chord {msg}")

    # Draw pads
    for i, rect in enumerate(rects):
        is_active = active == i
        is_hover  = rect.collidepoint(mx, my) and not is_active
        bg = (50,46,36) if is_active else ((32,30,26) if is_hover else (22,21,18))
        bc = (200,165,100) if is_active else ((80,76,68) if is_hover else (42,40,36))
        pygame.draw.rect(screen, bg, rect, border_radius=8)
        pygame.draw.rect(screen, bc, rect, 1, border_radius=8)
        txt = font_big.render(pad_label(root, scale, i), True, (220,215,200))
        screen.blit(txt, (rect.centerx - txt.get_width()//2, rect.centery - txt.get_height()//2))
        screen.blit(font_sm.render(str(i+1), True, (60,58,54)), (rect.x+8, rect.y+8))

    # Draw dropdowns on top
    draw_dropdown(screen, PAD,    18, 68,  NOTES[root], NOTES,            root_open)
    draw_dropdown(screen, PAD+78, 18, 140, scale,       list(SCALES.keys()), scale_open)

    pygame.display.flip()
    clock.tick(60)

pygame.quit()
