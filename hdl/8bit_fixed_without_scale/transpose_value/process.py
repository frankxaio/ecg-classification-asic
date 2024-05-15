# Read the binary.txt file
with open('binary.txt', 'r') as file:
    lines = file.readlines()

# Remove leading/trailing whitespace and commas
lines = [line.strip().strip(',') for line in lines]

# Extract the binary values
binary_values = [line.split("'b")[1] for line in lines]

# Convert to 16x16 matrix
matrix = [binary_values[i:i+16] for i in range(0, len(binary_values), 16)]

# Perform matrix transpose
transposed_matrix = list(map(list, zip(*matrix)))

# Print the transposed 16x16 array
print("Transposed 16x16 Binary Array:")
for row in transposed_matrix:
    print(' '.join(row))

# Print the transposed binary representation 
print("\nTransposed Binary Representation:")
for row in transposed_matrix:
    for value in row:
        print(value)
