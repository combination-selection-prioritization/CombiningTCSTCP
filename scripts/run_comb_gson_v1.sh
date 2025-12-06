#!/bin/bash

if [ $# != 4 ]; then
    echo "Usage:"
    echo "./run_comb_gson.sh [start_version] [end_version] [project_id] [mvn/ant]"
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

cd ..
cd defects4j
./init.sh
export PATH=$PATH:$(pwd)/framework/bin
cd ..
cd CombiningTCSTCP

compile() {
    local run_tests=${@}

    if [ ${build} = "ant" ]; then
        cd ${working_dir}

        if [ ${project} = "Chart" ]; then
            cd ant
        fi

        if [ ${run_tests} = "test" ]; then
            /usr/bin/time -o ${results_dir}/time/test_time.txt -f '%U\n%S' ant test -silent > /dev/null
        else
            /usr/bin/time -o ${results_dir}/time/build_time.txt -f '%U\n%S' ant compile-tests -silent > /dev/null
        fi
  
        if [ ${project} = "Chart" ]; then
            cd ..
        fi
        cd ../..
    fi

    if [ ${build} = "mvn" ]; then
        cd ${working_dir}

        if [ ${project} = "Gson" ]; then
            cd gson
        fi

        if [ ${run_tests} = "test" ]; then
            /usr/bin/time -o ${results_dir}/time/test_time.txt -f '%U\n%S' mvn install > /dev/null
        else
            /usr/bin/time -o ${results_dir}/time/build_time.txt -f '%U\n%S' mvn install -DskipTests=true > /dev/null
        fi
        
        if [ ${project} = "Gson" ]; then
            cd ..
        fi
        cd ../..
    fi
}

create_dirs() {
    local results_dir=${@}

    mkdir ${results_dir}
    mkdir ${results_dir}/ekstazi_dpt
    mkdir ${results_dir}/dpt
    mkdir ${results_dir}/ekstazi_rand
    mkdir ${results_dir}/fast_pw
    mkdir ${results_dir}/comb_s
    mkdir ${results_dir}/comb_p
    mkdir ${results_dir}/random
    mkdir ${results_dir}/time
}

echo "========================================="
echo "Cloning repositories"
echo "========================================="
./scripts/prepare_repos.sh ${1} ${2} ${3} ${4}

abs=$(pwd)
skipped=$(cat ${project}_skipped.txt)

working_dir=./repos/temp

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tools_dir="$SCRIPT_DIR/../tools"

if [ ${project} = "Chart" ] || 
   [ ${project} = "Math" ] ||
   [ ${project} = "Closure" ] ||
   [ ${project} = "Lang" ] ||
   [ ${project} = "Time" ]; then
    start=$(expr ${start} + ${skipped})
else
    end=$(expr ${end} - ${skipped})
fi

project_dir=${abs}/repos/${project}/${start}_fixed
results_dir=${abs}/repos/${project}/${start}_results
create_dirs ${results_dir}

rm -rf ${working_dir}
cp -r ${project_dir} ${working_dir}
if [ ${project} = "Gson" ]; then
    compilation_dir=${working_dir}/gson
else
    compilation_dir=${working_dir}
fi

i=${start}
echo "========================================="
echo "Compiling ${project} version ${1}"
echo "========================================="
compile "skip"
compile "test"

diretorio=${working_dir}/.ekstazi
if [ ${project} = "Gson" ]; then
    diretorio=${working_dir}/gson/.ekstazi
fi

if [ ! -d "$diretorio" ]; then
echo "Diretório não encontrado."
fi

ls "$diretorio"/*.clz | sed 's/\.clz$//' > ${results_dir}/file_names.txt

while read -r arquivo; do
cobertura=$(wc -l < "$arquivo.clz")
echo "$(basename "$arquivo") $cobertura" >> ${results_dir}/coverage_tests.txt &> /dev/null
done < ${results_dir}/file_names.txt
echo "Processo concluído. Arquivos criados: nomes_arquivos.txt e cobertura_testes.txt" &> /dev/null

python3 ${tools_dir}/path_gson.py ${results_dir}/file_names.txt

echo "========================================="
echo "Selecting tests for ${project} version ${1}"
echo "========================================="
/usr/bin/time -o ${results_dir}/time/selection_time.txt -f '%U\n%S' ls ${compilation_dir}/.ekstazi/
cd "${compilation_dir}/src/test" 

java_test_files=$(find . -type f -name '*.java' | grep -E '\/.*Test.*\.java$' | sed -e 's/^\.\///' -e 's/\//./g' -e 's/\.java$//' -e 's/^Test\.//')

echo $java_test_files &> /dev/null

echo "${java_test_files}" > "${results_dir}/all_tests.txt" &> /dev/null
echo "Arquivo gerado com sucesso em ${results_dir}/all_tests.txt" &> /dev/null
cd ..
cd ..
cd ../..
if [ ${project} = "Gson" ]; then
    cd ..
fi
pwd

sed -i -e 's/.clz//g' ${results_dir}/all_tests.txt
sed -i -e 's/test-results//g' ${results_dir}/all_tests.txt

python3 ${tools_dir}/path_gson.py ${results_dir}/all_tests.txt
python3 ${tools_dir}/dpt_adjust.py ${results_dir}/all_tests.txt ${results_dir}/file_names.txt ${results_dir}/coverage_tests.txt

cp ${results_dir}/file_names.txt ${results_dir}/affected_tests.txt

python3 ${tools_dir}/affected.py ${results_dir}/affected_tests.txt

python3 ${tools_dir}/select.py ${results_dir}/coverage_tests.txt ${results_dir}/affected_tests.txt ${results_dir}/coverage_tests_selected.txt

/usr/bin/time -o ${results_dir}/time/dpt_prioritization_time.txt -f '%U\n%S' python3 ${tools_dir}/dpt.py all ${results_dir}/coverage_tests.txt ${results_dir}/dpt 30

/usr/bin/time -o ${results_dir}/time/dpt_selected_prioritization_time.txt -f '%U\n%S' python3 ${tools_dir}/dpt.py all ${results_dir}/coverage_tests_selected.txt ${results_dir}/ekstazi_dpt 30

echo "========================================="
echo "Prioritizing tests for ${project} version ${1}"
echo "========================================="
/usr/bin/time -o ${results_dir}/time/fast_preparation_time.txt -f '%U\n%S' python3 ${tools_dir}/fast_parser.py ${compilation_dir}
/usr/bin/time -o ${results_dir}/time/fast_pw_time.txt -f '%U\n%S' python3 ${tools_dir}/prioritize.py all ${compilation_dir} ${results_dir} 30
/usr/bin/time -o ${results_dir}/time/comb_s_time.txt -f '%U\n%S' python3 ${tools_dir}/prioritize.py selected ${compilation_dir} ${results_dir} 30

echo "========================================="
echo "Combining results for ${project} version ${1}"
echo "========================================="
python3 ${tools_dir}/ekstazi_shuffle.py ${results_dir}
/usr/bin/time -o ${results_dir}/time/comb_p_time.txt -f '%U\n%S' python3 ${tools_dir}/combine.py ${results_dir}

cp -r ${compilation_dir}/.ekstazi ${results_dir}/ekstazi_dir
cp -r ${compilation_dir}/.fast ${results_dir}/fast_dir

for i in $(seq $(expr ${start} + 1) ${end}); do
    
    prev_results_dir=${results_dir}

    project_dir=${abs}/repos/${project}/${i}_fixed
    results_dir=${abs}/repos/${project}/${i}_results
    create_dirs ${results_dir}

    rm -rf ${working_dir}
    cp -r ${project_dir} ${working_dir}
    if [ ${project} = "Gson" ]; then
        compilation_dir=${working_dir}/gson
    else
        compilation_dir=${working_dir}
    fi
    
    compile "test"
    
    diretorio=${working_dir}/.ekstazi
    if [ ${project} = "Gson" ]; then
    diretorio=${working_dir}/gson/.ekstazi
    fi
    
    if [ ! -d "$diretorio" ]; then
    	echo "Diretório não encontrado."
    fi
    
    ls "$diretorio"/*.clz | sed 's/\.clz$//' > ${results_dir}/file_names.txt
    
    while read -r arquivo; do
    	cobertura=$(wc -l < "$arquivo.clz")
    	echo "$(basename "$arquivo") $cobertura" >> ${results_dir}/coverage_tests.txt &> /dev/null
    done < ${results_dir}/file_names.txt
    echo "Processo concluído. Arquivos criados: nomes_arquivos.txt e cobertura_testes.txt" &> /dev/null
    python3 ${tools_dir}/path_gson.py ${results_dir}/file_names.txt
    
    cd "${compilation_dir}/src/test" 
    
    java_test_files=$(find . -type f -name '*.java' | grep -E '\/.*Test.*\.java$' | sed -e 's/^\.\///' -e 's/\//./g' -e 's/\.java$//' -e 's/^Test\.//')
    
    echo "${java_test_files}" > "${results_dir}/all_tests.txt"  &> /dev/null
    echo "Arquivo gerado com sucesso em ${results_dir}/all_tests.txt" &> /dev/null
    cd ..
    cd ..
    pwd
    mvn clean
    rm -r .ekstazi
    cd ../..
    if [ ${project} = "Gson" ]; then
    cd ..
    fi
    pwd
    
    python3 ${tools_dir}/path_gson.py ${results_dir}/all_tests.txt
    
    python3 ${tools_dir}/dpt_adjust.py ${results_dir}/all_tests.txt ${results_dir}/file_names.txt ${results_dir}/coverage_tests.txt
    
    /usr/bin/time -o ${results_dir}/time/dpt_prioritization_time.txt -f '%U\n%S' python3 ${tools_dir}/dpt.py all ${results_dir}/coverage_tests.txt ${results_dir}/dpt 30
    
    echo "========================================="
    echo "Copying previous Ekstazi and FAST directories to version ${i}"
    echo "========================================="
    cp -r ${prev_results_dir}/ekstazi_dir ${compilation_dir}/.ekstazi
    cp -r ${prev_results_dir}/fast_dir ${compilation_dir}/.fast

    echo "========================================="
    echo "Compiling ${project} version ${i}"
    echo "========================================="
    compile "skip"

    echo "========================================="
    echo "Selecting tests for ${project} version ${i}"
    echo "========================================="
    cd ${compilation_dir}
    rm -r temp.txt &> /dev/null
    rm -r select.txt
    /usr/bin/time -o ${results_dir}/time/selection_time.txt -f '%U\n%S' mvn ekstazi:predict > select.txt 
    python3 ${tools_dir}/selectEkstazi_una_gson.py
    python3 ${tools_dir}/format_una.py
    sleep 1.5
    cp -r unaffected.txt ${results_dir}/unaffected_tests.txt 
    cd ..
    cd ..
    if [ ${project} = "Gson" ]; then
    cd ..
    fi

    echo "========================================="
    echo "Running tests for ${project} version ${i}"
    echo "========================================="
    compile "test"

    sed -i -e 's/\.clz//g' -e '/^\.clz/!s/test-results//g' ${results_dir}/all_tests.txt

    python3 ${tools_dir}/diff.py ${results_dir}/unaffected_tests.txt ${results_dir}/file_names.txt ${results_dir}/affected_tests.txt
    python3 ${tools_dir}/affected.py ${results_dir}/affected_tests.txt
    
    python3 ${tools_dir}/select.py ${results_dir}/coverage_tests.txt ${results_dir}/affected_tests.txt ${results_dir}/coverage_tests_selected.txt
    
    /usr/bin/time -o ${results_dir}/time/dpt_selected_prioritization_time.txt -f '%U\n%S' python3 ${tools_dir}/dpt.py all ${results_dir}/coverage_tests_selected.txt ${results_dir}/ekstazi_dpt 30

    echo "========================================="
    echo "Prioritizing tests for ${project} version ${i}"
    echo "========================================="
    /usr/bin/time -o ${results_dir}/time/fast_preparation_time.txt -f '%U\n%S' python3 ${tools_dir}/fast_parser.py ${compilation_dir}
    /usr/bin/time -o ${results_dir}/time/fast_pw_time.txt -f '%U\n%S' python3 ${tools_dir}/prioritize.py all ${compilation_dir} ${results_dir} 30
    /usr/bin/time -o ${results_dir}/time/comb_s_time.txt -f '%U\n%S' python3 ${tools_dir}/prioritize.py selected ${compilation_dir} ${results_dir} 30

    echo "========================================="
    echo "Combining results for ${project} version ${i}"
    echo "========================================="
    python3 ${tools_dir}/ekstazi_shuffle.py ${results_dir}
    /usr/bin/time -o ${results_dir}/time/comb_p_time.txt -f '%U\n%S' python3 ${tools_dir}/combine.py ${results_dir}

    cp -r ${compilation_dir}/.ekstazi ${results_dir}/ekstazi_dir
    cp -r ${compilation_dir}/.fast ${results_dir}/fast_dir

done

rm -rf ${working_dir}

exit 0
