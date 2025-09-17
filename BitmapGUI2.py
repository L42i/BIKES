import pygame
from pythonosc import udp_client

# --- Setup OSC client ---
ip = "127.0.0.1"   # SuperCollider usually listens locally
port = 57120       # Default SC port
osc_client = udp_client.SimpleUDPClient(ip, port)

# --- Setup PyGame ---
pygame.init()
screen_size = (640, 640)
screen = pygame.display.set_mode(screen_size)
pygame.display.set_caption("Bitmap OSC Grid")

# Grid setup
rows, cols = 8, 8
cell_size = screen_size[0] // cols  # assume square window

# Load one large bitmap
background = pygame.image.load("INSERT IMAGE")  # your bitmap here
background = pygame.transform.scale(background, screen_size)

running = True
while running:
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

    # Draw the bitmap background
    screen.blit(background, (0, 0))

    # Optional: draw grid lines on top of bitmap
    for row in range(rows):
        for col in range(cols):
            rect = pygame.Rect(col*cell_size, row*cell_size, cell_size, cell_size)
            pygame.draw.rect(screen, (255, 255, 255), rect, 1)

    pygame.display.flip()

pygame.quit()
