# CodeBook: Tidy Dataset for UCI HAR Analysis

## Dataset Overview

- **Source**: [UCI HAR Dataset](https://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
- **Dimensions**: 180 rows × 68 columns (30 subjects × 6 activities)
- **Variables**: Mean values of 66 mean/std features grouped by subject/activity

## Variables

### Identifiers

| Variable        | Type    | Description                   |
| --------------- | ------- | ----------------------------- |
| `subject_id`    | integer | Unique participant ID (1-30)  |
| `activity_name` | factor  | Activity name (e.g., WALKING) |

### Features

Naming convention: `[domain]_[sensor]_[statistic]_[axis]`

- **Domains**: `time_` (time-domain), `freq_` (frequency-domain)
- **Sensors**: `Accelerometer`, `Gyroscope`
- **Statistics**: `mean`, `std`
- **Axes**: `X`, `Y`, `Z` (or omitted for magnitude)

Example variables:

- `time_BodyAccelerometer_mean_X`
- `freq_BodyGyroscope_std_Z`

## Transformations

1. Merged test/train data
2. Extracted only mean/std measurements
3. Applied descriptive activity names
4. Averaged by subject/activity

## Structure

```r
str(tidy_data)
# tibble [180 × 68]
# $ subject_id                        : int  1 1 1...
# $ activity                          : Factor w/ 6 levels "WALKING",...
# $ time_BodyAccelerometer_mean_X     : num  0.277...
```
