# 上市公司资本结构影响因素分析

基于 A 股面板数据的实证研究 | 赵一骏 | 2026-04

---

## 📖 在线阅读

**Quarto Book 网址**：https://real-Yijun.github.io/dshw--panel/

## 📂 项目结构

```
hw/
├── _quarto.yml              ← Quarto 项目配置
├── index.qmd                ← 封面与目录
├── styles.css               ← 自定义样式
├── src/                     ← 章节内容
│   ├── 01-intro.qmd         ← 第1章：研究背景与假设
│   ├── 02-data.qmd          ← 第2章：数据与变量
│   ├── 03-results.qmd       ← 第3章：实证结果
│   ├── 04-robustness.qmd    ← 第4章：稳健性检验
│   └── 05-conclusion.qmd    ← 第5章：结论
├── docs/                    ← Quarto 构建输出（GitHub Pages）
├── Notebook/                ← Jupyter Notebook 分析代码
├── data/                    ← 数据文件
├── output/                  ← 模型结果与图片
└── document/                ← 作业要求与文字报告
```

## 📊 主要内容

| 章节 | 主题 | 核心发现 |
|------|------|---------|
| 第1章 | 研究背景与假设 | 优序融资 vs 权衡理论推导 |
| 第2章 | 数据与变量 | 4,513家公司，37,238观测值 |
| 第3章 | 实证结果 | M1-M6 六组模型完整分析 |
| 第4章 | 稳健性检验 | 多维度稳健性验证 |
| 第5章 | 结论 | 理论贡献与政策启示 |

## 🔧 分析工具

- **Stata 17.0**：reghdfe, regife, xthreg
- **Python 3.12**：pandas, pyfixest, linearmodels
- **Quarto**：在线文档发布

## 🚀 本地构建

```bash
# 安装 Quarto
# 见 https://quarto.org/docs/get-started/

# 预览书籍
quarto preview

# 构建 HTML 版本
quarto render

# 输出至 docs/ 目录，可直接部署至 GitHub Pages
```

## 🌐 GitHub Pages 部署

1. 将 `docs/` 目录推送到 GitHub 仓库
2. 在仓库 Settings → Pages → Source 选择 `main` 分支的 `/docs` 文件夹
3. 等待几分钟，网站将在 `https://real-Yijun.github.io/dshw--panel/` 上线

## 📝 样本筛选

| 筛选步骤 | 剩余观测数 | 剩余公司数 |
|---------|----------|----------|
| 初始样本 | 57,879 | 5,680 |
| 剔除金融保险 | 56,574 | 5,588 |
| 剔除 ST/PT | 45,847 | 4,738 |
| 剔除资不抵债 | 45,822 | 4,738 |
| 剔除缺失值 | 37,238 | 4,513 |

**最终样本**：2011—2025年，4,513家公司，37,238个公司-年观测值

---

*GitHub 仓库*：https://github.com/real-Yijun/dshw--panel
*联系作者*：zhaoyijun@example.com