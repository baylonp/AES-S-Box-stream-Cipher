# AES-S-Box-stream-Cipher


## Table of content

- Project specification
  - [Encryption scheme design](https://github.com/baylonp/AES-S-Box-stream-Cipher#11-encryption-scheme-design)
  - [S-Box](https://github.com/baylonp/AES-S-Box-stream-Cipher#12-s-box)

- [High-level model](https://github.com/baylonp/AES-S-Box-stream-Cipher/tree/main#2-high-level-design-aka-golden-model)



## 1.1 Encryption scheme design
The project comprises the design and implementation of an **AES S-box based ** stream
cipher which supports both encryption and decryption in system verilog, plus the logic synthesis in Quartus.

The ciphertext is obtained by **XORING** each letter of the plaintext with a value coming
from the S-box table that has been computed as follows:

First we decide the seed key and for each index of the plaintext we sum this to it.
Finally we compute the result modulus 256. This computation yields a value which
will be the index for the search inside the S-box.
This operation will be repeated for every letter of the plaintext and it is important to
note that the key decided at the beggining will remain the same for all the letters of the
plaintext.
This process is represented by this formula: C i = P i ⊕ S(CB[i])
Where:

- C[i] is the i th byte of ciphertext.
- P[i] is the i th byte of plaintext.
- CB[i] is the 8-bit value of the i th counter (counter block), for i = 0,1,2, . . . , and it
can be represented by the formula CB[i] = (K + i) mod 256
- S( ) is the S-box transformation of AES algorithm, that works over a byte

![Figure 1.1: Encryption_scheme.](https://github.com/baylonp/AES-S-Box-stream-Cipher/blob/main/encryption_scheme_stream_cipher.png)


Figure 1.1 shows the encryption scheme.

Moreover, different requirements have been asked; we need to have:
- An asynchronous active-low reset port
- An input flag that will rise to 1 as soon as the input is stable and ready to be
sampled. In our project this signal has the name of in_valid
- An output flag that will rise to 1 as soon as the output is ready. In our project this
signal has the name of out_flag
- A signal communicating the beginning of a new message, given that for every
message the key needs to be reset to its inital value. We achieve this by imple-
menting the new_msg signa


## 1.2 S-Box
We adopted a modified ( simplified ) version of Substitution box, we do not implement the DES S-box lookup mechanism.
Our S-Box is a table of values which get choosen based on the LSB and MSB of the
input. If my input to the table is 10101111, the first 4 LSB will decide the row, the
4 MSB will decide the column. In this example Row = (A0) (16) and Column =
(0F ) (16) . 

![Figure 1.2: Encryption_scheme.](https://github.com/baylonp/AES-S-Box-stream-Cipher/blob/main/s_box_implemented_in_the_project.png)


From Figure 1.2 we can see that the returning value is 79



## 2 High-Level Design (AKA Golden Model)

The Python High Level model that we developed comprises 2 main functions: En-
crypt() and Decrypt().


The Encrypt function takes a ASCII sctring as input, performs all the operations men-
tioned above and print out the ciphertext.

This output is fed into the Decrypt() function wich will perform the reverse opera-
tions and print out the initial ASCII input. To conclude, the LUT version of the Sbox
has been implemented via hardcoded values in a matrix (list of lists).

The code is [here](https://github.com/baylonp/AES-S-Box-stream-Cipher/blob/main/golden_model.py)


## 3 RTL block diagram analysis
The system takes several inputs: an 8-bit data input in[7:0], a clock signal clk, a reset signal rst_n, an input validity signal in_valid, a new message signal new_msg, and an 8-bit key key[7:0].

The purpose of the module is to process the input data using the key, producing an 8-bit output out[7:0] and a flag out_flag indicating the validity of the output.

The most important part is the AES substitution box aes_sbox, which takes an 8-bit input index[7:0] and produces an 8-bit output c. The value of index is determined by the operations described in chapter 1.

The system starts by resetting the index register when the rst_n signal is low. When new_msg is high, the key key[7:0] is loaded into the index register. If new_msg is not active and in_valid is high, the index value is incremented by one.
The data input in[7:0] is then XORed with the output of the aes_sbox module. The result of this XOR operation is stored in a register, which holds the output value out[7:0].

This register updates on the rising edge of the clock signal, but only if in_valid is high, indicating that the input data is valid. At the same time, the out_flag register is set high,signaling that the output data is valid.

The block diagram also includes multiplexers that control the flow of data within
the module. One MUX selects between the key and the incremented index value, di-
recting the appropriate value to the index register based on the control signals.

Another MUX helps manage the selection process, ensuring that the correct value is loaded into the register at the right time.
The key and new message signals initialize the process and the validity signals ensure that only valid data is processed and output.

Figure 3.3 illustrates the RTL block diagram of our module.

