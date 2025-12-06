import sys

def select_tests(tests_file, selected_file, output_file):

    with open(tests_file, 'r') as file_tests:
        test_lines = file_tests.readlines()

    with open(selected_file, 'r') as file_selected:
        selected_tests = set(file_selected.read().splitlines())

    filtered_tests = [line.strip() for line in test_lines if line.split()[0] in selected_tests]

    with open(output_file, 'w') as file_output:
        file_output.write('\n'.join(filtered_tests))

if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(1)

    tests_file = sys.argv[1]
    selected_file = sys.argv[2]
    output_file = sys.argv[3]

    select_tests(tests_file, selected_file, output_file)
