import pygame
from pythonosc import udp_client
import math

# --- Setup OSC client ---
ip = "127.0.0.1"   # SuperCollider usually listens locally
port = 57120       # Default SC port
osc_client = udp_client.SimpleUDPClient(ip, port)

# --- Setup PyGame ---
pygame.init()
screen_size = (1024, 600)
screen = pygame.display.set_mode(screen_size)
pygame.display.set_caption("Bitmap OSC Grid")

# --- Grid setup ---
#might be helpful when running multiple different soundscapes
'''Find the largest square size that fits the whole screen exactly
def gcd(a, b):
    while b:
        a, b = b, a % b
    return a
'''
square_size = 50
cols = screen_size[0] // square_size
rows = screen_size[1] // square_size

# Load and scale bitmap
background = pygame.image.load("Industrial.jpg")  # CHANGE THIS IMAGE!!!!!
background = pygame.transform.scale(background, screen_size)

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        elif event.type == pygame.MOUSEBUTTONDOWN:
            x, y = event.pos
            grid_x = x // square_size
            grid_y = y // square_size

            # Send OSC message with coordinates
            osc_client.send_message("/grid", [grid_x, grid_y])
            print(f"Clicked cell ({grid_x}, {grid_y}) -> sent OSC")

    # Draw background
    screen.blit(background, (0, 0))

    # Draw grid lines
    for row in range(rows):
        for col in range(cols):
            rect = pygame.Rect(col * square_size, row * square_size, square_size, square_size)
            pygame.draw.rect(screen, (255, 255, 255), rect, 1)

    pygame.display.flip()

pygame.quit()
