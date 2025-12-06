#!/bin/bash
#               
projects=("Cli" "Codec" "Compress" "Jsoup" "JxPath" "Lang" "Math" "Time" "Collections")
starts=(11 11 9 1  19 14 5  3  25 )
ends=(40 18 47 93 22 41 104 26 28)
builds=("mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn" "mvn")

for i in $(seq 0 $(expr ${#projects[@]} - 1)); do
    project=${projects[i]}
    start=${starts[i]}
    end=${ends[i]}
    build=${builds[i]}

    ./scripts/run_comb_v1.sh ${start} ${end} ${project} ${build}
done

./scripts/run_comb_gson_v1.sh 1 18 Gson mvn


if [ -d "repos" ]; then
    mv repos repos_ekstazi
    echo "Pasta 'repos' renomeada para 'repos_ekstazi'"
else
    echo "Pasta 'repos' não encontrada"
fi

"$(dirname "$0")/run_multiple_starts.sh"

"$(dirname "$0")/sync_repos.sh"

"$(dirname "$0")/run_multiple_metrics.sh"

"$(dirname "$0")/scripts/combine_raw_files.sh"

"$(dirname "$0")/scripts/sync_repos.sh"

# R scripts


