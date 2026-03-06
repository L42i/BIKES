import pygame
import time
from pythonosc import udp_client
import os
import sys

soundscape = "marine"

if len(sys.argv) > 1:
    soundscape = sys.argv[1]

# --- Setup OSC client ---
ip = "127.0.0.1"   # SuperCollider usually listens locally
port = 57120       # Default SC port
osc_client = udp_client.SimpleUDPClient(ip, port)

# --- Setup PyGame ---
pygame.init()
screen_size = (1024, 570)
screen = pygame.display.set_mode(screen_size)
pygame.display.set_caption("Bitmap OSC Grid")

# Grid setup
rows, cols = 3, 5
cell_w = screen_size[0] // cols  # 204
cell_h = screen_size[1] // rows  # 190

# Load images
base = os.path.dirname(os.path.abspath(__file__))
background = pygame.image.load(os.path.join(base,"/Users/jacobwesterstahl/Downloads/igpostjan26/DSC03498.JPG")).convert()
background = pygame.transform.scale(background, screen_size)

overlay = pygame.image.load(os.path.join(base, "/Users/jacobwesterstahl/Downloads/igpostjan26/DSC03498.JPG")).convert()
overlay = pygame.transform.scale(overlay, screen_size)

# Track active swaps: dict {(gx, gy): end_time}
active_swaps = {}

running = True
clock = pygame.time.Clock()


# --- Setup ---
INACTIVITY_EVENT = pygame.USEREVENT + 1
pygame.time.set_timer(INACTIVITY_EVENT, 15000) # 15 seconds
inactive = True # Start on the tap screen

pygame.font.init()
font = pygame.font.SysFont(None, 64)
text_surf = font.render("TAP TO START...", True, (255, 255, 255))
text_rect = text_surf.get_rect(center=(screen_size[0] // 2, screen_size[1] // 2))

while running:
    current_time = pygame.time.get_ticks()
    
    # 1. EVENT HANDLING
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        elif event.type == pygame.MOUSEBUTTONDOWN:
            # If we were inactive, a click wakes us up
            inactive = False
            # Reset the 15s timer
            pygame.time.set_timer(INACTIVITY_EVENT, 15000)
            
            # Grid Logic
            x, y = event.pos
            gx = min(cols - 1, max(0, x // cell_w))
            gy = min(rows - 1, max(0, y // cell_h))

            # Send OSC message with coordinates
            osc_client.send_message("/grid", [int(gx), int(gy)])
            print(f"Clicked cell ({gx}, {gy}) -> sent OSC")

            # Mark this cell as swapped for 2 seconds
            active_swaps[(int(gx), int(gy))] = current_time + 2000

        elif event.type == INACTIVITY_EVENT:
            inactive = True

    # 2. DRAWING 
    if inactive:
        screen.fill((0, 0, 0))
        screen.blit(text_surf, text_rect)
    else:
        # Draw Background
        screen.blit(background, (0, 0))

        # Draw swapped cells
        for (gx, gy), end_time in list(active_swaps.items()):
            if current_time < end_time:
                rect = pygame.Rect(gx * cell_w, gy * cell_h, cell_w, cell_h)
                cell_surface = overlay.subsurface(rect)
                screen.blit(cell_surface, rect)
            else:
                del active_swaps[(gx, gy)]

        # Draw grid lines
        for r in range(rows):
            for c in range(cols):
                rect = pygame.Rect(c * cell_w, r * cell_h, cell_w, cell_h)
                pygame.draw.rect(screen, (255, 255, 255), rect, 1)

    pygame.display.flip()
    clock.tick(60)

pygame.quit()
