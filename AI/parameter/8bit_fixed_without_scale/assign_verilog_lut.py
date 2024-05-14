def process_data(data):
    lines = data.strip().split('\n')
    result = []
    current_variable = None

    for line in lines:
        if line.startswith('File:'):
            file_path = line.split('File: ')[1]
            variable_name = file_path.split('\\')[-1].split('.')[0]
            current_variable = variable_name
            result.append(f"assign {current_variable} = {{")
        elif line.startswith('Content:'):
            continue
        else:
            if ',' not in line:
                result.append(line + "};")
            else:
                result.append(line)

    # Remove the extra }; from the last line
    # result[-1] = result[-1].rstrip('};')

    return '\n'.join(result)

# Read the content from the output.txt file
with open('output.txt', 'r') as file:
    content = file.read()

# Process the data
transformed_data = process_data(content)

# Save the transformed data to a new file
with open('transformed_output.txt', 'w') as file:
    file.write(transformed_data)
