import pygame
import sys

# Initialize pygame and mixer
pygame.init()
pygame.mixer.init()

# Screen setup
WIDTH, HEIGHT = 1024, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("BIKES Interface 1.0")

# Load background image
# Replace with your image file, make sure it's the right size
background = pygame.image.load("industrial.jpg")
background = pygame.transform.scale(background, (WIDTH, HEIGHT))

# Define clickable regions (x, y, w, h) + sound
class SoundZone:
    def __init__(self, rect, sound_file):
        self.rect = pygame.Rect(rect)
        try:
            self.sound = pygame.mixer.Sound(sound_file)
        except pygame.error as e:
            print(f"⚠️ Could not load sound {sound_file}: {e}")
            self.sound = None

    def check_click(self, pos):
        if self.rect.collidepoint(pos) and self.sound:
            self.sound.play()


# Define zones (adjust these to your image layout)
zones = [
    SoundZone((0, 0, WIDTH//2, HEIGHT//2), "traffic.mp3"),     # top-left
    SoundZone((WIDTH//2, 0, WIDTH//2, HEIGHT//2), "woosh.mp3"),  # top-right
    SoundZone((0, HEIGHT//2, WIDTH//2, HEIGHT//2), "MachineArm1.wav"), # bottom-left
    SoundZone((WIDTH//2, HEIGHT//2, WIDTH//2, HEIGHT//2), "SoundEffect1.wav"), # bottom-right
]

# Main loop
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
            running = False
        elif event.type == pygame.MOUSEBUTTONDOWN:
            for zone in zones:
                zone.check_click(event.pos)

    # Draw background
    screen.blit(background, (0, 0))

    pygame.display.flip()

pygame.quit()
sys.exit()
