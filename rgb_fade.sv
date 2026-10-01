// rgb_fade

module rgb_fade #(
    parameter STATE_INTERVAL = 2000000, // how many clk cycles before state change
    parameter INC_DEC_MAX = 200, // how many times to inc/dec rgb intensity per state
    parameter PWM_INTERVAL = 1200, // how long a pwm interval is
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX // how much to inc/dec intensity per step
)(
    input logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B

);
    // inc/dec pwm values every step (10,000 clk cycles), 200 steps in one state
    localparam STEP_CYCLES = STATE_INTERVAL / INC_DEC_MAX; // how many clk cycles before new step

    logic [$clog2(PWM_INTERVAL) - 1:0]
        red_pwm_value = PWM_INTERVAL,
        green_pwm_value = 0,
        blue_pwm_value = 0;

    logic [$clog2(STEP_CYCLES) - 1:0] count = 0;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_count = 0;
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] step = 0;

    logic [2:0] state = 0;
    logic [1:0] red_state, blue_state, green_state;
    logic time_to_step;

    // pulses high at each step, indicating to reset count and increase step by 1
    assign time_to_step = (count == STEP_CYCLES - 1);

    // cycles count btwn 0-9999 on clk, step btwn 0-199 on count reset, and state 0-5 on step reset
    always_ff @(posedge clk) begin
        if (time_to_step) begin
            count <= 0;
            if (step == INC_DEC_MAX - 1) begin
                step <= 0;
                state <= (state == 5) ? 0 : state + 1;
            end
            else
                step <= step + 1;
        end
        else
            count <= count + 1;
    end

    // for each color, change their state to hold, decreasing, or increasing depending on state
    always_comb begin
        case (state)
            3'd0: begin
                red_state = 0; blue_state = 0; green_state = 1;
            end
            3'd1: begin
                red_state = 2; blue_state = 0; green_state = 0;
            end
            3'd2: begin
                red_state = 0; blue_state = 1; green_state = 0;
            end
            3'd3: begin
                red_state = 0; blue_state = 0; green_state = 2;
            end
            3'd4: begin
                red_state = 1; blue_state = 0; green_state = 0;
            end
            3'd5: begin
                red_state = 0; blue_state = 2; green_state = 0;
            end
            default: begin
                red_state = 0; blue_state = 0; green_state = 0;
            end
        endcase
    end

    // inc/dec PWM value every step
    always_ff @(posedge clk) begin
        if (time_to_step) begin
            case (red_state)
                2'd1: red_pwm_value <= red_pwm_value + INC_DEC_VAL;
                2'd2: red_pwm_value <= red_pwm_value - INC_DEC_VAL;
                default: ;
            endcase

            case (blue_state)
                2'd1: blue_pwm_value <= blue_pwm_value + INC_DEC_VAL;
                2'd2: blue_pwm_value <= blue_pwm_value - INC_DEC_VAL;
                default: ;
            endcase

            case (green_state)
                2'd1: green_pwm_value <= green_pwm_value + INC_DEC_VAL;
                2'd2: green_pwm_value <= green_pwm_value - INC_DEC_VAL;
                default: ;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (pwm_count == PWM_INTERVAL - 1)
            pwm_count <= 0;
        else
            pwm_count <= pwm_count + 1;
    end

    // LED is on while count < value
    assign RGB_R = ~(pwm_count < red_pwm_value);
    assign RGB_G = ~(pwm_count < green_pwm_value);
    assign RGB_B = ~(pwm_count < blue_pwm_value);

endmodule
