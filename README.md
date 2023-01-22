# VUG2-Asteroids
Asteroids game for the VectorUGo-2 console

This is a simple and classic Asteroids arcade game for the VectorUGo-2 console. It has been written in Forth, using the new version of the ZTH1-Forth compiler that allows to compile code for VectorUGo-2. This game has actually been developed to debug the VectorUGo-2 OS and the updated ZTH1-Forth compiler and all the levels are the same. Therefore, it is probably not as fun as Minestorm on Vectrex ;-) .

Use the console joystick as follows:
* Right: rotate spaceship clockwise.
* Left: rotate spaceship counterclockwise.
* Up: increase thrust of spaceship (spaceship will brake whenever joystick is released).
* Down: jump into hyperspace (spaceship will reappear at random position).
* Fire: launch a missile. 

Note: to moderate display flickering, it is recommended to increase the clock frequency of the vector-display interface of VectorUGo-2 fro 166 kHz to 250 kHz (by modifying the clock 1 output of the IP in clocks.vhd). This leads to adjust the x and y amplification of the display device to get an optimal image size.
