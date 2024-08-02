# AES-S-Box-stream-Cipher


## Table of content

- [Project specification](https://github.com/baylonp/AES-S-Box-stream-Cipher/edit/main/README.md#11-encryption-scheme-design)
  - Encryption scheme design
  - S-Box





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
(0F ) (16) . From Figure 1.2 we can see that the returning value is 79


