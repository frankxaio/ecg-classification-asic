from rich import print
from rich.console import Console
from rich.panel import Panel
from rich.text import Text

console = Console()

def binary_to_decimal(binary_str, fixed_point):
    # 移除二進位字串中的空格
    binary_str = binary_str.replace(" ", "")

    # 如果二進位字串為空,直接返回0
    if not binary_str:
        return 0

    # 判斷是否為負數 (2's complement)
    is_negative = binary_str[0] == "1"

    # 如果是負數,將其轉換為正數的二進位表示 (2's complement)
    if is_negative:
        inverted_binary = "".join("1" if bit == "0" else "0" for bit in binary_str[1:])
        binary_str = bin(int(inverted_binary, 2) + 1)[2:].zfill(len(binary_str))

    # 計算小數點的位置
    decimal_point = fixed_point

    # 將二進位字串拆分為整數部分和小數部分
    integer_part = binary_str[:-decimal_point] if decimal_point > 0 else binary_str
    fractional_part = binary_str[-decimal_point:] if decimal_point > 0 else ""

    # 將整數部分轉換為十進位數
    integer_value = int(integer_part, 2) if integer_part else 0

    # 將小數部分轉換為十進位數
    fractional_value = sum(int(bit) * 2 ** -i for i, bit in enumerate(fractional_part, start=1)) if fractional_part else 0

    # 計算最終的十進位數
    decimal_num = integer_value + fractional_value

    # 如果是負數,將其轉換為負數的十進位表示
    if is_negative:
        decimal_num = -decimal_num

    return decimal_num

print(Panel("歡迎使用二進位轉十進位小數轉換器!", title="二進位轉換器", expand=False))
print("請輸入二進位字串和fixed-point位置,或輸入'q'退出程式。")

while True:
    binary_input = console.input("\n請輸入二進位字串: ")
    
    if binary_input.lower() == 'q':
        print(Panel("程式已結束。", title="結束", expand=False))
        break
    
    while True:
        try:
            fixed_point = int(console.input("請輸入fixed-point位置: "))
            break
        except ValueError:
            print(Panel("輸入的fixed-point位置無效,請再試一次。", title="錯誤", expand=False))
    
    decimal_output = binary_to_decimal(binary_input, fixed_point)
    
    result_text = Text(f"\n轉換結果: {decimal_output:.8f}", style="bold green")
    console.print(Panel(result_text, title="結果", expand=False))