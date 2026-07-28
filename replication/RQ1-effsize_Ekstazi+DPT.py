import os 
import itertools as it

from bisect import bisect_left
from typing import List
import csv

import numpy as np
import pandas as pd
import scipy.stats as ss

from pandas import Categorical


def VD_A(treatment: List[float], control: List[float]):
    m = len(treatment)
    n = len(control)

    if m != n:
        raise ValueError("Data d and f must have the same length")

    r = ss.rankdata(treatment + control)
    r1 = sum(r[0:m])

    # Compute the measure
    A = (2 * r1 - m * (m + 1)) / (2 * n * m) 

    levels = [0.12, 0.28, 0.42]  # (small, >= 0.56; medium, >= 0.64; large, >= 0.71)
    magnitude = ["negligible", "small", "medium", "large"]
    scaled_A = (A - 0.5) * 2

    magnitude = magnitude[bisect_left(levels, abs(scaled_A))]
    estimate = A

    return estimate, magnitude


if __name__ == '__main__':
    apfdf_dict = {}
    pttff_dict = {}

    metrics = ['apfdf', 'pttff']
    subjects = ["Cli", "Codec", "Collections", "Compress", "Gson", "Jsoup", "JxPath", "Lang", "Math", "Time"]
    suites = ["STARTS+FAST-S", "STARTS+DPT", "DPT", "Ekstazi+dpt", "STARTS", "Random", "STARTS", "Random", "Ekstazi", "STARTS+FAST-P", "FAST", "Ekstazi + FAST-P", "Ekstazi + FAST -S"]

    dicts = [apfdf_dict, pttff_dict]


    for dict_ in dicts:
        for subject in subjects:
            dict_[subject] = {}
            for suite in suites:
                dict_[subject][suite] = []


    with open(os.path.join('subjects','all','avg_final.csv')) as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        next(reader, None)  # skip the headers

        for row in reader:
            subject, version, suite, tccount, apfdf, ttff, pttff, misses, hit, hitcount = row
            #print(row)
            apfdf = float(apfdf)
            pttff = 1 - float(pttff)

            apfdf_dict[subject][suite].append(apfdf)
            pttff_dict[subject][suite].append(pttff)

    for metric in metrics:
        print('{}\n{}\n{}'.format('='*80, metric, '='*80))
        if metric == 'apfdf': dict_ = apfdf_dict
        elif metric == 'pttff': dict_ = pttff_dict
            
        for subject in subjects:
            print('{}\n{}\n{}'.format('-'*80, subject, '-'*80))
            control_fast = dict_[subject]["DPT"]
            control_ekstazi = dict_[subject]["Ekstazi"]
            control_random = dict_[subject]["Random"]
            treatment_s = dict_[subject]["Ekstazi+dpt"]
            #print(control_fast, control_ekstazi, control_random)

            print("Ekstazi+dpt vs RANDOM: ", VD_A(treatment_s, control_random))
            print("Ekstazi+dpt vs DPT: ", VD_A(treatment_s, control_fast))
            print("FASTAZI-S vs EKSTAZI: ", VD_A(treatment_s, control_ekstazi))
            print("EKSTAZI vs DPT: ", VD_A(control_ekstazi, control_fast))
            
            
