module aes_enc_dec_module (
  input    clk,
  input    rst_n,
  input    in_valid,
  input    new_msg,
  input [7:0] in,
  input    [7:0] key,
  output reg      out_flag,
  output reg [7:0] out
);

  logic [7:0] index;
  logic [7:0] c;
  
  // Istantiation of S-Box module
  aes_sbox s(
    .in(index)
    ,.out(c)
  );




// Counter update logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            index <= 8'b0;
        end else if (new_msg) begin
            index <= key;
        end else if (in_valid) begin
            index <= index + 1;
        end
    end



  always_ff @ (posedge clk or negedge rst_n) begin

    if (!rst_n) begin
		out <= 8'b0;
		out_flag <= 1'b0;

    end else if (in_valid) begin
   
		out <= in ^ c;
		out_flag <= 1'b1;


    end else  out_flag <= 1'b0;
       	
  
  end

endmodule
