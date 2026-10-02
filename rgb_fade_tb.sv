`timescale 1ns/1ns

module rgb_fade_tb;

    logic clk = 0;
    logic RGB_R, RGB_G, RGB_B;

    rgb_fade u0 (
        .clk    (clk),
        .RGB_R  (RGB_R),
        .RGB_G  (RGB_G),
        .RGB_B  (RGB_B)
    );

    // ~12 MHz clock
    always #42 clk = ~clk;

    // print PWM values every time the state changes
    always @(u0.state)
        $display("t = %4d ms  state = %0d  R = %4d  G = %4d  B = %4d",
                 $time / 1000000, u0.state, u0.red_pwm_value, u0.green_pwm_value, u0.blue_pwm_value);

    initial begin
        $dumpfile("rgb_fade.vcd");
        $dumpvars(0, RGB_R, RGB_G, RGB_B, u0.state, u0.red_pwm_value, u0.green_pwm_value, u0.blue_pwm_value);
        #1100000000;    // 1.1 s: one full cycle plus a bit
        $finish;
    end

endmodule
