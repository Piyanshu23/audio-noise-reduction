module butterworth_fir_filter_tb;
    reg clk;
    reg reset;
    reg signed [15:0] in_sample;
    wire signed [15:0] out_sample;

    // Number of samples to read
    localparam NUM_SAMPLES = 64000;
    
    // Memory to hold the input samples
    reg signed [15:0] sample_memory [0:NUM_SAMPLES-1];

    // Counter for accessing samples
    integer i;

    // File descriptor for output samples
    integer out_file;

    // Load samples from text file
    initial begin
        $readmemb("arctic_a0001noise.data", sample_memory); // Ensure the file is in the correct directory
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period (100 MHz)
    end

    // Test process
    initial begin
        // Open the file to store output samples
        out_file = $fopen("filtered_output.data", "w");
        
        reset = 1;
        in_sample = 16'd0;
        #20; // Wait for 20 ns
        reset = 0;

        // Feed samples one by one to the filter
        for (i = 0; i < NUM_SAMPLES; i = i + 1) begin
            in_sample = sample_memory[i];
            #10; // Wait for one clock cycle for each sample

            // Write the filtered output sample in binary format to the file
            $fwrite(out_file, "%b\n", out_sample);
        end

        // Close the file after all samples are processed
        $fclose(out_file);

        // End simulation
        $finish;
    end

    // Monitor output for debugging (optional)
    initial begin
        $monitor("Time: %0t | Input Sample: %d | Filtered Output: %d", $time, in_sample, out_sample);
    end

    // Filter code directly within the testbench

    // Filter order (9th order, so 10 taps)
    localparam N = 10;

    // Hardcoded coefficients for the Butterworth FIR filter
    reg signed [15:0] coeffs [0:N-1];
    reg signed [15:0] sample_reg [0:N-1];
    reg signed [31:0] acc;
    integer j;

    // Initialize coefficients
    initial begin
        coeffs[0] = 16'b0000000011110010;
        coeffs[1] = 16'b0000100001111110;
        coeffs[2] = 16'b0010000111110111;
        coeffs[3] = 16'b0100111101000000;
        coeffs[4] = 16'b0111011011011111;
        coeffs[5] = 16'b0111011011011111;
        coeffs[6] = 16'b0100111101000000;
        coeffs[7] = 16'b0010000111110111;
        coeffs[8] = 16'b0000100001111110;
        coeffs[9] = 16'b0000000011110010;
    end

    // Accumulation and shift register for the filter
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (j = 0; j < N; j = j + 1) begin
                sample_reg[j] <= 16'd0;
            end
            acc <= 32'd0;
        end else begin
            // Shift register for input samples
            for (j = N-1; j > 0; j = j - 1) begin
                sample_reg[j] <= sample_reg[j-1];
            end
            sample_reg[0] <= in_sample;
            
            // Accumulate filtered result
            acc = 32'd0;
            for (j = 0; j < N; j = j + 1) begin
                acc = acc + sample_reg[j] * coeffs[j];
            end
        end
    end

    // Output assignment with scaling down as needed
    assign out_sample = acc[31:16]; // Adjust this shift if required for your design

endmodule
