# code to reproduce the results in Figure 2
# "An AI-based analysis of zoning reforms in US cities"

#-------------------------------------------------------------------------------#
                                 # Packages #
#-------------------------------------------------------------------------------#
import os
import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from wordcloud import WordCloud
import matplotlib.pyplot as plt
import re

#-------------------------------------------------------------------------------#
                        # Define base directories #
#-------------------------------------------------------------------------------#
BASE_DIR = ""  # "/path/to/replication_package"
DATA_DIR = os.path.join(BASE_DIR, 'data')
FIGURES_DIR = os.path.join(BASE_DIR, 'figures')


#-------------------------------------------------------------------------------#
                        # Load and combine the data #
#-------------------------------------------------------------------------------#

# Path to the regression sample
csv_path = os.path.join(DATA_DIR, "regression_data_all.csv")

# Read in the chatgpt CSVs
df_setbacks = pd.read_csv(os.path.join(DATA_DIR, 'chatgpt_setbacks', 'chatgpt_guidelines_zoning.csv'))
df_far = pd.read_csv(os.path.join(DATA_DIR, 'chatgpt_far', 'chatgpt_guidelines_zoning.csv'))

# Combine the data
df = pd.concat([df_setbacks, df_far], ignore_index=True)

#-------------------------------------------------------------------------------#
        # Function to extract and filter themes from consolidated text #
#-------------------------------------------------------------------------------#
def extract_and_filter_themes(text):
    # Extract themes enclosed in **...**
    themes = re.findall(r'\*\*(.*?)\*\*', text)
    # Filter out common words that don’t differentiate well between groups
    unwanted_words = {'setback', 'setbacks', 'building', 'districts', 'regulations', 'development', 'codes', 'standard', 'requirements', 'and', 'lot', 'zoning'} 
    filtered_themes = [theme for theme in themes if not any(word in theme.lower().split() for word in unwanted_words)]
    return ' '.join(filtered_themes)

# Apply extraction and filtering to the 'Consolidated Themes' column
df['Extracted Themes'] = df['Consolidated Themes'].apply(extract_and_filter_themes)

#-------------------------------------------------------------------------------#
         # Prepare data for TF-IDF for top and bottom themes #
#-------------------------------------------------------------------------------#

top_themes = ' '.join(df[df['City Category'] == 'Top']['Extracted Themes'].tolist())
bottom_themes = ' '.join(df[df['City Category'] == 'Bottom']['Extracted Themes'].tolist())

# Create TF-IDF model and fit data for top and bottom themes
vectorizer = TfidfVectorizer(min_df=1, max_df=0.5)
tfidf_matrix = vectorizer.fit_transform([top_themes, bottom_themes])
feature_names = vectorizer.get_feature_names_out()

# Create dictionaries mapping words to their TF-IDF scores
top_scores = dict(zip(feature_names, tfidf_matrix.toarray()[0]))
bottom_scores = dict(zip(feature_names, tfidf_matrix.toarray()[1]))

# Calculate difference in scores and filter words
difference_threshold = 0.05  
top_filtered = {word: score for word, score in top_scores.items() if abs(score - bottom_scores.get(word, 0)) > difference_threshold}
bottom_filtered = {word: score for word, score in bottom_scores.items() if abs(score - top_scores.get(word, 0)) > difference_threshold}

#-------------------------------------------------------------------------------#
      # Load and combine the new data for the third word cloud (NU data) #
#-------------------------------------------------------------------------------#
# Load and combine the new data for the third word cloud
df_setbacks_nu = pd.read_csv(os.path.join(DATA_DIR, 'chatgpt_setbacks', 'chatgpt_guidelines_nu.csv'))
df_far_nu = pd.read_csv(os.path.join(DATA_DIR, 'chatgpt_far', 'chatgpt_guidelines_nu.csv'))
df_nu = pd.concat([df_setbacks_nu, df_far_nu], ignore_index=True)

# Apply function to extract and filter themes for the new data
df_nu['Extracted Themes'] = df_nu['Consolidated Themes'].apply(extract_and_filter_themes)
nu_themes = ' '.join(df_nu['Extracted Themes'].tolist())

# Transform the new combined data using the already fitted vectorizer
tfidf_matrix_nu = vectorizer.transform([nu_themes])
feature_names_nu = vectorizer.get_feature_names_out()
nu_scores = dict(zip(feature_names_nu, tfidf_matrix_nu.toarray()[0]))

#-------------------------------------------------------------------------------#
                  # Create a circular mask for word clouds #
#-------------------------------------------------------------------------------#

x, y = np.ogrid[:800, :800]  # size of the mask (800x800)
mask = (x - 400) ** 2 + (y - 400) ** 2 > 390 ** 2  
mask = 255 * mask.astype(int)  # convert to integer for the mask

#-------------------------------------------------------------------------------#
                     # Define a custom color function #
#-------------------------------------------------------------------------------#
d
def custom_color_func(word, font_size, position, orientation, random_state=None, **kwargs):
    colors = ["green", "blue", "orange", "red"]
    return colors[random_state.randint(0, len(colors))]


#-------------------------------------------------------------------------------#
                         # Generate and display word clouds #
#-------------------------------------------------------------------------------#
def generate_word_clouds(top_dict, bottom_dict, nu_dict, seed=15):
    random_state = np.random.RandomState(seed)
    plt.figure(figsize=(24, 8))
    ax1 = plt.subplot(1, 3, 1)
    wordcloud_top = WordCloud(width=800, height=800, background_color='white', mask=mask, random_state=random_state, color_func=custom_color_func).generate_from_frequencies(top_dict)
    ax1.imshow(wordcloud_top, interpolation="bilinear")
    ax1.axis('off')
    ax1.set_title('Top FBC City Themes', fontsize=20)
    ax1.text(0.01, 1.05, 'a', transform=ax1.transAxes, fontsize=20, verticalalignment='top', fontweight='bold')

    ax2 = plt.subplot(1, 3, 2)
    wordcloud_bottom = WordCloud(width=800, height=800, background_color='white', mask=mask, random_state=random_state, color_func=custom_color_func).generate_from_frequencies(bottom_dict)
    ax2.imshow(wordcloud_bottom, interpolation="bilinear")
    ax2.axis('off')
    ax2.set_title('Bottom FBC City Themes', fontsize=20)
    ax2.text(0.01, 1.05, 'b', transform=ax2.transAxes, fontsize=20, verticalalignment='top', fontweight='bold')

    ax3 = plt.subplot(1, 3, 3)
    wordcloud_nu = WordCloud(width=800, height=800, background_color='white', mask=mask, random_state=random_state, color_func=custom_color_func).generate_from_frequencies(nu_dict)
    ax3.imshow(wordcloud_nu, interpolation="bilinear")
    ax3.axis('off')
    ax3.set_title('FBC Repository Themes', fontsize=20)
    ax3.text(0.01, 1.05, 'c', transform=ax3.transAxes, fontsize=20, verticalalignment='top', fontweight='bold')

    # Save the figure 
    output_png_path = os.path.join(FIGURES_DIR, 'fig2.png')
    plt.savefig(output_png_path, dpi=300, bbox_inches='tight')
    plt.show()

# Call the function
generate_word_clouds(top_filtered, bottom_filtered, nu_scores)

