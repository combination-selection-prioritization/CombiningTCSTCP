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
# PHASE 1: Original Defects4J checkout (IDENTICAL - WITHOUT CHANGING A COMMA)
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
                    python3 tools/build_patcher_starts.py ${project_dir}/ant/build.xml ant
                else
                    python3 tools/build_patcher_starts.py ${project_dir}/build.xml ant
                fi
            fi

            if [ ${build} = "mvn" ]; then
                python3 tools/build_patcher_starts.py ${project_dir}/pom.xml mvn
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
                python3 tools/build_patcher_starts.py ${project_dir}/build.xml ant
            fi

            if [ ${build} = "mvn" ]; then
                if [ ${project} = "Gson" ]; then
                    python3 tools/build_patcher_starts.py ${project_dir}/gson/pom.xml mvn
                else
                    python3 tools/build_patcher_starts.py ${project_dir}/pom.xml mvn
                fi
            fi
        else
            skipped=$(expr ${skipped} + 1)
        fi
    done
fi

echo ${skipped} > ${project}_skipped.txt

# ============================================
# PHASE 2: Add previous versions before bugs (FIXED)
# ============================================

echo "========================================="
echo "Adding previous versions before bugs (STARTS)"
echo "========================================="

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

echo "Original repository: ${REPO_ORIGINAL}"

if [ ! -f "$COMMIT_DB" ]; then
    echo "ERROR: commit-db not found"
    exit 1
fi

if [ ! -d "$REPO_ORIGINAL" ]; then
    echo "ERROR: Original repository not found"
    exit 1
fi

# Save original folders
mkdir -p repos/${project}/.originals
mv repos/${project}/*_fixed repos/${project}/.originals/ 2>/dev/null

new_index=${start}

for i in $(seq ${start} ${end}); do
    
    # Avoid processing discarded versions if project is Closure
    if [[ ${project} = "Closure" && ( ( ${i} = 21 ) || ( ${i} = 137 ) || ( ${i} = 146 ) ) ]]; then
        echo "----------------------------------------"
        echo "Skipping Closure version: ${i}"
        continue
    fi

    # FIX: Replicate exact calculation from Phase 1 to find the correct folder
    if [ ${project} = "Chart" ] || [ ${project} = "Math" ] || [ ${project} = "Closure" ] || [ ${project} = "Lang" ] || [ ${project} = "Time" ]; then
        # Reverse projects
        orig_folder_num=$(expr ${end} - ${i} + ${start} + ${skipped})
    else
        # Normal projects
        orig_folder_num=$(expr ${i} - ${skipped})
    fi

    original_dir="repos/${project}/.originals/${orig_folder_num}_fixed"
    
    echo "----------------------------------------"
    echo "Processing Defects4J version: ${i} (Looking for original folder: ${orig_folder_num}_fixed)"
    
    if [ ! -d "${original_dir}" ]; then
        echo "ERROR/WARNING: Original folder not found: ${original_dir}. Skipping pair."
        continue
    fi
    
    commit_buggy=$(grep "^${i}," "$COMMIT_DB" | cut -d',' -f2)
    echo "Original buggy commit: ${commit_buggy}"
    
    if [ -z "$commit_buggy" ]; then
        echo "ERROR: Commit not found"
        cp -r "${original_dir}" "repos/${project}/${new_index}_fixed"
        new_index=$((new_index + 1))
        continue
    fi
    
    # Create previous version (real commit before bug)
    temp_repo="repos/${project}/.temp_${i}"
    git clone --depth 10 "${REPO_ORIGINAL}" "${temp_repo}" 2>/dev/null
    
    cd "${temp_repo}"
    
    if git checkout ${commit_buggy} 2>/dev/null; then
        if git checkout HEAD^ 2>/dev/null; then
            parent_commit=$(git rev-parse --short HEAD)
            parent_msg=$(git log -1 --oneline)
            echo "Previous commit: ${parent_commit}"
            echo "Message: ${parent_msg}"
            
            rm -rf .git
            cd - > /dev/null
            
            mv "${temp_repo}" "repos/${project}/${new_index}_fixed"
            
            # Apply STARTS patch to previous version (adjusted to support subfolders like gson)
            if [ ${build} = "mvn" ]; then
                if [ ${project} = "Gson" ] && [ -f "repos/${project}/${new_index}_fixed/gson/pom.xml" ]; then
                    python3 tools/build_patcher_starts.py "repos/${project}/${new_index}_fixed/gson/pom.xml" mvn
                elif [ -f "repos/${project}/${new_index}_fixed/pom.xml" ]; then
                    python3 tools/build_patcher_starts.py "repos/${project}/${new_index}_fixed/pom.xml" mvn
                fi
                echo "STARTS mvn patch applied"
            fi
            
            if [ ${build} = "ant" ]; then
                if [ ${project} = "Chart" ] && [ -f "repos/${project}/${new_index}_fixed/ant/build.xml" ]; then
                    python3 tools/build_patcher_starts.py "repos/${project}/${new_index}_fixed/ant/build.xml" ant
                elif [ -f "repos/${project}/${new_index}_fixed/build.xml" ]; then
                    python3 tools/build_patcher_starts.py "repos/${project}/${new_index}_fixed/build.xml" ant
                fi
                echo "STARTS ant patch applied"
            fi
            
            echo "CREATED: ${new_index}_fixed (previous to bug ${i})"
            new_index=$((new_index + 1))
        else
            echo "ERROR: Could not checkout HEAD^"
            cd - > /dev/null
            rm -rf "${temp_repo}"
            cp -r "${original_dir}" "repos/${project}/${new_index}_fixed"
            new_index=$((new_index + 1))
            continue
        fi
    else
        echo "ERROR: Commit checkout failed"
        cd - > /dev/null
        rm -rf "${temp_repo}"
        cp -r "${original_dir}" "repos/${project}/${new_index}_fixed"
        new_index=$((new_index + 1))
        continue
    fi
    
    # Move the original Defects4J version
    mv "${original_dir}" "repos/${project}/${new_index}_fixed"
    echo "CREATED: ${new_index}_fixed (original bug ${i})"
    new_index=$((new_index + 1))
done

# Cleanup
rm -rf repos/${project}/.originals
rm -rf repos/${project}/.temp_*

echo "========================================="
echo "Total final versions: $((new_index - start))"
echo "Range: ${start}_fixed to $((new_index - 1))_fixed"
echo "========================================="

exit 0
