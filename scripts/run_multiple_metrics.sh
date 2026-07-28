#!/bin/bash

projects=("Cli" "Codec" "Compress" "Jsoup" "JxPath" "Lang" "Math" "Time" "Collections" "Gson")
starts=(1 1 1 1 1 1 1 1 1 1)
ends=(30 8 39 93 4 28 100 23 2 18)
builds=( "mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn")


for i in $(seq 0 $(expr ${#projects[@]} - 1)); do
    project=${projects[i]}
    start=${starts[i]}
    end=${ends[i]}
    build=${builds[i]}

    ./scripts/metrics.sh ${start} ${end} ${project} ${build}
done


# R scripts
