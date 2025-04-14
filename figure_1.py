# code to reproduce the results in Figure 1
# "An AI-based analysis of zoning reforms in US cities"

#-------------------------------------------------------------------------------#
                                 # Packages #
#-------------------------------------------------------------------------------#
import os
import pickle
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.metrics.pairwise import cosine_similarity
from scipy.spatial.distance import cdist
from sklearn.decomposition import PCA
import math
import seaborn as sns

#-------------------------------------------------------------------------------#
                        # Define base directories #
#-------------------------------------------------------------------------------#
BASE_DIR = ""  # "/path/to/replication_package"
DATA_DIR = os.path.join(BASE_DIR, 'data')
FIGURES_DIR = os.path.join(BASE_DIR, 'figures')

#-------------------------------------------------------------------------------#
    # Load embeddings (produced by Construct - CreateEmbeddingsBirdModel.py) #
#-------------------------------------------------------------------------------#

def load_embeddings(file_path):
    with open(file_path, 'rb') as f:
        return pickle.load(f)
    

# Load Embeddings from Bird Model
nu_embedding_file_path = os.path.join(DATA_DIR, 'avg_embeddings_bird_nu.pkl')
zoning_embedding_file_path = os.path.join(DATA_DIR, 'avg_embeddings_municode_bird.pkl')
drei_embedding_file_path = os.path.join(DATA_DIR, 'avg_embeddings_bird_drei.pkl')

nu_embeddings = load_embeddings(nu_embedding_file_path)
zoning_embeddings = load_embeddings(zoning_embedding_file_path)
drei_embeddings = load_embeddings(drei_embedding_file_path)

print("Total documents:", len(nu_embeddings))
print("Total documents:", len(zoning_embeddings))
print("Total documents:", len(drei_embeddings))


#-------------------------------------------------------------------------------#
                      # Keep sample used in regressions #
#-------------------------------------------------------------------------------#

# Function to filter embeddings based on the regression sample 
def filter_embeddings_by_csv(embeddings, csv_file_path):
    # Load the CSV
    df = pd.read_csv(csv_file_path)
    
    # Remove the .txt extension from the document names in the CSV
    df['filename'] = df['filename'].str.replace('.txt', '', regex=False)

    # Get the list of document names to keep (after removing .txt extension)
    docs_to_keep = df['filename'].tolist()
    
    # Filter the embeddings to keep only those that match the filtered document names
    filtered_embeddings = {name: embedding for name, embedding in embeddings.items() if name in docs_to_keep}
    
    return filtered_embeddings

# Path to regression sample 
csv_file_path = os.path.join(DATA_DIR, 'regression_data_all.csv')

# Filter embeddings based on regression sample
zoning_embeddings = filter_embeddings_by_csv(zoning_embeddings, csv_file_path)

# Print the total documents after filtering
print("Filtered total documents in Zoning:", len(zoning_embeddings))


#-------------------------------------------------------------------------------#
# Convert dictionaries into numpy arrays #
#-------------------------------------------------------------------------------#

# Extract just the embeddings into lists
nu_embeddings_list = list(nu_embeddings.values())
zoning_embeddings_list = list(zoning_embeddings.values())
drei_embeddings_list = list(drei_embeddings.values())

# Convert lists of embeddings into NumPy arrays
nu_embeddings = np.array(nu_embeddings_list)
zoning_embeddings = np.array(zoning_embeddings_list)
drei_embeddings = np.array(drei_embeddings_list)


#-------------------------------------------------------------------------------#
 # Compute similarity scores between zoning documents and NU centroid #
#-------------------------------------------------------------------------------#

# Calculate the centroid of NU documents
centroid_nu = np.mean(nu_embeddings, axis=0).reshape(1, -1)

# Compute the similarity of each zoning document to the NU centroid
similarity_scores_zoning_nucentroid = []
for zoning_embedding in zoning_embeddings:
    zoning_embedding = zoning_embedding.reshape(1, -1)
    score = cosine_similarity(zoning_embedding, centroid_nu)
    similarity_scores_zoning_nucentroid.append(score[0][0])

# Calculate the similarity of each NU document to the NU centroid
similarity_scores_nu_nucentroid = []
for nu_embedding in nu_embeddings:
    nu_embedding = nu_embedding.reshape(1, -1)
    score = cosine_similarity(nu_embedding, centroid_nu)
    similarity_scores_nu_nucentroid.append(score[0][0])

# Calculate the similarity of each Drei document to the NU centroid
similarity_scores_drei_nucentroid = []
for drei_embedding in drei_embeddings:
    drei_embedding = drei_embedding.reshape(1, -1)
    score = cosine_similarity(drei_embedding, centroid_nu)
    similarity_scores_drei_nucentroid.append(score[0][0])


#-------------------------------------------------------------------------------#
                            #  Create Variables #
#-------------------------------------------------------------------------------#

#create log variable 
similarity_scores_zoning_nucentroid = [-math.log(1 - score) if 0 <= score <= 1 else score for score in similarity_scores_zoning_nucentroid]
similarity_scores_nu_nucentroid = [-math.log(1 - score) if 0 <= score <= 1 else score for score in similarity_scores_nu_nucentroid]

#-------------------------------------------------------------------------------#
                     # Combine all the embeddings #
#-------------------------------------------------------------------------------#

# Combine the embeddings
combined_embeddings = np.vstack((nu_embeddings, zoning_embeddings, drei_embeddings))

# Perform PCA
pca = PCA(n_components=2)
pca_results = pca.fit_transform(combined_embeddings)

# Split the transformed data into NU and zoning for plotting
nu_pca = pca_results[:len(nu_embeddings), :]
zoning_pca = pca_results[len(nu_embeddings):len(nu_embeddings) + len(zoning_embeddings), :]
drei_pca = pca_results[len(nu_embeddings) + len(zoning_embeddings):, :]


#-------------------------------------------------------------------------------#
                              # Composite Plot #
#-------------------------------------------------------------------------------#

# Plot setup
fig, axes = plt.subplots(1, 2, figsize=(10, 5))

# First subplot: PCA scatter plot
ax1 = axes[0]
ax1.scatter(zoning_pca[:, 0], zoning_pca[:, 1], color='blue', label='Zoning Documents', alpha=0.4, s=20)
ax1.scatter(nu_pca[:, 0], nu_pca[:, 1], color='orange', alpha=0.6, s=20)  # NU documents
ax1.scatter(drei_pca[:, 0], drei_pca[:, 1], color='orange', alpha=0.6, s=20)  # Driehaus treated as NU
ax1.set_title('PCA of document embeddings')
ax1.set_xlabel('PCA Component 1')
ax1.set_ylabel('PCA Component 2')
ax1.legend(['Zoning Documents', 'FBC Repository Documents'], edgecolor='none', loc='lower left')  # Custom legend
ax1.text(0.01, 0.99, 'a', transform=ax1.transAxes, fontsize=14, fontweight='bold', va='top', ha='left')
for spine in ax1.spines.values():
    spine.set_linewidth(1)
    spine.set_color('black')
ax1.grid(False)

# Second subplot: KDE plot for zoning and NU documents
ax2 = axes[1]  # Primary axis for zoning documents
sns.kdeplot(similarity_scores_zoning_nucentroid, ax=ax2, color='blue', label='Zoning Documents', shade=True)
ax2.set_xlabel('Log FBC Similarity')
ax2.set_ylabel('Density (Zoning)', color='blue')
ax2.tick_params(axis='y', labelcolor='blue')

# Create a secondary y-axis for NU documents on the same subplot
ax2_twin = ax2.twinx()
sns.kdeplot(similarity_scores_nu_nucentroid, ax=ax2_twin, color='orange', label='FBC Repository Documents', shade=True)
ax2_twin.set_ylabel('Density (FBC Repository)', color='orange')
ax2_twin.tick_params(axis='y', labelcolor='orange')
ax2.set_title('Log FBC similarity distributions')
ax2.text(0.01, 0.99, 'b', transform=ax2.transAxes, fontsize=14, fontweight='bold', va='top', ha='left')
for spine in ax2.spines.values():
    spine.set_linewidth(1)
    spine.set_color('black')
for spine in ax2_twin.spines.values():
    spine.set_linewidth(1)
    spine.set_color('black')
ax2.grid(False)
ax2_twin.grid(False)

# Legend configuration for KDE plot
handles1, labels1 = ax2.get_legend_handles_labels()
handles2, labels2 = ax2_twin.get_legend_handles_labels()
ax2.legend(handles1 + handles2, labels1 + labels2, loc='lower left', edgecolor='none')

plt.tight_layout()
output_figure_path = os.path.join(FIGURES_DIR, 'fig1.png')
plt.savefig(output_figure_path, dpi=300, bbox_inches='tight')
plt.show()


