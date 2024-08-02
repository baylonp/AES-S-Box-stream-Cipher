module tb_multikeys;

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
  reg [7:0] expected_outputs [0:24];
  reg [7:0] key_vector [0:4];
	
	// Intermediate signals for decryption test
  reg [7:0] encrypted_outputs [0:24];
  int k = 0;

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
    $readmemh("tv/out_text_multikey.txt.txt", expected_outputs);
	$readmemb("tv/key_vector_multikey.txt.txt", key_vector);


	//This "for" is for cycling the keys
	for(int j = 0; j<5;j++) begin
		// Start new message
		new_msg = 1'b1;
		key =key_vector[j]; // Example key, modify as needed
		#10;
		new_msg = 1'b0;
	
		// Apply inputs and check outputs
		for (int i = 0; i < 5; i++) begin
		  in_valid = 1'b1;
		  in = inputs[i];
		  #10;
		  in_valid = 1'b0;
		  #10;
		  encrypted_outputs[i+k] = out;
		  if (out == expected_outputs[i+k]) begin
			$display("Test %0d passed with key = %b: output = %h, expected = %h",i+k, key, out, expected_outputs[i+k]);
		  end else begin
			$display("Test %0d  failed with key = %b: output = %h, expected = %h",i+k, key, out, expected_outputs[i+k]);
		  end
		
		end
		k+=5;
	end
	
	  // Wait a few cycles
    #50;
	
	
	 // Decryption process
     // Reset index
	 k=0;
    for(int j = 0; j <5 ;j++ ) begin
      // Start new message
      new_msg = 1'b1;
      key = key_vector[j]; // Use keys in reverse order for decryption
      #10;
      new_msg = 1'b0;
    
      // Apply encrypted outputs and check if they match the original inputs
      for (int i = 0; i < 5; i++) begin
        in_valid = 1'b1;
        in = encrypted_outputs[i+k];
        #10;
        in_valid = 1'b0;
        #10;
        if (out == inputs[i]) begin
          $display("Decryption Test %0d passed with key = %h: output = %h, expected = %h", i + k, key, out, inputs[i]);
        end else begin
          $display("Decryption Test %0d failed with key = %h: output = %h, expected = %h", i + k, key, out, inputs[i]);
        end
      end
	  k+=5;
    end
	

    $stop;
  end

endmodule
