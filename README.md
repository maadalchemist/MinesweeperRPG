![icon](https://github.com/maadalchemist/MinesweeperRPG/blob/main/doc/icon.png?raw=true)

# Minesweeper RPG

Minesweeper RPG is a game where you control an actual ship out sweeping mines. Rather than the traditional, limited map size, this game features a procedurally generated map, turning a time trial game into an endless arcade game.

This project was a way for me to explore data structures, procedural generation, and shaders. This was NOT a project focused on visual assets. As such, all graphics are only barely above the bare minimum in terms of visual appeal. THis may change in the future, but for now, it looks as is.

## How to play
The arrow keys are used for movement. The up and down arrow keys move the craft forward and backwards, and the left and right arrow keys turn the craft. A tile in front of the ship if marked in yellow. 

![target_reference](https://github.com/maadalchemist/MinesweeperRPG/blob/main/doc/target_reference_screencap.png)

Clicking 'z' will reveal that tile, and clicking 'x' will flag that tile. 

 A revealed tile will display how many mines are adjacent to it. The play must use that information to determine where mines are and either flag them or avoid revealing them.

## Generation Proccess

After messing around with several generation ideas, the solution i landed on was chunk based using two-dimentional simplex noise. The world is divided into tiles 16x16 in size. A dictionary stores the identity of every tile, with states of "SAFE", "ONE", "TWO", ... "EIGHT", and "MINE". These tiles are further bunched into chunks, which contain 16x16 tiles. A separate dictionary contains the generation status of chunks, with states of "RED", "YELLOW", and "GREEN". 

A chunk in the "RED" state is completely blank. To become "YELLOW" it gets populated with mines according to a simplex noise pattern generated at the start of the game. However, the edges of these chunks would be calulated incorrectly if a real query were to occur, so to complete generation and become "GREEN", all neighboring tiles must be either "YELLOW" or "GREEN".

when the chunk dicitonaries are exported as a png image, you can get an idea of how these chunks work:

![chunk_visualization](https://github.com/maadalchemist/MinesweeperRPG/blob/main/doc/chunk_generation_visualization.png)

## Shaders

The water shader took a ton of work. It is completely procedurally generated with no input textures. Only pure math. 

First the shader transforms the UV position of the object into worldspace coordinates. This is so that the water object being shaded can be limited to just the camera space, but still seem to move independantly of the camera. In order to make the shader tileable, the shader then determins the tile the current pixel resides in. It will then generate a random point in the tile, and move that point periodically with time. The shader then goes through neighboring tiles, including the current tile, in order to determin the closest point to the currently rendering pixel, with white being farther and black being nearer. The brightness of the pixel is then determined based on the distance to the nearest point. This black and white value is then shifted to color, with white being adjusted towards one color and black towards another.

There is also a grid shader to differentiate tiles, which uses the same tiling techniques of the water shader.

## Class Diagram

Only variables and methods I created are presented in this diagram, becasue we would be here all day if I listed what the Godot engine handles. In addition, any simple methods or variables are left out in order to present important methods more prominantly. Also, because GDScript is a dynamic language, return types have been left off of methods as many of them are dynamic in nature

![class_diagram](https://github.com/maadalchemist/MinesweeperRPG/blob/main/doc/class_diagram.png)
