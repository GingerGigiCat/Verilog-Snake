

/*
 * Copyright (c) 2024 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

localparam UP = 2'd0, RIGHT = 2'd1, DOWN = 2'd2, LEFT = 2'd3;



module tt_um_vga_snake_gingergigicat(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  reg [9:0] counter;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  reg [5:0] snake [19:0]; // 100 length snake, 4 bits x,  4 bits y, top left corner is (0, 0)
  reg [5:0] food;
  reg [5:0] snake_length = 3;
  reg game_running = 1;
  wire [1:0] snake_direction;
  assign snake_direction = ui_in[1:0];



  always @(posedge vsync, negedge rst_n) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end


  always @(posedge counter[1]) begin
    integer advancer_i;
    var [7:0] new_head;
    if (game_running) begin
      case (snake_direction)
        UP: new_head = {snake[0][5:3], snake[0][2:0]-3'd1};
        RIGHT: new_head = {snake[0][5:3]+3'd1, snake[0][2:0]};
        DOWN: new_head = {snake[0][5:3], snake[0][2:0]+3'd1};
        LEFT: new_head = {snake[0][5:3]-3'd1, snake[0][2:0]};
      endcase
      if (new_head == food) begin
        snake_length = snake_length + 1;
        food = {counter[6], counter[1], counter[4], counter[3], counter[0], counter[5]};
      end
    

      for (advancer_i = 19; advancer_i > 0; advancer_i = advancer_i-1) begin
        if (advancer_i < snake_length+1) begin
          snake[advancer_i] = snake[advancer_i-1];
          if ((new_head == snake[advancer_i]) && (advancer_i != snake_length || snake_length == 3))
            game_running = 0;
        end
      end
      snake[0] = new_head;
    end
  end

  always @(posedge clk) begin
    integer drawer_i;

    G = 2'b00;
    R = 2'b00;
    B = 2'b00;


    if (video_active) begin
      for (drawer_i = 20; drawer_i > 0; drawer_i = drawer_i-1) begin
        if (drawer_i < snake_length+1)
        if ((pix_x[8:6] == snake[drawer_i][5:3]) && (pix_y[8:6] == snake[drawer_i][2:0])) begin
          G = 2'b10;
          if (!game_running) begin
            G = 2'b01;
            R = 2'b01;
            B = 2'b01;
          end

        end
      end
      if ((pix_x[8:6] == food[5:3]) && (pix_y[8:6] == food[2:0])) begin
        R = 2'b10;
      end
    end
    else begin
      G = 2'b00;
      R = 2'b00;
      B = 2'b00;
    end
  end


  // Suppress unused signals warning
  wire _unused_ok_ = &{pix_y, snake_length};

endmodule
