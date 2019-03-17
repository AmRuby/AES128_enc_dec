# AES128_enc_dec
# Description
Perfectly working Advanced Encryption Standard (AES) algorithm, with key size of 128 bits. It has encryption and decryption modules that can be altered between. It includes a test that tests the full algorithm. The top module is called AES (extensively explained), it port maps both of the modules and the user choose which one to work using internal signals (called enc and dec). The algorithm stars off with the key-scheduling process, then does either encryption or decryption (doesn't do the key-scheduling in parallel with the encryption or decryption). Throughput were not targeted much in this project, area was, hence, only one round of either encryption or decryption is implemented, while its' inputs and outputs are changed each round of the 10 rounds.
# Features
- 128 bit data
- 128 bit cipher key
- Optimized for area and power
