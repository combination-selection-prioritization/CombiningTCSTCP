#!/bin/bash

if [ $# != 4 ]; then
    echo "Usage:"
    echo "./prepare_repos.sh [start_version] [end_version] [project_id] [mvn/ant]"
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

if [ ${4} != "ant" ] && [ ${4} != "mvn" ] && [ ${4} != "none" ]; then
    echo "Build system must be ant or mvn."
    exit 4
fi

start=${1}
end=${2}
project=${3}
build=${4}

rm -rf repos/${project}
mkdir repos
mkdir repos/${project}

skipped=0

# Closure has three versions that are irrelevant to us.
closure_skip=(21 137 146)

# ============================================
# ORIGINAL PART - EXACTLY THE SAME
# ============================================

if [ ${project} = "Chart" ] || 
   [ ${project} = "Math" ] ||
   [ ${project} = "Closure" ] ||
   [ ${project} = "Lang" ] ||
   [ ${project} = "Time" ]; then

    for i in $(seq ${start} ${end}); do

        dir_ver=$(expr ${end} - ${i} + ${start} + ${skipped})
        project_dir=repos/${project}/${dir_ver}_fixed  

        if [[ ${project} = "Closure" && 
            ( ( ${i} = 21 ) || ( ${i} = 137 ) || ( ${i} = 146 ) ) ]]; then
            echo "Skipping ${project} version ${i}."
        else
            defects4j checkout -p ${project} -v ${i}f -w ${project_dir}
        fi
        
        if [ -d ${project_dir} ]; then
            rm -rf ${project_dir}/.git

            if [ ${build} = "ant" ]; then
                if [ ${project} = "Chart" ]; then
                    python3 tools/build_patcher.py ${project_dir}/ant/build.xml ant
                else
                    python3 tools/build_patcher.py ${project_dir}/build.xml ant
                fi
            fi

            if [ ${build} = "mvn" ]; then
                python3 tools/build_patcher.py ${project_dir}/pom.xml mvn
            fi
        else
            skipped=$(expr ${skipped} + 1)
        fi
    done

else

    for i in $(seq ${start} ${end}); do
        dir_ver=$(expr ${i} - ${skipped})
        project_dir=repos/${project}/${dir_ver}_fixed
        defects4j checkout -p ${project} -v ${i}f -w ${project_dir}

        if [ -d ${project_dir} ]; then
            rm -rf ${project_dir}/.git

            if [ ${build} = "ant" ]; then
                python3 tools/build_patcher.py ${project_dir}/build.xml ant
            fi

            if [ ${build} = "mvn" ]; then
                if [ ${project} = "Gson" ]; then
                    python3 tools/build_patcher.py ${project_dir}/gson/pom.xml mvn
                else
                    python3 tools/build_patcher.py ${project_dir}/pom.xml mvn
                fi
            fi
        else
            skipped=$(expr ${skipped} + 1)
        fi
    done

fi

echo ${skipped} > ${project}_skipped.txt

# ============================================
# NEW LOGIC - ADDING PREVIOUS VERSIONS (EKSTAZI)
# ============================================


LOG_FILE="prepare_repos_${project}_$(date +%Y%m%d_%H%M%S).log"

echo "=========================================" | tee -a "$LOG_FILE"
echo "Adding previous versions before bugs (EKSTAZI)" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"

DEFECTS4J_HOME="/home/danilotorquato/repos/defects4j"
COMMIT_DB="${DEFECTS4J_HOME}/framework/projects/${project}/commit-db"

case ${project} in
    Cli)         REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/commons-cli.git" ;;
    Codec)       REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/commons-codec.git" ;;
    Compress)    REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/commons-compress.git" ;;
    Collections) REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/commons-collections.git" ;;
    Gson)        REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/gson.git" ;;
    Jsoup)       REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/jsoup.git" ;;
    JxPath)      REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/commons-jxpath.git" ;;
    Lang)        REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/commons-lang.git" ;;
    Math)        REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/commons-math.git" ;;
    Time)        REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/joda-time.git" ;;
    *)           REPO_ORIGINAL="${DEFECTS4J_HOME}/project_repos/commons-${project,,}.git" ;;
esac
echo "Original repository: ${REPO_ORIGINAL}" | tee -a "$LOG_FILE"

if [ ! -f "$COMMIT_DB" ]; then
    echo "ERROR: commit-db not found" | tee -a "$LOG_FILE"
    exit 1
fi

if [ ! -d "$REPO_ORIGINAL" ]; then
    echo "ERROR: Original repository not found" | tee -a "$LOG_FILE"
    exit 1
fi

# Save original folders
mkdir -p repos/${project}/.originals
mv repos/${project}/*_fixed repos/${project}/.originals/ 2>/dev/null

new_index=${start}

for i in $(seq ${start} ${end}); do
    
    # Handle Closure skipped versions
    if [[ ${project} = "Closure" && ( ( ${i} = 21 ) || ( ${i} = 137 ) || ( ${i} = 146 ) ) ]]; then
        echo "----------------------------------------" | tee -a "$LOG_FILE"
        echo "Skipping Closure version: ${i}" | tee -a "$LOG_FILE"
        continue
    fi

    # Replicate exactly the naming calculation from Part 1
    if [ ${project} = "Chart" ] || [ ${project} = "Math" ] || [ ${project} = "Closure" ] || [ ${project} = "Lang" ] || [ ${project} = "Time" ]; then
        # Reverse projects
        orig_folder_num=$(expr ${end} - ${i} + ${start} + ${skipped})
    else
        # Normal projects
        orig_folder_num=$(expr ${i} - ${skipped})
    fi

    original_dir="repos/${project}/.originals/${orig_folder_num}_fixed"
    
    echo "----------------------------------------" | tee -a "$LOG_FILE"
    echo "Processing Defects4J version: ${i} (Looking for original folder: ${orig_folder_num}_fixed)" | tee -a "$LOG_FILE"
    
    if [ ! -d "${original_dir}" ]; then
        echo "ERROR/WARNING: Original folder not found: ${original_dir}. Skipping." | tee -a "$LOG_FILE"
        continue
    fi
    
    commit_buggy=$(grep "^${i}," "$COMMIT_DB" | cut -d',' -f2)
    echo "Original buggy commit: ${commit_buggy}" | tee -a "$LOG_FILE"
    
    if [ -z "$commit_buggy" ]; then
        echo "ERROR: Commit not found in commit-db" | tee -a "$LOG_FILE"
        cp -r "${original_dir}" "repos/${project}/${new_index}_fixed"
        new_index=$((new_index + 1))
        continue
    fi
    
    # Create previous version (HEAD^)
    temp_repo="repos/${project}/.temp_${i}"
    echo "Cloning repository..." | tee -a "$LOG_FILE"
    git clone --depth 10 "${REPO_ORIGINAL}" "${temp_repo}" >> "$LOG_FILE" 2>&1
    
    cd "${temp_repo}"
    
    if git checkout ${commit_buggy} >> "$LOG_FILE" 2>&1; then
        echo "Checkout of buggy commit: OK" | tee -a "$LOG_FILE"
        
        if git checkout HEAD^ >> "$LOG_FILE" 2>&1; then
            parent_commit=$(git rev-parse --short HEAD)
            parent_msg=$(git log -1 --oneline)
            echo "Previous commit: ${parent_commit}" | tee -a "$LOG_FILE"
            echo "Message: ${parent_msg}" | tee -a "$LOG_FILE"
            
            rm -rf .git
            cd - > /dev/null
            
            mv "${temp_repo}" "repos/${project}/${new_index}_fixed"
            
            # Apply build patch to previous version
            if [ ${build} = "mvn" ]; then
                if [ ${project} = "Gson" ] && [ -f "repos/${project}/${new_index}_fixed/gson/pom.xml" ]; then
                    python3 tools/build_patcher.py "repos/${project}/${new_index}_fixed/gson/pom.xml" mvn
                elif [ -f "repos/${project}/${new_index}_fixed/pom.xml" ]; then
                    python3 tools/build_patcher.py "repos/${project}/${new_index}_fixed/pom.xml" mvn
                fi
                echo "Mvn patch applied to previous version" | tee -a "$LOG_FILE"
            fi
            
            if [ ${build} = "ant" ]; then
                if [ ${project} = "Chart" ] && [ -f "repos/${project}/${new_index}_fixed/ant/build.xml" ]; then
                    python3 tools/build_patcher.py "repos/${project}/${new_index}_fixed/ant/build.xml" ant
                elif [ -f "repos/${project}/${new_index}_fixed/build.xml" ]; then
                    python3 tools/build_patcher.py "repos/${project}/${new_index}_fixed/build.xml" ant
                fi
                echo "Ant patch applied to previous version" | tee -a "$LOG_FILE"
            fi
            
            echo "CREATED: ${new_index}_fixed (previous to bug ${i})" | tee -a "$LOG_FILE"
            new_index=$((new_index + 1))
        else
            echo "ERROR: Could not checkout HEAD^" | tee -a "$LOG_FILE"
            cd - > /dev/null
            rm -rf "${temp_repo}"
            cp -r "${original_dir}" "repos/${project}/${new_index}_fixed"
            new_index=$((new_index + 1))
            continue
        fi
    else
        echo "ERROR: Checkout of commit ${commit_buggy} failed" | tee -a "$LOG_FILE"
        cd - > /dev/null
        rm -rf "${temp_repo}"
        cp -r "${original_dir}" "repos/${project}/${new_index}_fixed"
        new_index=$((new_index + 1))
        continue
    fi
    
    # Move original version
    mv "${original_dir}" "repos/${project}/${new_index}_fixed"
    echo "CREATED: ${new_index}_fixed (original bug ${i})" | tee -a "$LOG_FILE"
    new_index=$((new_index + 1))
done

rm -rf repos/${project}/.originals
rm -rf repos/${project}/.temp_*

echo "=========================================" | tee -a "$LOG_FILE"
echo "Total final versions: $((new_index - start))" | tee -a "$LOG_FILE"
echo "Log saved in: ${LOG_FILE}" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"

exit 0
