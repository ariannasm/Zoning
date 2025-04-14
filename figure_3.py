# code to reproduce the results in Figure 3
# "An AI-based analysis of zoning reforms in US cities"

#-------------------------------------------------------------------------------#
                                 # Packages #
#-------------------------------------------------------------------------------#
import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap
from sklearn.linear_model import LinearRegression
import statsmodels.api as sm
from scipy.stats import linregress
from scipy.stats import pearsonr

#-------------------------------------------------------------------------------#
# Define base directories                                                       #
#-------------------------------------------------------------------------------#
BASE_DIR = ""  # Replication package base folder
DATA_DIR = os.path.join(BASE_DIR, 'data')
FIGURES_DIR = os.path.join(BASE_DIR, 'figures')

#-------------------------------------------------------------------------------#
             # Load data (output of CreateEmbeddingsBirdModel.py) #
#-------------------------------------------------------------------------------#

# Load the similarity scores 
similarity_df = pd.read_csv(os.path.join(DATA_DIR, 'similarity_scores.csv'))
print("Similarity scores observations:", len(similarity_df))

# Load list of all cities
global_df = pd.read_csv(os.path.join(DATA_DIR, 'skeleton_global.csv'))
print("Global DataFrame observations:", len(global_df))

# Load the census DataFrame from the clean data folder
census_df = pd.read_csv(os.path.join(DATA_DIR, 'codes_merge_census.csv'))
print("Census DataFrame observations:", len(census_df))



#-------------------------------------------------------------------------------#
                 # Variable cleaning and construction #
#-------------------------------------------------------------------------------#
# Create a FileName column in similarity_df to merge with other data
similarity_df['FileName'] = similarity_df['Document Name'] + '.txt'

# Merge similarity scores with city skeleton using "FileName"
merged_df = pd.merge(global_df, similarity_df, on='FileName', how='inner')
print(merged_df.columns)

# Add a marker column to each dataframe
merged_df['source_merged_df'] = 'merged'
census_df['source_census_df'] = 'census'

# Merge to Census 
df = pd.merge(merged_df, census_df, on='FileName', how='left')
print(df.columns)

# Ensure the latitude and longitude are numeric
df['Latitude'] = pd.to_numeric(df['Latitude'], errors='coerce')
df['Longitude'] = pd.to_numeric(df['Longitude'], errors='coerce')

# log similarity 
df['Log Similarity to NU Centroid'] = -np.log(1 - df['Similarity to NU Centroid'])
# log population 
df['Log_muni_pop_10'] = np.log(df['muni_pop_10'])

# Drop rows with missing values in key columns (N=949)
df = df.dropna(subset=['WRLURI_AVIMP', 'Log Similarity to NU Centroid'])

#-------------------------------------------------------------------------------#
# Scatter plot between FBCI and Restrictiveness (with quadrants) #
#-------------------------------------------------------------------------------#
# Calculate medians to define quadrants
median_x = df['WRLURI_AVIMP'].median()
median_y = df['Log Similarity to NU Centroid'].median()

# Define colors for each quadrant
colors = {
    'high WRLURI-high FBC': 'green',  # Quadrant I
    'high WRLURI-low FBC': 'blue',    # Quadrant II
    'low WRLURI-low FBC': 'orange',   # Quadrant III
    'low WRLURI-high FBC': 'red'      # Quadrant IV
}

# Assign a color to each point based on its quadrant
df['quadrant_color'] = np.where(
    (df['WRLURI_AVIMP'] > median_x) & (df['Log Similarity to NU Centroid'] > median_y), colors['high WRLURI-high FBC'],
    np.where(
        (df['WRLURI_AVIMP'] <= median_x) & (df['Log Similarity to NU Centroid'] > median_y), colors['low WRLURI-high FBC'],
        np.where(
            (df['WRLURI_AVIMP'] > median_x) & (df['Log Similarity to NU Centroid'] <= median_y), colors['high WRLURI-low FBC'],
            colors['low WRLURI-low FBC']
        )
    )
)

# Calculate the number of observations in each quadrant
quadrant_counts = df['quadrant_color'].value_counts().to_dict()

# Calculate Pearson correlation
pearson_corr, _ = pearsonr(df['WRLURI_AVIMP'], df['Log Similarity to NU Centroid'])

# Set base size for markers
size_base = 5
sizes = df['Log_muni_pop_10'] * size_base

plt.figure(figsize=(6, 6))

# Scatter plot with assigned colors
for quadrant, color in colors.items():
    subset = df[df['quadrant_color'] == color]
    subset_sizes = sizes[subset.index]
    plt.scatter(subset['WRLURI_AVIMP'], subset['Log Similarity to NU Centroid'], 
                s=subset_sizes, alpha=0.5, color=color, label=f"{quadrant} ({quadrant_counts.get(color, 0)})")

# Add median lines to divide quadrants
plt.axvline(x=median_x, color='k', linestyle='--')
plt.axhline(y=median_y, color='k', linestyle='--')

# Specify the cities to label
city_labels = ["Charlotte, NC", "Detroit, MI", "Boston, MA", "New Haven, CT", 
               "New Orleans, LA", "Minneapolis, MN", "Seattle, WA", "San Jose, CA", 
               "Austin, TX", "Richmond, VA", "Pittsburgh, PA", "Fort Collins, CO", 
               "Fresno, CA", "Orlando, FL", "Atlanta, GA", "San Antonio, TX", "Syracuse, NY", "Oklahoma City, OK", "Columbus, GA"]

# Label the specified cities
for city in city_labels:
    city_data = df[df['City'] == city]
    if not city_data.empty:
        x = city_data['WRLURI_AVIMP'].values[0]
        y = city_data['Log Similarity to NU Centroid'].values[0]
        print(f"Labeling city: {city} at ({x}, {y})") 
        plt.text(x, y, city, fontsize=9, bbox=dict(facecolor='white', alpha=0.5))
    else:
        print(f"City not found: {city}")  

plt.title('')
plt.xlabel('Wharton Regulatory Index')
plt.ylabel('Log FBC Similarity')

# Update the legend to include counts
legend_handles = [plt.Line2D([0], [0], marker='o', color='w', markerfacecolor=c, markersize=10, label=f"{q} (N={quadrant_counts.get(c, 0)})") for q, c in colors.items()]
plt.legend(handles=legend_handles, title="Quadrants")

# Display Pearson correlation
plt.text(0.05, 0.95, f'Pearson Correlation: {pearson_corr:.2f}', transform=plt.gca().transAxes, fontsize=10, verticalalignment='top', bbox=dict(facecolor='white', alpha=0.5))

plt.grid(True)
output_png = os.path.join(FIGURES_DIR, 'fig3.png')
plt.savefig(output_png, dpi=300)
plt.show()
