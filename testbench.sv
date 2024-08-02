module tb_aes_enc_module;

  // Clock and reset signals
  reg clk;
  reg rst_n = 1'b0;

  // Input signals
  reg in_valid;
  reg new_msg;
  reg [7:0] in;
  reg [7:0] key;

  // Output signals
  wire out_flag;
  reg [7:0] out;
  
  
    // Define inputs and expected outputs
  reg [7:0] inputs [0:4];
  reg [7:0] expected_outputs [0:4];
	
	// Intermediate signals for decryption test
  reg [7:0] encrypted_outputs [0:4];

  // Instantiate the DUT (Device Under Test)
  aes_enc_dec_module dut (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .new_msg(new_msg),
    .in(in),
    .key(key),
    .out_flag(out_flag),
    .out(out)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns clock period
  end

  // Test sequence
  initial begin
    // Initialize signals
    rst_n = 0;
    in_valid = 0;
    new_msg = 0;
    in = 8'b0;
    key = 8'h00;

    // Apply reset
    #10;
    rst_n = 1'b1;

	// Read inputs and expected outputs from files
    $readmemb("tv/input_text.txt.txt", inputs);
    $readmemh("tv/out_text.txt.txt", expected_outputs);

    // Start new message
    new_msg = 1'b1;
    key =8'b10101010; // Example key, modify as needed
    #10;
    new_msg = 1'b0;

    // Apply inputs and check outputs
    for (int i = 0; i < 5; i++) begin
      in_valid = 1'b1;
      in = inputs[i];
      #10;
      in_valid = 1'b0;
      #10;
	  encrypted_outputs[i] = out;
      if (out == expected_outputs[i]) begin
        $display("Test %0d passed: output = %h, expected = %h", i, out, expected_outputs[i]);
      end else begin
        $display("Test %0d failed: output = %h, expected = %h", i, out, expected_outputs[i]);
      end
    end
	
	  // Wait a few cycles
    #50;
	
	
	// Decryption test
    new_msg = 1'b1;
    #10;
    new_msg = 1'b0;
	
	for (int i = 0; i < 5; i++) begin
      in_valid =  1'b1;
      in = encrypted_outputs[i];
      #10;
      in_valid = 1'b0;
      #10;
      if (out == inputs[i]) begin
        $display("Decryption Test %0d passed: output = %h, expected = %h", i, out, inputs[i]);
      end else begin
        $display("Decryption Test %0d failed: output = %h, expected = %h", i, out, inputs[i]);
      end
    end
	
	

    $stop;
  end

endmodule
