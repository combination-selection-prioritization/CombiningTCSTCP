#!/bin/bash


projects=("Cli" "Codec" "Compress" "Jsoup" "JxPath" "Lang" "Math" "Time" "Collections" "Gson")
starts=(11 11 9 1  19 14 5  4  25 1)
ends=(40 18 47 93 22 41 104 26 28 18)
builds=("mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn")

for i in $(seq 0 $(expr ${#projects[@]} - 1)); do
    project=${projects[i]}
    start=${starts[i]}
    end=${ends[i]}
    build=${builds[i]}

    ./scripts/metrics.sh ${start} ${end} ${project} ${build}
done


# R scripts
