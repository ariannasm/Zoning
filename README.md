
**"An AI-based analysis of zoning reforms in US cities"**
*Salazar-Miranda, A., Talen, E.*

Below is an outline of each script along with the input and output files to reproduce the figures and tables in the paper. 

---

## Python Scripts

### `figure_1.py`
- **Description:** PCA and similarity scores from document embeddings.
- **Inputs:**  
  - `avg_embeddings_bird_nu.pkl`  
  - `avg_embeddings_municode_bird.pkl`  
  - `avg_embeddings_bird_drei.pkl`  
  - `regression_data_all.csv`
- **Outputs:**  
  - `fig1.png` (in the `figures/` folder)

---

### `figure_2.py`
- **Description:** Word clouds for top and bottom city themes and FBC repository themes.
- **Inputs:**  
  - CSV files from `chatgpt_setbacks/` and `chatgpt_far/`  
  - `regression_data_all.csv`
- **Outputs:**  
  - `fig2.png` (in the `figures/` folder)

---

### `figure_3.py`
- **Description:** Relationship between the Wharton Regulatory Index and FBC similarity.
- **Inputs:**  
  - `similarity_scores.csv`  
  - `skeleton_global.csv`  
  - `codes_merge_census.csv`
- **Outputs:**  
  - `fig3.png` (in the `figures/` folder)

---

### `figure_4.py`
- **Description:** Map of FBC similarity.
- **Inputs:**  
  - `regression_data_all.csv`  
  - Shapefiles: `tl_2021_us_uac10.shp`, `US_place_2010.shp`, `usa_contour.shp`
- **Outputs:**  
  - `fig4.png` (in the `figures/` folder)

---

### `figure_S1.py`
- **Description:** Summary statistics for zoning documents.
- **Inputs:**  
  - `zoning_docs_bird_chunked.pkl`  
  - Raw text files from the shared code text database  
  - `regression_data_all.csv`
- **Outputs:**  
  - `figS1.png` (in the `figures/` folder)

---

## Stata Scripts

### `figure_5a.do`
- **Description:** Regression figure panel a (setbacks, FAR, minimum plot size).
- **Inputs:**  
  - `regression_data_all.dta`  
  - `regression_data_subset.dta`
- **Outputs:**  
  - `fig5_a.png` (in the `figures/` folder)  

---

### `figure_5b.do`
- **Description:** Regression figure panel b (walkscore, commute, multi-family housing).
- **Inputs:**  
  - `regression_data_all.dta`  
  - `regression_data_subset.dta`
- **Outputs:**  
  - `fig5_b.png` (in the `figures/` folder)  

---

### `table_1.do`
- **Description:** Summary statistics for demographic and economic variables.
- **Inputs:**  
  - `descriptive_nu_zoning.dta`
- **Outputs:**  
  - LaTeX tables (saved in the `tables/` folder)

---

### `tables_supplementary.do`
- **Description:** Regressions with additional controls.
- **Inputs:**  
  - `regression_data_all.dta`  
  - `regression_data_subset.dta`
- **Outputs:**  
  - LaTeX tables (saved in the `tables/` folder)

---

Please contact arianna.salazarmiranda@yale.edu if you have questions regarding the code or data. 