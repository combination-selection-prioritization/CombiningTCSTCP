import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Carregar dados
df = pd.read_csv('avg_all.csv')

# Configurações visuais
plt.style.use('seaborn-v0_8-whitegrid')
colors = {'ApproachTime': '#4C72B0', 'TestTime': '#55A868'}

# ---- FORÇAR COLUNAS NUMÉRICAS ----
for col in ['ApproachTime', 'Test time', 'TTFF Total', 'TTFF (seconds)']:
    df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0)

# ---- MEDIANA GLOBAL POR SUITE (todos os projetos) ----
median_df = (
    df.groupby('Suite')[['ApproachTime', 'Test time', 'TTFF Total', 'TTFF (seconds)']]
      .median()
      .reset_index()
)

# ---- ORDENAR PELO TTFF TOTAL (menor -> maior) ----
median_df = median_df.sort_values('TTFF Total', ascending=True)

# Listas ordenadas
ferramentas = median_df['Suite'].tolist()
approach_times = median_df['ApproachTime'].tolist()
test_times = median_df['Test time'].tolist()
ttff_seconds = median_df['TTFF (seconds)'].tolist()
ttff_total = median_df['TTFF Total'].tolist()

# Posições das barras
x_pos = np.arange(len(ferramentas))

# Criar figura
fig, ax = plt.subplots(figsize=(16, 9))

# Barras empilhadas
ax.bar(x_pos, test_times, bottom=approach_times, color=colors['TestTime'], alpha=0.7,
       label='Test Execution Time', edgecolor='black')
ax.bar(x_pos, approach_times, color=colors['ApproachTime'], alpha=0.7,
       label='Tool Analysis Time', edgecolor='black')

# Bullets do TTFF
for i, (approach, ttff) in enumerate(zip(approach_times, ttff_seconds)):
    ax.plot(i, approach + ttff, 'o', markersize=10, color='red', markeredgecolor='black')

# Customizar gráfico
ax.set_title('Test Execution Analysis (Median across ALL Projects)', fontsize=16, fontweight='bold')
ax.set_xlabel('Tools (Suites)', fontsize=14)
ax.set_ylabel('Time (seconds)', fontsize=14)
ax.set_xticks(x_pos)
ax.set_xticklabels(ferramentas, rotation=45, ha='right')

# Adicionar valores nas barras
max_height = max([a + t for a, t in zip(approach_times, test_times)])
for i, (approach, test, total) in enumerate(zip(approach_times, test_times, ttff_total)):
    ax.text(i, approach + test + (max_height * 0.02), f'{total:.1f}s',
            ha='center', va='bottom', fontsize=10, fontweight='bold')

# Legenda
ax.legend(loc='upper right')

# Ajuste eixo Y
ax.set_ylim(0, max_height * 1.15)
ax.grid(axis='y', alpha=0.3)

# Ajustar layout e salvar direto
plt.tight_layout()
filename = 'test_analysis_ALLPROJECTS_median_ordered'
plt.savefig(f'{filename}.png', dpi=300, bbox_inches='tight')
plt.savefig(f'{filename}.pdf', bbox_inches='tight')
plt.close(fig)

print(f"Gráfico salvo: {filename}.png")
print(f"Gráfico salvo: {filename}.pdf")
