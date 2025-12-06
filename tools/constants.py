str_ekstazi = "ekstazi_rand"
str_starts = "starts_rand"
str_fast_pw = "fast_pw"
str_comb_s = "comb_s"
str_comb_p = "comb_p"
str_random = "random"
str_comb_s_starts = "comb_s_starts"
str_comb_p_starts = "comb_p_starts"
str_dpt = "dpt"
str_DPT = "DPT"
str_dpt_ekstazi = "ekstazi_dpt"
str_dpt_starts = "starts_dpt"
DPTT_time = "DPTT_time"
DPTT_ekstazi_time = "DPTT_ekstazi_time"
DPTT_time_starts = "DPTT_time_starts"
FAST_T_starts = "FAST_T_starts"
DPTT_ekstazi_t = "DPTT_ekstazi_t"
DPTT_t_starts = "DPTT_t_starts"

suites = [str_ekstazi, 
          str_fast_pw,
          str_dpt_ekstazi,
          str_dpt,
          str_starts,
          str_comb_s_starts,
          str_comb_p_starts,
          str_dpt_starts,
          str_comb_s, 
          str_comb_p, 
          str_random]

str_sel_time = "sel_time"
str_prio_p_time = "prio_p_time"
str_prio_s_time = "prio_s_time"
str_comb_time = "comb_time"
str_fast_prep_time = "fast_prep_time"
str_ekstazi_time = "ekstazi_time"
str_fast_time = "fast_time"
str_comb_p_time = "comb_p_time"
str_comb_s_time = "comb_s_time"
str_build_time = "build_time"
str_test_time = "test_time"


display_names = {
    str_ekstazi: "Ekstazi",
    str_DPT : "DPT",
    str_fast_pw: "FAST",
    str_dpt_ekstazi: "Ekstazi+dpt",
    str_dpt: "DPT",
    str_starts: "STARTS",
    str_comb_s_starts: "STARTS+FAST-S",
    str_comb_p_starts: "STARTS+FAST-P",
    str_dpt_starts: "STARTS+DPT",
    str_comb_s: "Ekstazi + FAST -S",
    str_comb_p: "Ekstazi + FAST-P",
    str_random: "Random",
    str_sel_time: "Selection",
    str_fast_prep_time: "FAST preparation",
    str_prio_p_time: "Full prioritization",
    str_prio_s_time: "Sel. prioritization",
    str_comb_time: "Combination",
    str_ekstazi_time: "Ekstazi",
    str_fast_time: "FAST",
    str_comb_p_time: "Ekstazi + FAST-P",
    str_comb_s_time: "Ekstazi + FAST-S",
    str_build_time: "Build time",
    str_test_time: "Test time",
    DPTT_time: "DPTT_time",
    DPTT_ekstazi_time: "DPTT_ekstazi_time",
    DPTT_ekstazi_t:"DPTT_ekstazi_t",
    DPTT_t_starts:"DPTT_t_starts",
    str_sel_time+"_starts":str_sel_time+"_starts",
    str_prio_p_time+"_starts":str_prio_p_time+"_starts",
    str_prio_s_time+"_starts":str_prio_s_time+"_starts",
    str_comb_time+"_starts":str_comb_time+"_starts",
    str_fast_prep_time+"_starts":str_fast_prep_time+"_starts",
    str_build_time+"_starts":str_build_time+"_starts",
    str_test_time+"_starts": str_test_time+"_starts",
    DPTT_time_starts:"DPTT_time_starts",
    str_fast_time+"_starts":str_fast_time+"_starts",
    str_comb_p_time+"_starts":"STARTS + FAST - P",
    str_comb_s_time+"_starts":"STARTS + FAST - S",
    FAST_T_starts:"FAST_T_starts",
}

str_adj = "adj_budget"
str_napfd = "napfd"
str_ttff_abs = "ttff_abs"
str_ttff = "ttff"
str_len = "suite_len"
metrics = [str_adj, str_len, str_napfd, str_ttff_abs, str_ttff]

str_result = "result"
str_misses = "misses"

percentages = [.10, .20, .25, .30, .40, .50, .60, .70, .75, .80, .90, 1]
num_iterations = 30
iterations = range(1, num_iterations+1)
