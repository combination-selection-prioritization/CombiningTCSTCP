import os
from constants import *

def read_file(file_path):
    with open(file_path, "r") as f:
        return  list(
                    filter(lambda line: len(line) > 0 and "$" not in line,
                        map(lambda line: line.strip(), 
                            f.readlines() 
                        ) 
                    ) 
                )
    return []


def save_file(file_path, data):
    with open(file_path, "w") as f:
        f.write("\n".join(data)+"\n")


def read_time(file_path):
    with open(file_path, "r") as f:
        lines = f.readlines()
        # get CPU kernel time
        raw_number = lines[-1].strip()
        if ":" in raw_number:
            raw_number = float(raw_number.split(":")[1])
        else:
            raw_number = float(raw_number)
        result = float("{:.4f}".format(raw_number))
        # get CPU user time
        raw_number = lines[-2].strip()
        if ":" in raw_number:
            raw_number = float(raw_number.split(":")[1])
        else:
            raw_number = float(raw_number)
        result += float("{:.4f}".format(raw_number))
        # return sum
        return result


def fully_qualified_name(file_path):
    """INPUT
    (str)file_path: full path of a file

    OUTPUT
    (str) the fully qualified name of a Java class"""
    path, _ = os.path.splitext(file_path)
    path, name = os.path.split(path)
    qualified = [name]

    while path != '':
        path, name = os.path.split(path)
        if name == 'tests' or name == 'test' or name == 'java':
            return '.'.join(qualified)
        qualified = [name] + qualified
    
    return ''


def get_failing_tests(file_path):
    failing_tests = set()

    with open(file_path, "r") as f:
        lines = f.readlines()
        for line in lines:
            halves = line.split("=")

            if halves[0] == "d4j.tests.trigger":
                tests = halves[1].split(",")
                for test in tests:
                    test_case = test.split("::")[0].strip()
                    failing_tests.add(test_case)
                break

    return failing_tests


def apfd(prioritization, faults):
    """INPUT:
    (list)prioritization: list of test cases
    (str)faults: path of fault_matrix_h (txt file)

    OUTPUT:
    (float)APFD = 1 - (sum_{i=1}^{m} t_i / n*m) + (1 / 2n)
    n = number of test cases
    m = number of faults detected
    t_i = position of first test case revealing fault i in the prioritization
    Average Percentage of Faults Detected
    """

    """
    With D4J, there is only one fault per version.
    Therefore, the numerator is the position of the first test that finds the fault (aka TTFF).
    Furthermore, m can only be 1 (fault detected) or 0 (fault undetected).
    """

    numerator = ttff_abs(prioritization, faults)
    
    n, m = len(prioritization), (1 if numerator > 0 else 0)
    apfd = 1.0 - (numerator / (n * m)) + (1.0 / (2 * n)) if m > 0 else 0.0

    return apfd


def napfd(full_suite_len, suite_ttff):
    """
    Variation of APFD that normalizes the result based on the full test suite length.
    """

    numerator = suite_ttff
    
    n, m = full_suite_len, (1 if numerator > 0 else 0)
    apfd = 1.0 - (numerator / (n * m)) + (1.0 / (2 * n)) if m > 0 else 0.0

    return apfd


def ttff_abs(suite, faults):
    count = 1
    for test_case in suite:
        if test_case in faults:
            return count
        count += 1
    
    return 0


def ttff(full_suite_len, suite_ttff):
    return float(suite_ttff) / full_suite_len


def gather_time(results_path):
    result = {}

    time_path = os.path.join(results_path, "time", "selection_time.txt")
    result[str_sel_time] = read_time(time_path)
    
    time_path = os.path.join(results_path, "time_starts", "selection_time_starts.txt")
    result[str_sel_time+"_starts"] = read_time(time_path)
    
    time_path = os.path.join(results_path, "time", str_fastazi_s+"_time.txt")
    result[str_prio_s_time] = read_time(time_path)/num_iterations
    
    time_path = os.path.join(results_path, "time_starts", str_fastazi_s+"_time_starts.txt")
    result[str_prio_s_time+"_starts"] = read_time(time_path)/num_iterations

    time_path = os.path.join(results_path, "time", "fast_preparation_time.txt")
    result[str_fast_prep_time] = read_time(time_path)
    
    time_path = os.path.join(results_path, "time_starts", "fast_preparation_time_starts.txt")
    result[str_fast_prep_time+"_starts"] = read_time(time_path)

    time_path = os.path.join(results_path, "time", "build_time.txt")
    result[str_build_time] = read_time(time_path)
    
    time_path = os.path.join(results_path, "time_starts", "build_time_starts.txt")
    result[str_build_time+"_starts"] = read_time(time_path)

    time_path = os.path.join(results_path, "time", "test_time.txt")
    result[str_test_time] = read_time(time_path)
    
    time_path = os.path.join(results_path, "time_starts", "test_time_starts.txt")
    result[str_test_time+"_starts"] = read_time(time_path)
    
    time_path = os.path.join(results_path, "time", "dpt_prioritization_time.txt")
    result[DPTT_time] = read_time(time_path)/30
    
    time_path = os.path.join(results_path, "time", "dpt_selected_prioritization_time.txt") 
    result[DPTT_ekstazi_time] = read_time(time_path)/30
    
    time_path = os.path.join(results_path, "time_starts", "dpt_selected_prioritization_time_starts.txt") 
    result[DPTT_time_starts] = read_time(time_path)/30
    
    result[str_DPT] = result[DPTT_time] + result[str_sel_time]
    
    result[str_fast_time] = (result[str_fast_prep_time] + result[str_prio_s_time])
    
    result[str_fast_time+"_starts"] = (result[str_fast_prep_time+"_starts"] + result[str_prio_s_time+"_starts"])  
    
    result[str_comb_s_time] = max(result[str_sel_time], result[str_fast_prep_time]) + result[str_prio_s_time] 
    
    result[str_comb_s_time+"_starts"] = max(result[str_sel_time+"_starts"], result[str_fast_prep_time+"_starts"]) + result[str_prio_s_time+"_starts"] 
    
    result[FAST_T_starts] = (result[str_fast_prep_time+"_starts"] + result[str_prio_s_time+"_starts"])
    
    result[DPTT_ekstazi_t] = (result[str_sel_time]) + (result[DPTT_ekstazi_time])
    
    result[DPTT_t_starts] = ((result[str_sel_time+"_starts"]) + (result[DPTT_time_starts]) + result[str_sel_time])
    
    return result

def time_avg(time):
    suites = [str_sel_time, str_sel_time+"_starts", str_prio_s_time,str_prio_s_time+"_starts", str_fast_prep_time, str_fast_prep_time+"_starts", str_build_time, str_build_time+"_starts", str_test_time, str_test_time+"_starts", DPTT_time, DPTT_ekstazi_time, DPTT_time_starts, str_fast_time, str_fast_time+"_starts", str_comb_s_time, str_comb_s_time+"_starts", FAST_T_starts, DPTT_ekstazi_t, DPTT_t_starts, str_DPT]
    avg = {}
    s = {} # sum
    c = {} # count
    
    for suite in suites:
        s[suite] = 0.0
        c[suite] = 0
    
    for _, version_results in time.items():
        for suite, value in version_results.items():
            s[suite] += float(value)
            c[suite] += 1
    
    for suite in suites:
        avg[suite] = s[suite]/c[suite]
        
    
    return avg
