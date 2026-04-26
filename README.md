# 上市公司资本结构影响因素分析

> [作业要求](https://github.com/lianxhcn/dsfin/blob/main/homework/ex_P03_Panel-capital_strucuture.md)

## 个人信息

- 姓名：赵一骏
- 邮箱：<zhaoyijun@example.com>
---
### GitHub 仓库

https://github.com/real-Yijun/dshw--panel.git

### Quarto Book（如完成）


---

### 数据来源

- CSMAR，下载时间：2026-04-22
- 最终样本：4,513 家公司，37,238 个公司-年观测值，2011—2025 年

### 样本筛选流程

| 筛选步骤 | 剔除观测数 | 剩余观测数 | 剩余公司数 |
|---------|----------|----------|----------|
| 初始样本（2010-2025，全部A股） | — | 57,879 | 5,680 |
| 剔除金融保险（证监会行业代码 J 开头） | 1,305 | 56,574 | 5,588 |
| 剔除曾被 ST/PT 处理的公司 | 10,727 | 45,847 | 4,738 |
| 剔除资不抵债样本（Lev > 1） | 25 | 45,822 | 4,738 |
| 剔除关键变量缺失值（Lev、NPR、Size、Tang、Growth、NDTS、SOE、ind_code） | 8,584 | 37,238 | 4,513 |
| **最终样本** | — | **37,238** | **4,513** |

### 工具

- Stata 17.0（主要建模：M1' IFE / M2-M5 分组回归 / M6 门槛模型）
- Python 3.12（数据处理：pandas、numpy、scipy；基准回归 M1：pyfixest；门槛模型 M6：linearmodels）
- Jupyter Notebook

### 主要发现

1. **A 股整体支持优序融资理论**：M1 基准回归显示，NPR 系数为 −0.618（t = −11.41），在公司与年度双向聚类标准误下高度显著。盈利能力越强的企业杠杆率越低，与权衡理论预期的正相关相反。

2. **产权性质显著调节 NPR-Lev 关系**：国有企业 NPR 系数（−0.836）是民营企业（−0.513）的 1.6 倍，交互项检验（F = 18.65, p = 0.0007）证实组间差异在 1% 水平显著。国企盈利后主动降杠杆的行为更为强烈。

3. **NPR-Lev 关系呈现三阶段时序演变**：2011-2013 年维持强负向（β_t ≈ −0.74）；2015-2020 年受去杠杆政策和贸易摩擦影响明显减弱（β_t 降至 −0.38）；2022 年后重新强化，2024 年达 −0.95，优序融资效应再次主导。

4. **企业规模存在非线性的异质性调节**：M5 多项式模型 β(Size) = −30.289 + 2.699×Size − 0.061×Size²，拐点约在 Size = 22.12（~4 亿元总资产）。M6 门槛值 γ̂ = 23.36（~P64，约 140 亿元），两者结构性转折位置接近，互为稳健性检验。

5. **IFE 压缩但不消除 NPR 效应**：引入交互固定效应后 NPR 系数从 −0.618 缩至 −0.392（减少 36%），说明部分负向关系由不可观测的时变异质性驱动，但 NPR 的因果效应依然稳健。

---

## 项目结构

```
hw/
├── .gitignore                         ← Git 忽略配置
├── README.md                          ← 本文件
├── Notebook/
│   ├── 01_variable_construction.ipynb  ← 变量构造、样本筛选、Winsorize
│   ├── 02_descriptive_statistics.ipynb← 分组描述统计、相关系数、时序趋势图
│   ├── 03_M1.ipynb                    ← M1 TWFE（Python/pyfixest）& M1' IFE（Stata/regife）
│   ├── 03_M2.ipynb                    ← M2 分组回归（SOE vs Non-SOE）
│   ├── 03_M3.ipynb                    ← M3 交互项调节效应 & Margins Plot
│   ├── 03_M4.ipynb                    ← M4 时变系数模型 & β_t 时序图
│   ├── 03_M5.ipynb                    ← M5 函数系数模型（多项式调节）
│   └── 03_M6.ipynb                    ← M6 门槛模型（Python/linearmodels）
├── data/
│   ├── raw/                           ← 原始 CSMAR 数据（未上传 GitHub）
│   │   ├── balance_sheet.csv         ← 资产负债表
│   │   ├── income_stmt.csv           ← 利润表
│   │   ├── cashflow.csv              ← 现金流量表
│   │   ├── ownership.csv             ← 股权性质
│   │   ├── industry.csv              ← 行业分类
│   │   ├── st.csv                    ← ST/PT 标记
│   │   └── m2.csv                    ← M2 宏观数据
│   └── clean/
│       ├── 01/                       ← 第1章处理结果
│       │   ├── sample_screening_1_3.csv
│       │   ├── panel_filtered_winsor_1_5.csv
│       │   └── winsorize_summary_1_5.csv
│       └── 02/                       ← 第2章处理结果
│           ├── desc_stats_2_1_by_group.csv
│           ├── ttest_2_1_soe_vs_nonsoe.csv
│           └── corr_matrix_2_2.csv
├── output/
│   ├── figures/
│   │   ├── Fig1_Lev_trend_SOE_vs_NonSOE.png
│   │   ├── Fig2_NPR_trend_SOE_vs_NonSOE.png
│   │   ├── Fig2_winsorize_boxplot_comparison.png
│   │   ├── Fig3_Lev_boxplot_by_year.png
│   │   ├── Fig3_correlation_heatmap.png
│   │   ├── M3_marginsplot.png
│   │   ├── M4_beta_timevarying.png
│   │   ├── M5_beta_size_curve.png
│   │   └── M6_threshold_curve.png
│   └── model/
│       ├── M1_M6_summary_table.csv
│       ├── M2_grouped_results.txt
│       ├── M3_interaction_results.txt
│       ├── M4_beta_yearly.csv
│       ├── M4_timevarying_results.txt
│       ├── M5_size_function_results.txt
│       └── M6_threshold_results.txt
└── document/
    ├── ex_P03_Panel-capital_strucuture.md
    └── 04_report.md                  ← 第四部分完整文字报告（重点）
```