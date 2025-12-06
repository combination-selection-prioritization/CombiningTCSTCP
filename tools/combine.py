import os
import sys

from functions import read_file, save_file
from constants import *
import time

if __name__ == '__main__':
    working_dir = '.'
    if len(sys.argv) == 2:
        working_dir = sys.argv[1]
    
    selected_path = os.path.join(working_dir, "affected_tests.txt")

    prioritized_dir = os.path.join(working_dir, str_fast_pw)
    combined_dir = os.path.join(working_dir, str_comb_p)

    selected = read_file(selected_path)

    iteration_time = []
    for i in range(1, 31):
        # start = time.process_time()

        prioritized_path = os.path.join(prioritized_dir, str(i)+".txt")
        prioritized = read_file(prioritized_path)

        combined = []
        # Take the selected tests according to the prioritized order.
        for test in prioritized:
            if test in selected:
                combined.append(test)

        combined_path = os.path.join(combined_dir, str(i)+".txt")
        save_file(combined_path, combined)


