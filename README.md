# CombiningTCSTCP: Combined Test Selection and Prioritization Tool

A comprehensive tool for combining test selection with test prioritization techniques to optimize regression testing.

## 📋 Overview

This project provides a framework for evaluating combined test selection and prioritization approaches across multiple Defects4J projects. 

## 🚀 Prerequisites

### 1. **Defects4J**
- Must be installed and configured
- Ensure `defects4j` command is available in PATH
- Defects4J should be located at `../defects4j` relative to this project

### 2. **Java and Build Tools**
- **Java 8+** (compatible with Defects4J)
- **Maven 3.6+** (for Maven projects)
- **Ant 1.10+** (for Ant projects)

### 3. **Python Dependencies**
- **Python 3.8+** with the following packages:
  - `os`, `sys`, `re`, `time`, `math`, `random`
- Ensure Python scripts are accessible in the `tools/` directory

### 4. **Test Selection Tools**
- **Ekstazi**: Maven plugin for test selection
- **STARTS**: Maven plugin for test selection (for STARTS experiments)

### 5. **R** (Optional, for analysis)
- R and RStudio for statistical analysis
- Required R packages: `tidyverse`, `ggplot2`, `dplyr`, `readr`



## 🛠️ Installation & Setup

1. **Clone and navigate to the project:**
   ```bash
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

🏃‍♂️ Usage
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


🐛 Troubleshooting
Common Issues

    Defects4J not found:
    

Error: defects4j command not found

Solution: Ensure Defects4J is installed and in PATH

Maven plugin errors:


Plugin 'org.ekstazi:ekstazi-maven-plugin' not found

Solution: Install Ekstazi Maven plugin or adjust pom.xml configuration

Permission denied:


./scripts/run_multiple.sh: Permission denied

Solution: chmod +x scripts/*.sh

Python script errors:


ModuleNotFoundError: No module named '...'

    Solution: Install required Python packages

📝 Notes

    Execution time varies by project size (from minutes to hours)

    Ensure sufficient disk space for Defects4J repositories

    The tool automatically renames directories and synchronizes results

🙏 Acknowledgements

    Defects4J team for the benchmark

    Ekstazi and STARTS developers
    
    FAST developers

    All contributors to this project

For questions or issues, please open an issue on the GitHub repository.
