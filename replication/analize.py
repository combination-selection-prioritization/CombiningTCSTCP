import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Set style for academic papers
plt.style.use('seaborn-v0_8-whitegrid')
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.size'] = 10

# Load data
df = pd.read_csv('avg_all.csv')

# Color palette for academic paper
colors = ['#4C72B0', '#55A868', '#C44E52', '#8172B2', '#CCB974', '#64B5CD', '#4C8C4A', '#A85959', '#7B7BB8']

def save_both_formats(filename):
    """Salva em PNG e PDF"""
    plt.savefig(f'{filename}.png', dpi=300, bbox_inches='tight')
    plt.savefig(f'{filename}.pdf', bbox_inches='tight')

# GRAPH 1: Average TTFF Total for each tool
plt.figure(figsize=(10, 6))
ttff_means = df.groupby('Suite')['TTFF Total'].median().sort_values()

bars = plt.bar(ttff_means.index, ttff_means.values, color=colors[0], edgecolor='black', alpha=0.8)
for bar in bars:
    height = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2., height + 0.3, f'{height:.2f}s', 
             ha='center', va='bottom', fontsize=9)

plt.title('Total Time to First Failure by Tool', fontsize=12, fontweight='bold')
plt.xlabel('Tool', fontsize=11)
plt.ylabel('TTFF Total (seconds)', fontsize=11)
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
save_both_formats('ttff_total')
plt.show()

# GRAPH 2: Tool Overhead Percentage
plt.figure(figsize=(10, 6))
approach_means = df.groupby('Suite')['ApproachTime / total.exec.time (%)'].median().sort_values(ascending=False)

bars = plt.bar(approach_means.index, approach_means.values, color=colors[1], edgecolor='black', alpha=0.8)
for bar in bars:
    height = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2., height + 0.5, f'{height:.2f}%', 
             ha='center', va='bottom', fontsize=9)

plt.title('Tool Overhead (% of Total Execution Time)', fontsize=12, fontweight='bold')
plt.xlabel('Tool', fontsize=11)
plt.ylabel('ApproachTime / Total Time (%)', fontsize=11)
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
save_both_formats('tool_overhead_percentage')
plt.show()

# GRAPH 3: Average pTTFF (Percentage)
plt.figure(figsize=(10, 6))
pttff_means = df.groupby('Suite')['pTTFF'].median().sort_values()

bars = plt.bar(pttff_means.index, pttff_means.values, color=colors[2], edgecolor='black', alpha=0.8)
for bar in bars:
    height = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2., height + 0.01, f'{height:.2f}', 
             ha='center', va='bottom', fontsize=8)

plt.title('Normalized TTFF (pTTFF) by Tool', fontsize=12, fontweight='bold')
plt.xlabel('Tool', fontsize=11)
plt.ylabel('Normalized TTFF (pTTFF)', fontsize=11)
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
save_both_formats('pttff')
plt.show()

# GRAPH 4: Average Approach Time (seconds)
plt.figure(figsize=(10, 6))
approach_time_means = df.groupby('Suite')['ApproachTime'].median().sort_values(ascending=False)

bars = plt.bar(approach_time_means.index, approach_time_means.values, color=colors[3], edgecolor='black', alpha=0.8)
for bar in bars:
    height = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2., height + 0.1, f'{height:.2f}s', 
             ha='center', va='bottom', fontsize=9)

plt.title('Approach Time by Tool', fontsize=12, fontweight='bold')
plt.xlabel('Tool', fontsize=11)
plt.ylabel('Approach Time (seconds)', fontsize=11)
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
save_both_formats('approach_time')
plt.show()

# GRAPH 5: Average Absolute TTFF (seconds)
plt.figure(figsize=(10, 6))
ttff_seconds_means = df.groupby('Suite')['TTFF (seconds)'].median().sort_values()

bars = plt.bar(ttff_seconds_means.index, ttff_seconds_means.values, color=colors[4], edgecolor='black', alpha=0.8)
for bar in bars:
    height = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2., height + 0.3, f'{height:.2f}s', 
             ha='center', va='bottom', fontsize=9)

plt.title('Absolute TTFF by Tool', fontsize=12, fontweight='bold')
plt.xlabel('Tool', fontsize=11)
plt.ylabel('TTFF (seconds)', fontsize=11)
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
save_both_formats('absolute_ttff')
plt.show()

# Print numerical summaries
print("=" * 60)
print("SUMMARY STATISTICS")
print("=" * 60)

print("\n1. Average TTFF Total by Tool (seconds):")
print(ttff_means.round(2).sort_values())

print("\n2. Average Overhead by Tool (%):")
print(approach_means.round(2).sort_values(ascending=False))

print("\n3. Average Normalized TTFF (pTTFF):")
print(pttff_means.round(2).sort_values())

print("\n4. Average Approach Time (seconds):")
print(approach_time_means.round(2).sort_values(ascending=False))

print("\n5. Average Absolute TTFF (seconds):")
print(ttff_seconds_means.round(2).sort_values())
