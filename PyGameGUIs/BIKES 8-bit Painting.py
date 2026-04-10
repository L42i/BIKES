import pygame
import sys

# --- Initialize ---
pygame.init()
TILE_SIZE = 32
WIDTH, HEIGHT = 1024, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
clock = pygame.time.Clock()
pygame.display.set_caption("8-bit Handcrafted Tile Map")

# --- Colors (simulate 8-bit tiles) ---
GREEN = (34, 177, 76)   # grass
DARK_GREEN = (0, 100, 0) #grass pressed
BLUE = (0, 162, 232)    # water
DARK_BLUE = (0, 0, 180) # water pressed
GRAY = (127, 127, 127)  # wall
DARK_GRAY = (64, 64, 64) #wall pressed

# --- Map Layout ---
# 0 = grass, 1 = water, 2 = wall
game_map = [
    [0,0,0,1,1,1,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,1,0,1,0,0,0,0,0,0,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,1,1,1,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,1,1,1,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,1,0,1,0,0,0,0,0,0,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,1,1,1,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,2,0,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,2,2,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,2,0,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,2,0,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0],
    [0,0,0,0,0,0,0,1,0,0,2,2,2,0,1,0,2,2,2,0,1,1,1,0,2,2,2,0,0,1,0,0],
    [0,0,0,0,0,0,1,0,1,0,1,0,0,0,1,0,2,0,2,0,1,0,1,0,2,0,2,0,2,0,2,0],
    [0,0,0,0,0,0,0,1,0,0,2,0,0,0,1,0,2,2,2,2,1,0,1,0,2,2,2,0,0,1,0,0],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
]

# --- Draw Map Function ---
def draw_map():
    for row in range(len(game_map)):
        for col in range(len(game_map[row])):
            tile_type = game_map[row][col]
            if tile_type == 0:
                color = GREEN
            elif tile_type == 1:
                color = BLUE
            elif tile_type == 2:
                color = GRAY
            elif tile_type == 3:  # pressed water
                color = DARK_BLUE
            elif tile_type == 4:
                color = DARK_GREEN
            elif tile_type == 5:
                color = DARK_GRAY
            pygame.draw.rect(
                screen, 
                color, 
                (col * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE)
            )

# --- Main Game Loop ---
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
            running = False
        # Handle mouse clicks
        if event.type == pygame.MOUSEBUTTONDOWN:
            mouse_x, mouse_y = pygame.mouse.get_pos()
            col = mouse_x // TILE_SIZE
            row = mouse_y // TILE_SIZE

            # Toggle water color if clicked
            if game_map[row][col] == 1:      # normal water
                game_map[row][col] = 3       # turn into pressed water
            elif game_map[row][col] == 3:    # pressed water
                game_map[row][col] = 1       # back to normal water

            # Toggle grass color if clicked
            elif game_map[row][col] == 0:
                game_map[row][col] = 4
            elif game_map[row][col] == 4:    
                game_map[row][col] = 0

            # Toggle wall color if clicked
            if game_map[row][col] == 2:      # normal wall
                game_map[row][col] = 5     
            elif game_map[row][col] == 5:    
                game_map[row][col] = 2

    screen.fill((0, 0, 0))  # clear screen
    draw_map()              # draw handcrafted map

    pygame.display.flip()
    clock.tick(60)
