# AES-S-Box-stream-Cipher


## Table of content

- Project specification
  - [Encryption scheme design](https://github.com/baylonp/AES-S-Box-stream-Cipher#11-encryption-scheme-design)
  - [S-Box](https://github.com/baylonp/AES-S-Box-stream-Cipher#12-s-box)

- [High-level model](https://github.com/baylonp/AES-S-Box-stream-Cipher/tree/main#2-high-level-design-aka-golden-model)

- [RTL design](https://github.com/baylonp/AES-S-Box-stream-Cipher#3-rtl-block-diagram-analysis)

- Interface Specifications and Expected Behavior
  - [Expected behaviour](https://github.com/baylonp/AES-S-Box-stream-Cipher#41-expected-behaviour)
  - [Corner Cases](https://github.com/baylonp/AES-S-Box-stream-Cipher#42-corner-cases)
 
- [Functional verification]()

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

![Figure 1.1: Encryption_scheme.](https://github.com/baylonp/AES-S-Box-stream-Cipher/blob/main/images/encryption_scheme_stream_cipher.png)


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

![Figure 1.2: Encryption_scheme.](https://github.com/baylonp/AES-S-Box-stream-Cipher/blob/main/images/s_box_implemented_in_the_project.png)


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

![Figure 3.3: RTL.](https://github.com/baylonp/AES-S-Box-stream-Cipher/blob/main/images/RTL-design.png)

In addition, a fiite state machine could be helpful to understand the varius steps in the simple module we implemented.

![FSM](https://github.com/baylonp/AES-S-Box-stream-Cipher/blob/main/images/FSM.png)


## 4.1 Expected behaviour


To power on the system, we must assert rst_n as the initial step of resetting internal
registers. This reset should be held low for one clock cycle to achieve proper resetting
of all internal states of the module. When the reset is deasserted (made high), operation
can begin.

The new_msg signal should be asserted by the user while providing an input_key[7:0]
decryption/encryption on their input. During this process, the key is loaded into an
internal index register. For at least one clock cycle, it should stay high before being
released again. During this time, in_valid must remain low in order to prevent early
processing of any input data.

For the user to execute the decryption or encryption process, he needs to load the key
and then provide input data. The in_valid signal should be raised high for every data
byte and the data entered into in[7:0]. The module will then process this input data byte
in the next clock cycle. Of course, the in_valid signal must be high for one clock cycle
while the module performs the necessary calculations.

It produces decrypted or encrypted output via out[7:0] port. After signaling that the
output is ready and valid, out_flag will remain high. After these steps are completed,
an external device can capture the output and then wait for the next valid data byte by
monitoring the out_flag.

Timing wise, synchronizing the in_valid signal with a clock signal requires that all
input bytes are input separately on different clock cycles where presence of valid data
is indicated by in_valid signal. In order to enable continuous data processing with each

clock edge, after in_valid has been set up output data will only be available during next
bit time.

This behaviour is shown in Figure 4.1.



![Figure 4.1 Expected waveform](https://github.com/baylonp/AES-S-Box-stream-Cipher/blob/main/images/waveform.png)


## 4.2 Corner cases
When the in_valid signal is asserted without first asserting new_msg, the module will
still process the input data, but it may not use the intended key for encryption or decryption, leading to incorrect outputs. Therefore, it is crucial to follow the correct sequence of signals to ensure proper operation.

When the in_valid signal is not raised to 1 after the signal new_msg goes low data
is ignored, the module does not recognize that valid input data is available. As a result,
it ignores the input data on in[7:0]. In addition, since in_valid is low, the index register does not increment and remains at its current value.


## 5 Functional verification (Testbenches)
The testbench we designed for the AES encryption/decryption thoroughly tests both
the encryption and decryption capabilities of the module.The test sequence starts with
defining and initializing various signals that control and provide inputs to the module,
including the clock, reset, input valid, new message, input data and the key. Outputs
are also defined to capture the results from the module.

The aes_enc_dec_module, defined as Device Under Test (DUT), is instantiated and
connected to these signals. The testbench generates a clock signal that oscillates every
5 time units. Initially, the reset signal is asserted to initialize the module to a known
state, then after 14.5 time units, it is deasserted to begin the functional mode.

The testbench reads input values and expected output values from external test vec-
tors, manually loaded into registers.The key loading process is simulated by setting the
new_msg signal high and providing a specific key value. In our case, the key value is
initalized to 0xAA.

Once the key is loaded, the testbench enters the encryption testing phase. It loops
through a series of input data values, providing each one to the module while asserting
the in_valid signal to indicate valid data.

After giving the module time to process each input, it checks the output against the ex-
pected result. If the output matches the expected value, a success message is displayed;
if not, a failure message is shown. This process ensures that the module correctly en-
crypts the input data according to the provided key.

The opposite happens for the Decrytpion testing phase.
In order to prove the correctness of our model we encrypted the string hello = (68656c6c6f ) (16) using the key 0xAA and the ciphertext value returned back is c407fdf98b.

This value is then saved in a register called encrypted_outputs and later used for decryption. Its decryption will be compared with the values in the input_text.txt test vector.

We see that this process gives back the original plaintext string hello.

Moreover, we tested the module using different keys for encrypting the same plain-
text. 
As we can see, every 5 tests the key changes. The expected values come from the
input_text_multikey.txt **test vector** for encryption and from out_text_multikey.txt for de-
cryption. Through this test we prove that our module correctly encrypts plaintexts with
different keys and correctly decrypts them.

The code is here for the [testbench](https://github.com/baylonp/AES-S-Box-stream-Cipher/blob/main/testbench.sv)
