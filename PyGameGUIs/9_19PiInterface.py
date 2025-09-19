import pygame
from pythonosc import udp_client

# --- Setup OSC client ---
ip = "127.0.0.1"   # SuperCollider usually listens locally
port = 57120       # Default SC port
osc_client = udp_client.SimpleUDPClient(ip, port)

# --- Setup PyGame ---
pygame.init()
screen_size = (846, 457)
screen = pygame.display.set_mode(screen_size)
pygame.display.set_caption("Bitmap OSC Grid")

# --- Grid setup ---
square_size = 25
cols = screen_size[0] // square_size
rows = screen_size[1] // square_size

grid_width = cols * square_size
grid_height = rows * square_size

# Offsets to center the grid
offset_x = (screen_size[0] - grid_width) // 2
offset_y = (screen_size[1] - grid_height) // 2

# Try to load background image
try:
    background = pygame.image.load("Industrial.jpg")  # <-- replace with your file
    background = pygame.transform.scale(background, screen_size)
    print("Background image loaded successfully.")
except Exception as e:
    print(f"Could not load background image: {e}")
    background = None

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        elif event.type == pygame.MOUSEBUTTONDOWN:
            x, y = event.pos
            # Adjust for offsets
            grid_x = (x - offset_x) // square_size
            grid_y = (y - offset_y) // square_size

            if 0 <= grid_x < cols and 0 <= grid_y < rows:
                # Send OSC message with coordinates
                osc_client.send_message("/grid", [grid_x, grid_y])
                print(f"Clicked cell ({grid_x}, {grid_y}) -> sent OSC")
            else:
                print("Clicked outside the grid")

    # Draw background (or fallback color)
    if background:
        screen.blit(background, (0, 0))
    else:
        screen.fill((0, 0, 0))  # fallback: black

    # Draw grid lines with offsets
    for row in range(rows):
        for col in range(cols):
            rect = pygame.Rect(
                offset_x + col * square_size,
                offset_y + row * square_size,
                square_size,
                square_size
            )
            pygame.draw.rect(screen, (255, 255, 255), rect, 1)

    pygame.display.flip()

pygame.quit()
