import os
import sys
import random

from functions import read_file, save_file
from constants import *

def ekstazi_rand(working_dir):
    # Shuffle tests selected by Ekstazi
    selected_path = os.path.join(working_dir, "affected_tests.txt")
    output_dir = os.path.join(working_dir, "starts_rand")
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
   
    if os.path.exists(selected_path):
        selected = read_file(selected_path)
        # Create 30 permutations of the test suite.
        for i in range(1, 31):
            random.shuffle(selected)
            output_path = os.path.join(output_dir, str(i)+".txt")
            save_file(output_path, selected)

def randomize(working_dir):
    # Shuffle all tests
    tests_path = os.path.join(working_dir, "all_tests.txt")
    output_dir = os.path.join(working_dir, str_random)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    if os.path.exists(tests_path):
        tests = read_file(tests_path)
        # Create 30 permutations of the test suite.
        for i in range(1, 31):
            random.shuffle(tests)
            output_path = os.path.join(output_dir, str(i)+".txt")
            save_file(output_path, tests)


if __name__ == '__main__':

    working_dir = '.'
    if len(sys.argv) == 2:
        working_dir = sys.argv[1]
    
    ekstazi_rand(working_dir)
    randomize(working_dir)
