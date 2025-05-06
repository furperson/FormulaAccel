
// Q = ((a_in - b_in) * (1 + 3c) - 4d) / 2

module QAccel #(
    parameter DATA_WIDTH = 32 
) (
    input logic clk,
    input logic reset, 
    input logic valid_in,  

    input logic signed [DATA_WIDTH-1:0] a_in,
    input logic signed [DATA_WIDTH-1:0] b_in,
    input logic signed [DATA_WIDTH-1:0] c_in,
    input logic signed [DATA_WIDTH-1:0] d_in,

    output logic signed [2*DATA_WIDTH-1:0] q_out,
    output logic valid_out                         
);

    // Расчет промежуточных ширин
    // Рассчитываем ширину, чтобы избежать переполнения на каждом шаге
    localparam T1_WIDTH = DATA_WIDTH;                      // a_in - b_in
    localparam T2_WIDTH = DATA_WIDTH + 2;                  // 3 * c_in 
    localparam T3_WIDTH = DATA_WIDTH + 2;                  // 4 * d_in
    localparam T4_WIDTH = T2_WIDTH + 1;                    // 1 + t2 
    localparam T5_WIDTH = T1_WIDTH + T4_WIDTH;             // t1 * t4 
    localparam T6_WIDTH = T5_WIDTH + 1;                    // t5 - t3 
    localparam Q_WIDTH  = T6_WIDTH - 1;                    // t6 / 2 

        // Инстанцирование конвейерного умножителя
    mult #(
        .DATA_WIDTH (DATA_WIDTH)
    ) mult_inst (
        .clk       (clk),
        .reset     (reset),
        .valid_in    (1'b1), // Начинаем умножение, когда готовы операнды t1_s3, t4_s3
        .a_in      (t1_s3),
        .b_in      (t4_s3),
        .p_out     (t5_s4), // Результат умножения t5
        .valid_out (valid_from_mult) // Валидность результата t5
    );

    // Сигналы конвейерных регистров

    // Стадия 1: Регистрация входных данных
    logic signed [DATA_WIDTH-1:0] a_s1, b_s1, c_s1, d_s1;
    logic valid_s1 = 1'b0;

    // Стадия 2: Результаты первых параллельных вычислений
    logic signed [T1_WIDTH-1:0] t1_s2; // a_in - b_in
    logic signed [T2_WIDTH-1:0] t2_s2; // 3 * c_in
    logic signed [T3_WIDTH-1:0] t3_s2; // 4 * d_in
    logic valid_s2 = 1'b0;

    // Стадия 3: Результат t4 = 1 + t2, и проброс остальных операндов
    logic signed [T1_WIDTH-1:0] t1_s3; // проброс t1
    logic signed [T4_WIDTH-1:0] t4_s3; // 1 + t2
    logic signed [T3_WIDTH-1:0] t3_s3; // проброс t3
    logic valid_s3 = 1'b0;

    // Стадия 4: Результат умножения t5 = t1 * t4, и проброс t3
    logic signed [T5_WIDTH-1:0] t5_s4; // t1 * t4 (основное умножение)
    logic signed [T3_WIDTH-1:0] t3_s4; // проброс t3
    logic valid_s4 = 1'b0;

    // Стадия 5: Результат вычитания t6 = t5 - t3
    logic signed [T6_WIDTH-1:0] t6_s5; // t5 - t3
    logic valid_s5 = 1'b0;

    // Выходной регистр (после деления/сдвига)
    logic signed [Q_WIDTH-1:0] q_reg;
    logic valid_reg = 1'b0;


    // Логика конвейера
    always_ff @(posedge clk ) begin
        if (reset) begin
            valid_s1   <= 1'b0;
            a_s1       <= '0;
            b_s1       <= '0;
            c_s1       <= '0;
            d_s1       <= '0;

            valid_s2   <= 1'b0;
            t1_s2      <= '0;
            t2_s2      <= '0;
            t3_s2      <= '0;

            valid_s3   <= 1'b0;
            t1_s3      <= '0;
            t4_s3      <= '0;
            t3_s3      <= '0;

            valid_s4   <= 1'b0;
            // t5_s4      <= '0;
            t3_s4      <= '0;

            valid_s5   <= 1'b0;
            t6_s5      <= '0;

            valid_reg  <= 1'b0;
            q_reg      <= '0;
        end else begin
            // Стадия 1: Регистрация входов при valid_in = 1
            valid_s1 <= valid_in; // Передаем сигнал valid_inble дальше как valid
            if (valid_in) begin
                a_s1 <= a_in;
                b_s1 <= b_in;
                c_s1 <= c_in;
                d_s1 <= d_in;
            end
            //Стадия 2: Вычисление t1, t2, t3
            valid_s2 <= valid_s1; // Продвигаем valid
            if (valid_s1) begin 
                // t1 = a_in - b_in (ширина T1_WIDTH = DATA_WIDTH)
                t1_s2 <= a_s1 - b_s1;

                // t2 = 3 * c_in 
                t2_s2 <= T2_WIDTH'((c_s1 <<< 1) + c_s1);

                // t3 = 4 * d_in
                t3_s2 <= T3_WIDTH'(d_s1 <<< 2);
            end

            // Стадия 3: Вычисление t4 = 1 + t2
            valid_s3 <= valid_s2; // Продвигаем valid
            if (valid_s2) begin
                // t4 = 1 + t2
                t4_s3 <= T4_WIDTH'(1) + T4_WIDTH'(t2_s2);

                // Проброс t1 и t3 на следующую стадию
                t1_s3 <= t1_s2;
                t3_s3 <= t3_s2;
            end

            // Стадия 4: Вычисление t5 = t1 * t4 (умножение)
            valid_s4 <= valid_s3; // Продвигаем valid
            if (valid_s3) begin
                // t5 = t1 * t4

                // Проброс t3 на следующую стадию
                t3_s4 <= t3_s3;
            end

            // Стадия 5: Вычисление t6 = t5 - t3 (вычитание)
            valid_s5 <= valid_s4; // Продвигаем valid
            if (valid_s4) begin
                // t6 = t5 - t3
                t6_s5 <= T6_WIDTH'(t5_s4) - T6_WIDTH'(t3_s4);
            end

            // Выходная стадия: Вычисление Q = t6 / 2 и регистрация
            valid_reg <= valid_s5; // Продвигаем valid на выход
            if (valid_s5) begin
                // Q = t6 / 2 (арифметический сдвиг вправо на 1)
                q_reg <= t6_s5 >>> 1;
            end
        end
    end

    assign q_out     = q_reg;       // Выдаем зарегистрированное значение Q
    assign valid_out = valid_reg;   // Выдаем зарегистрированный сигнал valid

endmodule