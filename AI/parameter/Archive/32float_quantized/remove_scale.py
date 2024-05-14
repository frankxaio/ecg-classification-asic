import os
import shutil
import numpy as np

def copy_files(src_dir, dst_dir):
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.startswith('parameters') or file.startswith('quantized_bias'):
                src_file = os.path.join(root, file)
                dst_file = os.path.join(dst_dir, os.path.relpath(src_file, src_dir))
                os.makedirs(os.path.dirname(dst_file), exist_ok=True)
                shutil.copy2(src_file, dst_file)
            elif file.startswith('quantized_weights'):
                weights_file = os.path.join(root, file)
                scale_file = os.path.join(root, 'quantization_scale.txt')
                
                # 檢查quantization_scale文件是否存在
                if not os.path.exists(scale_file):
                    print(f"Warning: {scale_file} not found. Skipping.")
                    continue
                
                # 讀取quantized_weights和quantization_scale
                weights = np.loadtxt(weights_file, dtype=int)
                scale = np.loadtxt(scale_file)
                
                # 將quantized_weights乘以quantization_scale
                fixed_weights = weights * scale
                
                # 將結果保存到目標資料夾,使用新的文件名
                dst_file = os.path.join(dst_dir, os.path.relpath(weights_file, src_dir))
                dst_file = dst_file.replace('quantized_weights', 'fixed_weights')
                os.makedirs(os.path.dirname(dst_file), exist_ok=True)
                np.savetxt(dst_file, fixed_weights, fmt='%.6f')

# 設置源資料夾和目標資料夾路徑
src_folder = '.'
dst_folder = '8bit_fixed_without_scale'

# 創建目標資料夾（如果不存在）
os.makedirs(dst_folder, exist_ok=True)

# 複製文件到目標資料夾
copy_files(src_folder, dst_folder)
