import csv

def float_to_fixed8(float_value):
    # Convert float to 8-bit fixed-point representation with 4-bit integer and 4-bit fraction
    fixed8_value = int(round(float_value * (2**4)))
    if fixed8_value < 0:
        fixed8_value = (abs(fixed8_value) ^ 0xFF) + 1
    binary = format(fixed8_value & 0xFF, '08b')
    return binary

# 開啟原始 CSV 檔案
with open('ptbdb_test_sliced_15.csv', 'r') as file:
    reader = csv.reader(file)
    data = list(reader)

# 處理前 5 行資料的前 15 欄,並分別存儲到五個不同的 TXT 檔案中
for i, row in enumerate(data[:5], start=1):
    fixed_point_row = []
    for value in row[:15]:  # 只處理前 15 欄
        float_value = float(value)
        fixed_point_binary = float_to_fixed8(float_value)
        fixed_point_row.append(fixed_point_binary)

    # 將結果寫入 TXT 檔案
    with open(f'fixed_point_data_{i}.txt', 'w') as file:
        file.write('\n'.join(fixed_point_row))