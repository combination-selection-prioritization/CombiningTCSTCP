#!/bin/bash

set -e  # Para o script em caso de erro


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


BASE_DIR="$(pwd)"
REPOS_DIR="$BASE_DIR/repos"
EKSTAZI_DIR="$BASE_DIR/repos_ekstazi"


log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}


check_directories() {
    if [ ! -d "$REPOS_DIR" ]; then
        log_error "Dir $REPOS_DIR not found!"
        exit 1
    fi
    
    if [ ! -d "$EKSTAZI_DIR" ]; then
        log_error "Dir $EKSTAZI_DIR not found!"
        exit 1
    fi
}


discover_projects() {
    log_info "Searching projcts $EKSTAZI_DIR..."
    

    local projects=$(find "$EKSTAZI_DIR" -maxdepth 1 -type d -name "[A-Za-z]*" | grep -v "^$EKSTAZI_DIR$" | sort)
    
    if [ -z "$projects" ]; then
        log_warn "Not found $EKSTAZI_DIR"
        return 1
    fi
    

    echo "$projects" | while read -r project_path; do
        if [ -n "$project_path" ] && [ "$project_path" != "$EKSTAZI_DIR" ]; then
            basename "$project_path"
        fi
    done
}


process_project() {
    local project_name="$1"
    local project_path="$EKSTAZI_DIR/$project_name"
    local target_project="$REPOS_DIR/$project_name"
    
    log_info "Project: $project_name"
    

    if [ ! -d "$target_project" ]; then
        log_warn "Project $project_name does not exist in $REPOS_DIR..."
        return 0
    fi
    

    local versions=$(find "$project_path" -maxdepth 1 -type d -name "*_results" | sort)
    
    if [ -z "$versions" ]; then
        log_warn "No version for $project_name"
        return 0
    fi
    
    log_info "  Versions for: $(echo "$versions" | wc -l)"
    

    while IFS= read -r version_path; do
        if [ -n "$version_path" ]; then
            process_version "$project_name" "$version_path"
        fi
    done <<< "$versions"
}


process_version() {
    local project_name="$1"
    local version_path="$2"
    local version_name=$(basename "$version_path")
    local target_version="$REPOS_DIR/$project_name/$version_name"
    
    log_info "  Version: $version_name"
    

    if [ ! -d "$target_version" ]; then
        log_warn "    Version $version_name does not exist $REPOS_DIR/$project_name..."
        return 0
    fi
    

    copy_directories "$version_path" "$target_version"
    

    copy_files "$version_path" "$target_version"
    

    process_special_renames "$target_version" "$version_path"
}


copy_directories() {
    local source_dir="$1"
    local target_dir="$2"
    
    local directories=("dpt" "ekstazi_dir" "ekstazi_dpt" "ekstazi_rand")
    
    for dir in "${directories[@]}"; do
        local source_path="$source_dir/$dir"
        local target_path="$target_dir/$dir"
        
        if [ -d "$source_path" ]; then
            log_info "    Copying: $dir"

            rm -rf "$target_path"
            cp -r "$source_path" "$target_path"
        else
            log_warn "    Dir $dir not found $source_dir"
        fi
    done
}


copy_files() {
    local source_dir="$1"
    local target_dir="$2"
    
    local files=(".txt")
    
    for file in "${files[@]}"; do
        local source_file="$source_dir/$file"
        local target_file="$target_dir/$file"
        
        if [ -f "$source_file" ]; then
            log_info "    Files: $file"
            cp "$source_file" "$target_file"
        else
            log_warn "    file $file not found in $source_dir"
        fi
    done
}


process_special_renames() {
    local target_version="$1"
    local source_version="$2"
    

    local special_dirs=("comb_p" "comb_s" "time")
    
    for special_dir in "${special_dirs[@]}"; do
        local target_path="$target_version/$special_dir"
        local ekstazi_source="$source_version/$special_dir"
        local backup_name="${special_dir}_starts"
        

        if [ -d "$target_path" ]; then
            log_info "     $special_dir  $backup_name"
            mv "$target_path" "$target_version/$backup_name"
        else
            log_warn "    Dir $special_dir not found in $target_version "
        fi
        

        if [ -d "$ekstazi_source" ]; then
            log_info "    Copying $special_dir  repos_ekstazi"
            cp -r "$ekstazi_source" "$target_version/$special_dir"
        else
            log_warn "    Dir $special_dir not found repos_ekstazi"
        fi
    done
}


main() {

    
    check_directories
    

    local projects=$(discover_projects)
    
    if [ -z "$projects" ]; then

        exit 1
    fi
    

    echo "$projects"
    echo
    

    while IFS= read -r project; do
        if [ -n "$project" ]; then
            process_project "$project"
            echo
        fi
    done <<< "$projects"
    

}


main "$@"
