# code to reproduce the results in Figure 4
# "An AI-based analysis of zoning reforms in US cities"

#-------------------------------------------------------------------------------#
                                 # Packages #
#-------------------------------------------------------------------------------#
import os
import geopandas as gpd
import matplotlib.pyplot as plt
import pandas as pd
import matplotlib.patches as mpatches
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
import matplotlib.patheffects as PathEffects
import seaborn as sns


#-------------------------------------------------------------------------------#
                         # Define base directories #
#-------------------------------------------------------------------------------#
BASE_DIR = ""  # Replication package base folder
DATA_DIR = os.path.join(BASE_DIR, "data")
FIGURES_DIR = os.path.join(BASE_DIR, "figures")


#-------------------------------------------------------------------------------#
                        # Load the similarity scores #
#-------------------------------------------------------------------------------#
csv_path = os.path.join(DATA_DIR, "regression_data_all.csv")
df = pd.read_csv(csv_path)


#-------------------------------------------------------------------------------#
                        # Load Census shapefiles #
#-------------------------------------------------------------------------------#
uac_shp = os.path.join(DATA_DIR, "tl_2021_us_uac10", "tl_2021_us_uac10.shp")
places_shp = os.path.join(DATA_DIR, "nhgis0092_shapefile_tl2010_us_place_2010", "US_place_2010.shp")
us_states_shp = os.path.join(DATA_DIR, "census_nation", "usa_contour.shp")

uac = gpd.read_file(uac_shp)
places = gpd.read_file(places_shp)
us_states = gpd.read_file(us_states_shp)

# Ensure CRS (Coordinate Reference System) alignment
uac = uac.to_crs(epsg=4326)
places = places.to_crs(epsg=4326)
us_states = us_states.to_crs(epsg=4326)

#-------------------------------------------------------------------------------#
                                # Merge DataFrames #
#-------------------------------------------------------------------------------#
df['place_geoid10'] = df['place_geoid10'].astype(str)
places['GEOID10'] = places['GEOID10'].astype(str)
df['place_geoid10'] = df['place_geoid10'].str.zfill(7)

# Merge places with the similarity data
merged_df = places.merge(df, left_on='GEOID10', right_on='place_geoid10')

# Add quartiles of log similarity
merged_df['quartile'] = pd.qcut(merged_df['log_similaritytonucentroid'], 4, labels=["Q1", "Q2", "Q3", "Q4"])


region_counts = merged_df['region_enc'].value_counts()
print("Number of observations per region:")
print(region_counts)

#-------------------------------------------------------------------------------#
                    # Set up color palette and labels #
#-------------------------------------------------------------------------------#

# Color Palette
cmap = plt.cm.viridis

# Define the colormap and quartile percentage labels
percentage_ranges = ['0% to 25%', '25% to 50%', '50% to 75%', '75% to 100%']
quartile_colors = [cmap(i/3) for i in range(4)]  

city_labels = {
    'Q1': ["Charlotte, NC", "Detroit, MI", "Boston, MA", "New Haven, CT"],
    'Q2': ["New Orleans, LA", "Minneapolis, MN", "Seattle, WA", "San Jose, CA"],
    'Q3': ["Austin, TX", "Richmond, VA", "Pittsburgh, PA", "Fort Collins, CO"],
    'Q4': ["Fresno, CA", "Orlando, FL", "Atlanta, GA", "San Antonio, TX"]
}

#-------------------------------------------------------------------------------#
                                # Plot the map #
#-------------------------------------------------------------------------------#

fig, ax = plt.subplots(1, 1, figsize=(12, 6))
uac.plot(ax=ax, color='grey', alpha=0.4, linewidth=0.5, edgecolor='none')
us_states.plot(ax=ax, linewidth=0.5, edgecolor='black', facecolor='none')
merged_df.plot(column='quartile', ax=ax, cmap=cmap, alpha=0.9, edgecolor='none', legend=False)

# Label the main map with 'a'
ax.text(0.01, 0.99, 'a', transform=ax.transAxes, fontsize=14, fontweight='bold', va='top', ha='left')

# Adjust legend
patches = [mpatches.Patch(color=cmap(i/3), label=f'{25*i}% to {25*(i+1)}%') for i in range(4)]
legend = ax.legend(handles=patches, title="Log FBC Similarity", loc='lower right', fontsize='x-small', title_fontsize='small', frameon=False)

#-------------------------------------------------------------------------------#
                        # Add inset for KDE plot #
#-------------------------------------------------------------------------------#

ax_inset = inset_axes(ax, width="30%", height="30%", loc='lower left', borderpad=4)
colors = ['red', 'blue', 'green', 'orange']  # Colors for each region

for (region, count), color in zip(region_counts.items(), colors):
    subset = merged_df[merged_df['region_enc'] == region]['log_similaritytonucentroid']
    label = f"{region}, N={count}"  # Format the label to include the region and its count
    sns.kdeplot(subset, ax=ax_inset, label=label, color=color, shade=True)

# Set properties for the inset
ax_inset.set_facecolor((1, 1, 1, 0.5))  # White background with 50% opacity
ax_inset.set_title('')
ax_inset.set_xlabel('Log FBC Similarity', fontsize='small')
ax_inset.set_ylabel('Density', fontsize='small')
small_legend = ax_inset.legend(title='Region', fontsize='x-small', title_fontsize='x-small', loc='upper left', frameon=True)
small_legend.get_frame().set_facecolor('#FFFFFF')  # Set the background to white
small_legend.get_frame().set_alpha(0.3)  # Set the transparency level to 30%
small_legend.get_frame().set_edgecolor('none')  # Remove the border

#-------------------------------------------------------------------------------#
                    # Add annotations for specific cities #
#-------------------------------------------------------------------------------#
quartile_labels = ['Q1', 'Q2', 'Q3', 'Q4']
for quartile_label, cities in city_labels.items():
    for city in cities:
        city_data = merged_df[merged_df['city'] == city]
        if not city_data.empty:
            for idx, row in city_data.iterrows():
                ax.annotate(row['city'], xy=(row['longitude'], row['latitude']), xycoords='data',
                            xytext=(3, 3), textcoords='offset points', ha='center', va='center',
                            fontsize=8, color='black', bbox=dict(boxstyle="round,pad=0.3", 
                            edgecolor=cmap((int(quartile_label[1])-1)/3), facecolor='white', linewidth=0.7))
                
# Label the inset with 'b'
ax_inset.text(0.01, 0.99, 'b', transform=ax_inset.transAxes, fontsize=14, fontweight='bold', va='top', ha='left')

#-------------------------------------------------------------------------------#
                                 # Customize borders #
#-------------------------------------------------------------------------------#

ax.spines['top'].set_visible(True)
ax.spines['bottom'].set_visible(True)
ax.spines['left'].set_visible(True)
ax.spines['right'].set_visible(True)
ax.spines['top'].set_color('black')
ax.spines['bottom'].set_color('black')
ax.spines['left'].set_color('black')
ax.spines['right'].set_color('black')
ax.spines['top'].set_linewidth(0.5)
ax.spines['bottom'].set_linewidth(0.5)
ax.spines['left'].set_linewidth(0.5)
ax.spines['right'].set_linewidth(0.5)

ax_inset.spines['top'].set_color('black')
ax_inset.spines['bottom'].set_color('black')
ax_inset.spines['left'].set_color('black')
ax_inset.spines['right'].set_color('black')
ax_inset.spines['top'].set_linewidth(0.5)
ax_inset.spines['bottom'].set_linewidth(0.5)
ax_inset.spines['left'].set_linewidth(0.5)
ax_inset.spines['right'].set_linewidth(0.5)

#-------------------------------------------------------------------------------#
                    # Set axis labels, limits, and grid #
#-------------------------------------------------------------------------------#
plt.suptitle('') 
ax.set_xlabel('Longitude')
ax.set_ylabel('Latitude')
ax.set_xlim([-130, -65])
ax.set_ylim([23, 50])
ax.grid(False)

output_png = os.path.join(FIGURES_DIR, 'fig4.png')
plt.savefig(output_png, dpi=300)

plt.show()

