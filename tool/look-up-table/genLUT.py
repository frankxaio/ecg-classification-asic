import math
import struct

def float_to_ieee754_16bit_binary(value):
    # 將浮點數轉換為 IEEE 754 格式的 16 位二進制表示
    binary = struct.pack('>e', value)
    return ''.join(format(byte, '08b') for byte in binary)

def sigmoid(x):
    return 1 / (1 + math.exp(-x))

def gelu(x):
    return 0.5 * x * (1 + math.tanh(math.sqrt(2 / math.pi) * (x + 0.044715 * x**3)))

def generate_lut(func, min_val, max_val, num_points):
    step = (max_val - min_val) / (num_points - 1)
    lut = [float_to_ieee754_16bit_binary(func(min_val + i * step)) for i in range(num_points)]
    return lut

# 產生 sigmoid 和 GELU 的查找表
# ! 輸入的範圍需在 sigmoid 和 GELU 的有效範圍內，-16 ~ 15
sigmoid_lut = generate_lut(sigmoid, -16, 15, 1024)
gelu_lut = generate_lut(gelu, -16, 15, 1024)

# 將查找表儲存為 .txt 檔案
with open('sigmoid_lut_ieee754_16bit_binary.txt', 'w') as file:
    for value in sigmoid_lut:
        file.write(value + '\n')

with open('gelu_lut_ieee754_16bit_binary.txt', 'w') as file:
    for value in gelu_lut:
        file.write(value + '\n')
