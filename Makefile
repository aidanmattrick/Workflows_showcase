all : report/summary_report.md

# Retrieve datasets from repo
data/raw/dc-wikia-data.csv data/raw/marvel-wikia-data.csv : \
    src/get_datasets.py
	    python src/get_datasets.py \
	    -i https://github.com/rudeboybert/fivethirtyeight/tree/master/data-raw/comic-characters \
	    -o data/raw -g -v

# Preprocess and clean the data
data/processed/clean_characters.csv \
data/processed/clean_characters_train.csv \
data/processed/clean_characters_test.csv \
data/processed/clean_characters_deploy.csv : \
    data/raw/dc-wikia-data.csv \
    data/raw/marvel-wikia-data.csv \
    src/preprocess_data.py
		python src/preprocess_data.py \
	    -i data/raw \
	    -o data/processed/clean_characters.csv -v

# Generate EDA tables and figures
results/figures/alignment_over_time.png \
results/figures/alignment_vs_features.png \
results/figures/appearances_by_alignment.png \
results/tables/dataset_overview.pkl \
results/tables/feature_overview.pkl : \
    data/processed/clean_characters.csv \
    src/generate_eda.py
	    python src/generate_eda.py \
	    -i data/processed/clean_characters.csv \
	    -o results -v

# Modelling
results/figures/optimized_model.png \
results/figures/model_comparison.png \
results/tables/optimized_model.pkl \
results/tables/model_comparison.pkl \
results/models/optimized_model.pkl : \
    data/processed/clean_characters_train.csv \
	data/processed/clean_characters_test.csv \
	src/analysis.py
	    python src/analysis.py \
		    -i data/processed/clean_characters_train.csv \
			-o results -v


# Generate summary markdown report
report/summary_report.md : \
    results/figures/alignment_over_time.png \
    results/figures/alignment_vs_features.png \
	results/figures/appearances_by_alignment.png \
	results/tables/dataset_overview.pkl \
	results/tables/feature_overview.pkl \
	results/figures/optimized_model.png \
    results/figures/model_comparison.png \
    results/tables/optimized_model.pkl \
    results/tables/model_comparison.pkl \
	results/models/optimized_model.pkl
	    jupyter nbconvert --to html report/summary_report.ipynb --no-input

clean :
	rm -f data/raw/*
	rm -f data/processed/*
	rm -f results/figures/*
	rm -f results/tables/*
	rm -f results/models/*
	rm -f report/eda_profile_report.html
	rm -f report/summary_report.html
	rm -rf report/summary_report_files/