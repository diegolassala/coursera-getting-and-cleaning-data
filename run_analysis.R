##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##                                                                            ~~
##           PEER REVIEWED PROJECT - COURSERA: DATA CLEANING WITH R         ----
##                                                                            ~~
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


rm(list = ls())

##~~~~~~~~~~~~~~~~~~~~~~~~~~
##  ~ Project settings  ----
##~~~~~~~~~~~~~~~~~~~~~~~~~~

# Set working directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
#setwd("..")

Sys.setlocale("LC_TIME", "en_US.UTF-8")

## Load packages
# List of required packages
packages <- c("dplyr", "lubridate", "sqldf", "ARTofR")

# Install & load all packages
for (pkg in packages) {
        if (!require(pkg, character.only = TRUE)) {
                install.packages(pkg)
                library(pkg, character.only = TRUE)
        }
}

#Script Aesthetics
xxx_title0("Peer Reviewed Project - Coursera: Data Cleaning with R")
xxx_title3 ("Project settings")
xxx_title3 ("Data Download")
xxx_title3 ("Data Load")
xxx_title3 ("Data Cleaning")
xxx_title3 ("Data Analysis")

# if (!dir.exists("data")) {dir.create("data")}

##~~~~~~~~~~~~~~~~~~~~~~~
##  ~ Data Download  ----
##~~~~~~~~~~~~~~~~~~~~~~~

zip_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zip_file <- "UCI_HAR_Dataset.zip"
extracted_dir <- "UCI HAR Dataset"

# Only download and extract if the dataset doesn't exist
if (!dir.exists(extracted_dir)) {
        # Download only if zip file doesn't exist
        if (!file.exists(zip_file)) {
                download.file(zip_url, zip_file, method = "curl")
        }
        
        # Extract the dataset
        unzip(zip_file)
        
        # Remove the zip file (only if we downloaded it)
        if (file.exists(zip_file)) {
                file.remove(zip_file)
                message("Temporary zip file removed")
        }
} else {
        message("Dataset already exists - using cached version")
}

##~~~~~~~~~~~~~~~~~~~
##  ~ Data Load  ----
##~~~~~~~~~~~~~~~~~~~

# Read activity labels and features
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", 
                              col.names = c("activity_id", "activity_name"))
features <- read.table("UCI HAR Dataset/features.txt", 
                       col.names = c("feature_id", "feature_name"))

# Read test data
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject_id")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "activity_id")

# Read train data
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject_id")
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "activity_id")

##~~~~~~~~~~~~~~~~~~~~~~~
##  ~ Data Cleaning  ----
##~~~~~~~~~~~~~~~~~~~~~~~

# Combine test and train data
X_combined <- rbind(X_test, X_train)
y_combined <- rbind(y_test, y_train)
subject_combined <- rbind(subject_test, subject_train)

# Assign column names from features
colnames(X_combined) <- features$feature_name

# Select only mean() and std() columns
selected_features <- grep("mean\\(\\)|std\\(\\)", 
                          features$feature_name, 
                          value = TRUE)
X_filtered <- X_combined[, selected_features]
x_filtered

# Replace activity IDs with names
y_combined$activity_name <- factor(y_combined$activity_id, 
                                   levels = activity_labels$activity_id,
                                   labels = activity_labels$activity_name)

# Combine subject, activity, and measurements
final_data <- cbind(subject_combined, y_combined, X_filtered) %>%
        select(-activity_id)  # Drop redundant activity_id column

###############################################################
# If you want to be 100% safe:
merged_data <- subject_combined %>%
        mutate(row_id = row_number()) %>%
        inner_join(y_combined %>% mutate(row_id = row_number()),
                   by = "row_id") %>%
        inner_join(X_combined %>% mutate(row_id = row_number()),
                   by = "row_id") %>%
        select(-row_id)
###############################################################

# Clean up column names
colnames(final_data) <- gsub("^t", "time_", colnames(final_data))
colnames(final_data) <- gsub("^f", "freq_", colnames(final_data))
colnames(final_data) <- gsub("Acc", "Accelerometer", colnames(final_data))
colnames(final_data) <- gsub("Gyro", "Gyroscope", colnames(final_data))
colnames(final_data) <- gsub("-mean\\(\\)", "_mean", colnames(final_data))
colnames(final_data) <- gsub("-std\\(\\)", "_std", colnames(final_data))
colnames(final_data) <- gsub("[-()]", "_", colnames(final_data))

##~~~~~~~~~~~~~~~~~~~~~~~
##  ~ Data Analysis  ----
##~~~~~~~~~~~~~~~~~~~~~~~

tidy_data <- final_data %>%
        group_by(subject_id, activity_name) %>%
        summarise(across(everything(), mean, na.rm = TRUE)) %>%
        ungroup()

# Save the tidy dataset
write.table(tidy_data, "tidy_data.txt", row.names = FALSE)




