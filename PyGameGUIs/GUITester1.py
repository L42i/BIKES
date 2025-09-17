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

# Optional: load an image for each cell
cell_images = []
for i in range(rows * cols):
    img = pygame.Surface((cell_size, cell_size))
    img.fill((50 + (i*20) % 200, 100, 150))  # just colored blocks for now
    cell_images.append(img)

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        
        elif event.type == pygame.MOUSEBUTTONDOWN:
            x, y = event.pos
            grid_x = x // cell_size
            grid_y = y // cell_size
            
            # Send OSC message to SC
            osc_client.send_message("/grid", [grid_x, grid_y])
            print(f"Clicked cell ({grid_x}, {grid_y}) -> sent OSC")

    # Draw grid
    for row in range(rows):
        for col in range(cols):
            idx = row * cols + col
            rect = pygame.Rect(col*cell_size, row*cell_size, cell_size, cell_size)
            screen.blit(cell_images[idx], rect)

            # draw grid lines
            pygame.draw.rect(screen, (255,255,255), rect, 1)

    pygame.display.flip()

pygame.quit()
