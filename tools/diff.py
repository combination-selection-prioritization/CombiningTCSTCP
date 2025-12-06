import sys

def filter_affected_tests(unaffected_path, all_tests_path, affected_path):

    with open(unaffected_path, 'r') as unaffected_file:
        unaffected_tests = set(line.strip() for line in unaffected_file)


    with open(all_tests_path, 'r') as all_tests_file:
        all_tests = set(line.strip() for line in all_tests_file)


    affected_tests = all_tests - unaffected_tests


    with open(affected_path, 'w') as affected_file:

        non_empty_lines = [line for line in affected_tests if line]
        affected_file.write('\n'.join(sorted(non_empty_lines)))

if __name__ == "__main__":

    if len(sys.argv) != 4:
        sys.exit(1)


    unaffected_tests_file = sys.argv[1]
    all_tests_file = sys.argv[2]
    affected_tests_file = sys.argv[3]


    filter_affected_tests(unaffected_tests_file, all_tests_file, affected_tests_file)

