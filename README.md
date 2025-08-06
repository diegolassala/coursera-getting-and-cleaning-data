# Human Activity Recognition (HAR) Data Cleaning Project

## Project Overview

This project demonstrates data cleaning and preparation of the UCI HAR Dataset, which contains smartphone sensor data from 30 subjects performing 6 activities. The final output is a tidy dataset ready for analysis.

## Repository Structure

- UCI HAR Dataset: Raw data (excluded from Git)
- run_analysis.R: Main processing script
- tidy_data.txt: Final cleaned dataset
- README.md: This documentation
- CodeBook.md: Variable descriptions

## How the Script Works

### 1. Initial Setup

```r
# Clear environment and set working directory
rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load required packages
packages <- c("dplyr", "lubridate", "sqldf", "ARTofR")
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}
```

### 2. Data Download

The script automatically:

- Downloads the dataset if not present
- Extracts the zip file
- Removes the temporary zip file

```r
if (!dir.exists(extracted_dir)) {
  if (!file.exists(zip_file)) {
    download.file(zip_url, zip_file, method = "curl")
  }
  unzip(zip_file)
  file.remove(zip_file)
}
```

### 3. Data Loading

Loads three components for both test and train sets:

- Subject IDs (who performed activities)
- Activity IDs (what they were doing)
- Sensor measurements (561 features)

```r
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
```

### 4. Data Merging

Combines test and train sets while ensuring proper alignment:

```r
# Simple merge (works because data is pre-aligned)
final_data <- cbind(
  rbind(subject_test, subject_train),
  rbind(y_test, y_train),
  rbind(X_test, X_train)
)

# Safer alternative with row IDs
merged_data <- subject_combined %>%
  mutate(row_id = row_number()) %>%
  inner_join(y_combined, by = "row_id") %>%
  inner_join(X_combined, by = "row_id")
```

### 5. Data Cleaning

Key transformations:

1. Extracts only mean/std measurements
2. Applies descriptive activity names
3. Improves variable names

```r
# Select only mean/std features
selected_features <- grep("mean\\(\\)|std\\(\\)", features$feature_name)
X_filtered <- X_combined[, selected_features]

# Clean column names
colnames(final_data) <- gsub("^t", "time_", colnames(final_data))
colnames(final_data) <- gsub("Acc", "Accelerometer", colnames(final_data))
```

### 6. Tidy Dataset Creation

Creates the final summarized dataset:

```r
tidy_data <- final_data %>%
  group_by(subject_id, activity_name) %>%
  summarise(across(everything(), mean)) %>%
  ungroup()

write.table(tidy_data, "tidy_data.txt", row.names = FALSE)
```

## How to Use

1. Run `run_analysis.R` to process the data
2. View results in `tidy_data.txt`
3. See variable descriptions in `CodeBook.md`

## Requirements

- R (v4.0+ recommended)
- Packages: dplyr, lubridate, sqldf, ARTofR

## Acknowledgments

Data from:  
[UCI Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

````

To save this directly from R:

```r
writeLines(con = "README.md", text = '# Human Activity Recognition (HAR) Data Cleaning Project

[PASTE THE ENTIRE MARKDOWN CONTENT HERE]')

message("README.md successfully created!")
```
````

This README:

1. Clearly explains each processing step
2. Shows code snippets with context
3. Documents file structure
4. Includes usage instructions
5. Is properly formatted for GitHub/GitLab
