### Justification for the selected function

The function **multivariate_outliers()** was developed as part of my ongoing R package project, which aims to detect outliers in multivariate data using several distance-based methods. For Assignment 2, I have focused on implementing the Mahalanobis distance and the Minimum Covariance Determinant (MCD) methods.

The Mahalanobis distance method calculates the squared distance between each data point and the mean vector of the scaled data, weighted by the inverse covariance matrix. Furthermore, the Minimum Covariance Determinant (MCD) method improves upon the Mahalanobis distance by robustly estimating the mean and covariance matrix that is resistant to outliers. Distances calculated using both methods are compared to the same chi-square based cutoff, with points beyond this threshold flagged as outliers.

### Object-Oriented Programming (OOP)

Object-Oriented Programming (OOP) brings structure, encapsulation, and polymorphism to statistical computation. The function works particularly well with object-oriented programming (OOP) in R using the S3 system. It is also be accelerated in C++ using Rcpp to make distance calculations more efficient. The Mahalanobis distance involves matrix algebra, and statistical thresholds derived from the chi-squared distribution are implemented in C++ using Rcpp. 

This function returns a structured object in the form of a data frame with calculated distances and logical outlier flags after detecting multivariate outliers. The data frame contains a list of observations as objects. So, the function produces multiple outputs, such as original data with given variables, distance scores, and logical outlier flags (TRUE if it is an outlier and FALSE if not). It explains encapsulation, which is a key OOP principle where data and behavior are combined. It hides the complexity of computation and helps to maintain a clean, interpretable interface for users. 

Furthermore, polymorphism enables us to define method-specific behaviors for generic functions such as print(). This method, when dispatched, displays the outlier detection results as a data frame, where each row corresponds to an observation with original variables along with the distance and logical outlier flag. This use of polymorphism improves clarity and usability for end-users.

### Alternatives to OOP

A non-OOP approach might return only a list or raw values, and then users may need to extract and interpret the results manually. Additionally, it will be less readable and difficult to extend. Therefore, OOP maintains the package's cleanliness, testability, and extensibility, which is crucial for package development.

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




