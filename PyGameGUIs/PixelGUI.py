import pygame
import time
from pythonosc import udp_client

# --- Setup OSC client ---
ip = "127.0.0.1"   # SuperCollider usually listens locally
port = 57120       # Default SC port
osc_client = udp_client.SimpleUDPClient(ip, port)

# --- Setup PyGame ---
pygame.init()
screen_size = (1024, 570)
screen = pygame.display.set_mode(screen_size)
pygame.display.set_caption("Bitmap OSC Grid with Temporary Swap")

# Grid setup
rows, cols = 8, 8
cell_size = screen_size[0] // cols  # assume square window

# Load images
background = pygame.image.load("/Users/jacobwesterstahl/Downloads/Industrial2Pixel.jpeg").convert()
background = pygame.transform.scale(background, screen_size)

overlay = pygame.image.load("/Users/jacobwesterstahl/Downloads/Industrial2.jpeg").convert()
overlay = pygame.transform.scale(overlay, screen_size)

# Track active swaps: dictionary {(grid_x, grid_y): end_time}
active_swaps = {}

running = True
clock = pygame.time.Clock()

while running:
    current_time = time.time()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        elif event.type == pygame.MOUSEBUTTONDOWN:
            x, y = event.pos
            grid_x = x // cell_size
            grid_y = y // cell_size

            # Send OSC message with coordinates
            osc_client.send_message("/grid", [grid_x, grid_y])
            print(f"Clicked cell ({grid_x}, {grid_y}) -> sent OSC")

            # Mark this cell as swapped for 2 seconds
            active_swaps[(grid_x, grid_y)] = current_time + 2.0

    # Draw the full background
    screen.blit(background, (0, 0))

    # Draw swapped cells
    for (gx, gy), end_time in list(active_swaps.items()):
        if current_time < end_time:
            # compute rectangle for this grid cell
            rect = pygame.Rect(gx * cell_size, gy * cell_size, cell_size, cell_size)
            # copy just that region from overlay
            cell_surface = overlay.subsurface(rect)
            screen.blit(cell_surface, rect)
        else:
            # remove expired swaps
            del active_swaps[(gx, gy)]

    # Optional: draw grid lines
    for row in range(rows):
        for col in range(cols):
            rect = pygame.Rect(col*cell_size, row*cell_size, cell_size, cell_size)
            pygame.draw.rect(screen, (255, 255, 255), rect, 1)

    pygame.display.flip()
    clock.tick(60)  # limit to 60fps

pygame.quit()
