# MultivOutliers

**MultivOutliers** is a lightweight R package for detecting multivariate outliers using Mahalanobis or Minimum Covariance Determinant(MCD) distances. It uses `Rcpp` to accelerate computations and is designed for high-dimensional numeric data.

Due to assignment requirements, this package:
- Uses `Rcpp::cppFunction()` inline instead of `.cpp` files
- Cannot be installed via `install()`, but works via `load_all()`

The multivariate_outliers() function has been created in the R script, located within the R folder.

## Installation

This package uses `Rcpp::cppFunction()` to compile C++ at runtime. Therefore, DO NOT install using `install_github()`.

Instead, please:
1. Clone or download the zip package from GitHub and extract it.
2. Open the folder in RStudio.
3. Run:

```r
# Install devtools if not already installed
install.packages("devtools")
library(devtools)
library(MASS)

# Change working directory to the package folder
setwd("path/to/MultivOutliers")

# Load the package (without installing)
devtools::load_all()
```
## Test the function
```r
data <- mtcars[, c("mpg", "hp", "wt")]

# Using Mahalanobis method
result_maha <- multivariate_outliers(as.matrix(data), "mahalanobis", 0.975)
result_maha

# Using MCD method
result_mcd <- multivariate_outliers(as.matrix(data), "mcd", 0.975)
result_mcd

# View outliers
result_maha[result_maha$Outlier == TRUE, ]
result_mcd[result_mcd$Outlier == TRUE, ]
```
Documentation is provided using Roxygen2. After loading the package via load_all(), you can view help with:

```r
?multivariate_outlier




