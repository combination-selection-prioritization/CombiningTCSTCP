CombiningTCSTCP: Combined Test Selection and Prioritization Tool

A comprehensive tool for combining test selection with test prioritization techniques to optimize regression testing.
Overview

This project provides a framework for evaluating combined test selection and prioritization approaches across multiple Defects4J projects. 
Prerequisites
1. Defects4J

    Must be installed and configured

    Ensure defects4j command is available in PATH

    Defects4J should be located at ../defects4j relative to this project

2. Java and Build Tools

    Java 8+ (compatible with Defects4J)

    Maven 3.6+ (for Maven projects)

    Ant 1.10+ (for Ant projects)

3. Python Dependencies

    Python 3.8+ with the following packages:

        os, sys, re, time, math, random..

    Ensure Python scripts are accessible in the tools/ directory

4. Test Selection Tools

    Ekstazi: Maven plugin for test selection

    STARTS: Maven plugin for test selection (for STARTS experiments)

5. R 

    R and RStudio for statistical analysis

    Required R packages: tidyverse, ggplot2, dplyr, readr

Project Structure
text

CombiningTCSTCP/
├── scripts/
│   ├── combine_raw_files.sh      # Combine metrics from all projects
│   ├── run_multiple.sh           # Main execution script
│   ├── run_comb_v1.sh            # Run combined approach 
│   ├── run_starts_v1.sh          # Run combined approach 
│   ├── run_multiple_starts.sh    # Run STARTS on multiple projects
│   ├── run_multiple_metrics.sh   # Calculate metrics for all projects
│   ├── metrics.sh                # Metrics calculation script
│   ├── prepare_repos.sh          # Prepare repositories 
│   ├── prepare_repos_starts.sh   # Prepare repositories 
│   └── sync_repos.sh            # Synchronize results between tools
├── tools/
│   ├── path.py                  # Path manipulation utilities
│   ├── dpt.py                   # Dynamic Prioritization Technique
│   ├── fast_parser.py           # FAST test parser
│   ├── prioritize.py            # Test prioritization
│   ├── combine.py               # Combine selection and prioritization
│   ├── metric.py                # Metrics calculation
│   └── ... (other Python utilities)


Installation & Setup

    Clone and navigate to the project:

git clone <repository-url>
cd CombiningTCSTCP

Ensure Defects4J is properly set up:


# Defects4J should be in the parent directory
ls ../defects4j/

Make scripts executable:

chmod +x scripts/*.sh

Install required Python packages:

# Install any required external packages if needed
pip install -r requirements.txt  # if provided

Usage
Basic Execution

To run the complete pipeline:

./scripts/run_multiple.sh

This script will:

    Run the combined approach with Ekstazi for all projects

    Run the combined approach with STARTS for all projects

    Calculate metrics for all projects

    Combine results into consolidated CSV files

Project Configuration

Projects are configured in run_multiple.sh with:

    Projects: Defects4J project names

    Starts: Starting version numbers

    Ends: Ending version numbers

    Builds: Build system (mvn/ant)

Output

Results are organized in:

    repos/<project>/<version>_results/: Individual version results

    metrics/<project>/: Per-project metrics (raw.csv, avg.csv, time.csv)

    metrics/all/: Combined metrics across all projects


Configuration
Skipped Versions

Some Defects4J versions are skipped. The count is stored in ${project}_skipped.txt.
Project-specific Adjustments



Notes

    Execution time varies by project size (from minutes to hours)

    Ensure sufficient disk space for Defects4J repositories

    The tool automatically renames directories and synchronizes results


Acknowledgements

    Defects4J team for the benchmark

    Ekstazi and STARTS developers
    
    FAST developers

    All contributors to this project

For questions or issues, please open an issue on the GitHub repository.
