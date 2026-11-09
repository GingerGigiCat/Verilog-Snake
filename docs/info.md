<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project has an array of regs that stored each cell of the snake, each is 8 bits allowing a 16x16 grid. Every few frames, the snake cells are shifted along by one, and the new head position is calculated and compared against the current food position, and all the other parts of the body. If the new head overlaps the body, the snake goes grey and stops moving to show game over, and if the new head is at the position of food, the snake length increases by 1. The food location is pseudo-random, using some bits of the counter.

## How to test

Try it out at https://vga-playground.com/?repo=https://github.com/GingerGigiCat/Verilog-Snake/

To run tests, do:

```bash
git clone https://github.com/GingerGigiCat/Verilog-Snake/
cd Verilog-Snake/test
make
```

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
