#!/bin/bash

# Script to filter and renumber versions that have defects4j.build.properties
# Usage: ./filter_versions_to_seq.sh

abs="/home/danilotorquato/repos/CombiningTCSTCP"
repos_dir="${abs}/repos"
repos_seq_dir="${abs}/repos_seq"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global counters
total_projects=0
total_versions_processed=0
total_versions_filtered=0
total_versions_copied=0

echo "========================================="
echo "FILTERING VERSIONS WITH defects4j.build.properties"
echo "========================================="
echo "Source: $repos_dir"
echo "Target: $repos_seq_dir"
echo ""
echo "RULE: Only versions that have defects4j.build.properties will be kept"
echo ""

mkdir -p "$repos_seq_dir"

read -p "Do you want to clean the $repos_seq_dir directory before starting? (s/N): " clean_target
if [[ "$clean_target" =~ ^[Ss]$ ]]; then
    echo "Cleaning $repos_seq_dir..."
    rm -rf "${repos_seq_dir:?}"/*
    echo "[OK] Directory cleaned"
    clean_mode=true
else
    echo "[INFO] Incremental mode: existing projects will be skipped"
    clean_mode=false
fi
echo ""

for project_path in "$repos_dir"/*; do
    if [ ! -d "$project_path" ]; then
        continue
    fi
    
    project_name=$(basename "$project_path")
    
    # Check if project already exists in destination and we're not in clean mode
    if [ "$clean_mode" = false ] && [ -d "${repos_seq_dir}/${project_name}" ]; then
        echo -e "${YELLOW}⏭ Project $project_name already exists in destination, skipping...${NC}"
        continue
    fi
    
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}Processing project: $project_name${NC}"
    echo -e "${BLUE}=========================================${NC}"
    
    target_project_dir="${repos_seq_dir}/${project_name}"
    mkdir -p "$target_project_dir"
    
    # List all _fixed versions and sort numerically
    versions=$(ls -d "$project_path"/*_fixed 2>/dev/null | sed 's/.*\///' | sed 's/_fixed$//' | sort -n)
    
    if [ -z "$versions" ]; then
        echo -e "${YELLOW}  No versions found for $project_name${NC}"
        continue
    fi
    
    total_projects=$((total_projects + 1))
    project_versions=0
    project_valid=0
    project_copied=0
    
    valid_versions=()
    
    echo "  Step 1: Identifying versions with defects4j.build.properties..."
    for v in $versions; do
        project_versions=$((project_versions + 1))
        total_versions_processed=$((total_versions_processed + 1))
        
        fixed_dir="${project_path}/${v}_fixed"
        props_file="${fixed_dir}/defects4j.build.properties"
        
        if [ -f "$props_file" ]; then
            valid_versions+=($v)
            project_valid=$((project_valid + 1))
            total_versions_filtered=$((total_versions_filtered + 1))
            
            # Extract bug id for display
            bug_id=$(grep "^d4j.bug.id=" "$props_file" | cut -d'=' -f2)
            echo -e "    ${GREEN}✓ Version $v is VALID (bug ${bug_id})${NC}"
        else
            echo -e "    ${RED}✗ Version $v is INVALID (no defects4j.build.properties)${NC}"
        fi
    done
    
    echo ""
    echo "  Valid versions found: ${#valid_versions[@]} of $project_versions"
    
    if [ ${#valid_versions[@]} -gt 0 ]; then
        echo "  Step 2: Copying and renumbering valid versions..."
        new_version=1
        for old_version in "${valid_versions[@]}"; do
            
            old_fixed="${project_path}/${old_version}_fixed"
            new_fixed="${target_project_dir}/${new_version}_fixed"
            
            old_results="${project_path}/${old_version}_results"
            new_results="${target_project_dir}/${new_version}_results"
            
            echo -e "    Version $old_version → $new_version"
            
            cp -r "$old_fixed" "$new_fixed" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "      ${GREEN}✓ Copied _fixed${NC}"
            else
                echo -e "      ${RED}✗ Failed to copy _fixed${NC}"
            fi
            
            if [ -d "$old_results" ]; then
                cp -r "$old_results" "$new_results" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "      ${GREEN}✓ Copied _results${NC}"
                    project_copied=$((project_copied + 1))
                    total_versions_copied=$((total_versions_copied + 1))
                else
                    echo -e "      ${RED}✗ Failed to copy _results${NC}"
                fi
            else
                echo -e "      ${YELLOW}⚠ No _results directory for version $old_version${NC}"
            fi
            
            new_version=$((new_version + 1))
        done
        
        # Save mapping
        mapping_file="${target_project_dir}/version_mapping.txt"
        echo "# Original version -> New version mapping" > "$mapping_file"
        echo "# Generated: $(date)" >> "$mapping_file"
        echo "# Only versions with defects4j.build.properties were kept" >> "$mapping_file"
        echo "" >> "$mapping_file"
        
        new_version=1
        for old_version in "${valid_versions[@]}"; do
            old_fixed="${project_path}/${old_version}_fixed"
            props_file="${old_fixed}/defects4j.build.properties"
            bug_id=$(grep "^d4j.bug.id=" "$props_file" | cut -d'=' -f2 2>/dev/null || echo "unknown")
            echo "$old_version (bug $bug_id) -> $new_version" >> "$mapping_file"
            new_version=$((new_version + 1))
        done
        
        echo -e "  ${GREEN}✓ Version mapping saved to: $mapping_file${NC}"
        
    else
        echo -e "  ${YELLOW}No valid versions found for $project_name, skipping...${NC}"
        rmdir "$target_project_dir" 2>/dev/null
    fi
    
    echo ""
done

# ============================================
# FINAL STEP: Rename directories
# ============================================
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Renaming directories${NC}"
echo -e "${BLUE}=========================================${NC}"

# Check if repos_seq exists and has content
if [ -d "$repos_seq_dir" ] && [ -n "$(ls -A $repos_seq_dir 2>/dev/null)" ]; then
    # Rename repos to repos_original
    if [ -d "$repos_dir" ]; then
        echo "Renaming $repos_dir to ${repos_dir}_original..."
        mv "$repos_dir" "${repos_dir}_original"
        echo -e "${GREEN}✓ Renamed to ${repos_dir}_original${NC}"
    fi
    
    # Rename repos_seq to repos
    echo "Renaming $repos_seq_dir to $repos_dir..."
    mv "$repos_seq_dir" "$repos_dir"
    echo -e "${GREEN}✓ Renamed to $repos_dir${NC}"
    
    echo ""
    echo -e "${GREEN}✓ Directory swap completed!${NC}"
    echo -e "  Original repositories (unfiltered): ${repos_dir}_original"
    echo -e "  Filtered and renumbered repositories: $repos_dir"
else
    echo -e "${YELLOW}⚠ $repos_seq_dir is empty or does not exist. No renaming performed.${NC}"
fi

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}FINAL SUMMARY${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "Projects processed: $total_projects"
echo -e "Total versions processed: $total_versions_processed"
echo -e "Total valid versions found (with defects4j.build.properties): $total_versions_filtered"
echo -e "Total versions copied: $total_versions_copied"
echo ""
echo -e "${GREEN}Done! Filtered versions are now available at:${NC}"
echo -e "${GREEN}$repos_dir${NC}"
echo -e "${YELLOW}Original unfiltered versions saved at: ${repos_dir}_original${NC}"
echo ""

exit 0
