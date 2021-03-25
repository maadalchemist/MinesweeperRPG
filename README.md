![icon](https://github.com/maadalchemist/MinesweeperRPG/blob/main/doc/icon.png?raw=true)

# Minesweeper RPG

Minesweeper RPG is a game where you control an actual ship out sweeping mines. Rather than the traditional, limited map size, this game features a procedurally generated map, turning a time trial game into an endless arcade game

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

## Class Diagram
