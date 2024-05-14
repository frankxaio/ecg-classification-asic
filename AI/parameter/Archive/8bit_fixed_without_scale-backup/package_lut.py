import os

def process_files(root_dir, output_file):
    with open(output_file, 'w') as outfile:
        for root, dirs, files in os.walk(root_dir):
            for file in files:
                if file.endswith('.txt'):
                    file_path = os.path.join(root, file)
                    with open(file_path, 'r') as infile:
                        content = infile.read().strip().split("\n")
                        outfile.write(f"File: {file_path}\n")
                        outfile.write("Content:  \n")
                        for i, line in enumerate(content):
                            if i == len(content) - 1:
                                outfile.write(f"8'b{line}\n")
                            else:
                                outfile.write(f"8'b{line},\n")
                        outfile.write("\n")

# Set the root directory and output file path
root_directory = '.'
output_file_path = 'output.txt'

# Process the files and write to the output file
process_files(root_directory, output_file_path)
