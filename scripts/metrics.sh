if [ $# != 4 ]; then
    echo "Usage:"
    echo "./run_comb.sh [start_version] [end_version] [project_id] [mvn/ant]"
    echo "start_version (int): The first version to run."
    echo "end_version (int): The last version to run."
    echo "project_id (str): The Defects4J project id (e.g. Chart, Csv, etc.)."
    echo "mvn/ant (str): Whether the project uses maven or ant for builds."

    exit 1
fi

if [ ${1} -lt 1 ]; then
    echo "Start version should be greater than 0."
    exit 2
fi

if [ ${4} != "ant" ] && [ ${4} != "mvn" ]; then
    echo "Build system must be ant or mvn."
    exit 4
fi


start=${1}
end=${2}
project=${3}
build=${4}



abs=$(pwd)
skipped=$(cat ${project}_skipped.txt)

working_dir=./repos/temp
tools_dir=./tools


project_dir=${abs}/repos/${project}/${start}_fixed
# fi
results_dir=${abs}/repos/${project}/${start}_results

echo "${project}"

# Calculate the metrics
echo "========================================="
echo "Calculating metrics for ${project}"
echo "========================================="
python3 ${tools_dir}/metric.py ./repos ${start} ${end} ./metrics ${project} all
python3 ${tools_dir}/metric.py ./repos ${start} ${end} ./metrics ${project} selected


exit 0
