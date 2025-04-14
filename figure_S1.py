# code to reproduce the results in Figure S1
# "An AI-based analysis of zoning reforms in US cities"

#-------------------------------------------------------------------------------#
                                 # Packages #
#-------------------------------------------------------------------------------#
import os
import pickle
import pandas as pd
import matplotlib.pyplot as plt

#-------------------------------------------------------------------------------#
                        # Define base directories #
#-------------------------------------------------------------------------------#
# Define base directories for the replication package
BASE_DIR = ""  # "/path/to/replication_package"
DATA_DIR = os.path.join(BASE_DIR, "data")
FIGURES_DIR = os.path.join(BASE_DIR, "figures")

# Define a directory for the shared code text database (Note this requires access to the raw code data)
SHARED_DIR = "/Users/arianna/Dropbox (Personal)/Zoning/_shared"
SHARED_CODES_DIR = os.path.join(SHARED_DIR, "Zoning code text database", "muni_code_analysis", "_data", "_raw", "codes", "all_codes_municode_txt")


#------------------------------------------------------------#
            # Load the chunked documents #
#------------------------------------------------------------#
with open(os.path.join(DATA_DIR, 'zoning_docs_bird_chunked.pkl'), 'rb') as file:
    zoning_docs_chunked = pickle.load(file)

#------------------------------------------------------------#
        # Get the list of original document names #
#------------------------------------------------------------#
all_txt_files = [f for f in os.listdir(SHARED_CODES_DIR) if f.endswith('.txt')]

#------------------------------------------------------------#
# Load the regression data from the replication data #
#------------------------------------------------------------#
regression_data = pd.read_csv('/Users/arianna/Dropbox (Personal)/Zoning/_replication/data/regression_data_all.csv')

# Extract the filenames from regression_data
regression_filenames = set(regression_data['filename'].unique())

#------------------------------------------------------------#
# Match and filter the chunked documents based on regression sample  #
#------------------------------------------------------------#
filtered_chunks = []
filtered_doc_names = []

for doc_name, chunks in zip(all_txt_files, zoning_docs_chunked):
    if doc_name in regression_filenames:
        filtered_chunks.append(chunks)
        filtered_doc_names.append(doc_name)

# Check the number of documents retained
print(f"Total documents in the regression sample: {len(filtered_chunks)}")


#------------------------------------------------------------#
        # Initialize lists to store statistics #
#------------------------------------------------------------#
num_chunks_per_doc = []
total_tokens_per_doc = []
avg_tokens_per_chunk = []

# Calculate statistics from filtered_chunks
for doc_chunks in filtered_chunks:
    # Number of chunks for this document
    num_chunks = len(doc_chunks)
    num_chunks_per_doc.append(num_chunks)
    
    # Total tokens for this document
    total_tokens = sum(len(chunk.split()) for chunk in doc_chunks)
    total_tokens_per_doc.append(total_tokens)
    
    # Average tokens per chunk
    avg_tokens = total_tokens / num_chunks if num_chunks > 0 else 0
    avg_tokens_per_chunk.append(avg_tokens)

#------------------------------------------------------------#
    # Create a dataFrame to store the document statistics #
#------------------------------------------------------------#
summary_stats = pd.DataFrame({
    'Number of Chunks per Document': num_chunks_per_doc,
    'Total Tokens per Document': total_tokens_per_doc,
    'Average Tokens per Chunk': avg_tokens_per_chunk
})

# Calculate stats for each column
summary_table = pd.DataFrame({
    'Statistic': ['Count', 'Mean', 'Median', 'Std Dev', 'Max', 'Min'],
    'Number of Chunks per Document': [
        summary_stats['Number of Chunks per Document'].count(),
        summary_stats['Number of Chunks per Document'].mean(),
        summary_stats['Number of Chunks per Document'].median(),
        summary_stats['Number of Chunks per Document'].std(),
        summary_stats['Number of Chunks per Document'].max(),
        summary_stats['Number of Chunks per Document'].min()
    ],
    'Total Tokens per Document': [
        summary_stats['Total Tokens per Document'].count(),
        summary_stats['Total Tokens per Document'].mean(),
        summary_stats['Total Tokens per Document'].median(),
        summary_stats['Total Tokens per Document'].std(),
        summary_stats['Total Tokens per Document'].max(),
        summary_stats['Total Tokens per Document'].min()
    ],
    'Average Tokens per Chunk': [
        summary_stats['Average Tokens per Chunk'].count(),
        summary_stats['Average Tokens per Chunk'].mean(),
        summary_stats['Average Tokens per Chunk'].median(),
        summary_stats['Average Tokens per Chunk'].std(),
        summary_stats['Average Tokens per Chunk'].max(),
        summary_stats['Average Tokens per Chunk'].min()
    ]
})

# Print the final summary table
print(summary_table)


#------------------------------------------------------------#
    # Plotting histograms for the document statistics #
#------------------------------------------------------------#
num_chunks_per_doc = summary_stats['Number of Chunks per Document']
total_tokens_per_doc = summary_stats['Total Tokens per Document']

# Set up a figure with three square panels side by side
fig, axs = plt.subplots(1, 3, figsize=(12, 4), constrained_layout=True)

# Define common properties for the histograms
hist_color = 'blue'
hist_alpha = 0.7
bins = 30

# Plot for Number of Chunks per Document
axs[0].hist(num_chunks_per_doc, bins=bins, edgecolor='black', color=hist_color, alpha=hist_alpha)
axs[0].set_title('Number of Chunks per Document', fontsize=12)
axs[0].set_xlabel('Number of Chunks', fontsize=10)
axs[0].set_ylabel('Frequency', fontsize=10)
axs[0].grid(axis='y', linestyle='--', linewidth=0.5, alpha=0.7)

# Plot for Total Tokens per Document
axs[1].hist(total_tokens_per_doc, bins=bins, edgecolor='black', color=hist_color, alpha=hist_alpha)
axs[1].set_title('Total Tokens per Document', fontsize=12)
axs[1].set_xlabel('Total Tokens', fontsize=10)
axs[1].set_ylabel('Frequency', fontsize=10)
axs[1].grid(axis='y', linestyle='--', linewidth=0.5, alpha=0.7)

# Plot for Average Tokens per Chunk
axs[2].hist(avg_tokens_per_chunk, bins=bins, edgecolor='black', color=hist_color, alpha=hist_alpha)
axs[2].set_title('Average Tokens per Chunk', fontsize=12)
axs[2].set_xlabel('Average Tokens', fontsize=10)
axs[2].set_ylabel('Frequency', fontsize=10)
axs[2].grid(axis='y', linestyle='--', linewidth=0.5, alpha=0.7)

# Add a shared title for all plots
fig.suptitle('', fontsize=14)

# Save the figure with a high resolution
plt.savefig(os.path.join(FIGURES_DIR, 'figS1.png'), dpi=300)

# Show the plots
plt.show()