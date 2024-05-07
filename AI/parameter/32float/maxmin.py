import os

# Function to find max and min values in a file
def find_max_min(file_path):
    with open(file_path, 'r') as f:
        values = [float(line.strip()) for line in f]
        max_val = max(values)
        min_val = min(values)
    return max_val, min_val

# Traverse the directory structure
for root, dirs, files in os.walk('.'):
    for file in files:
        if file == 'parameters.txt':
            file_path = os.path.join(root, file)
            max_val, min_val = find_max_min(file_path)
            print(f"Folder: {root}")
            print(f"Max value: {max_val}")
            print(f"Min value: {min_val}")
            print()
