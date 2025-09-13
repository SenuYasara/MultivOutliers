#' Detect Multivariate Outliers
#'
#' Detects multivariate outliers in a numeric dataset using either the Mahalanobis distance or the robust Minimum Covariance Determinant(MCD) methods.
#' This function supports robust statistical detection by computing distance scores for each observation and comparing them against a chi-squared cutoff at a specified significance level.
#' It is useful for identifying outliers in high-dimensional continuous data.
#'
#' @param data A numeric data frame or matrix.
#' @param method "mahalanobis" or "mcd"
#' @param alpha Significance level (default = 0.975)
#'
#' @return A data frame combining the original input data with distances and outlier flags
#' @importFrom Rcpp cppFunction
#' @importFrom MASS cov.rob
#' @export
#' @examples
#' # Using Mahalanobis method
#' data <- mtcars[, c("mpg", "hp", "wt")]
#' result_maha <- multivariate_outliers(as.matrix(data), "mahalanobis", 0.975)
#' head(result_maha)
#'
#' # Using MCD method
#' result_mcd <- multivariate_outliers(as.matrix(data), "mcd", 0.975)
#' head(result_mcd)
#'
#' # View outliers
#' result_maha[result_maha$Outlier == TRUE, ]
#' result_mcd[result_mcd$Outlier == TRUE, ]

multivariate_outliers <- NULL

Rcpp::cppFunction('

#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]

DataFrame multivariate_outliers(NumericMatrix data,
                                    std::string method = "mahalanobis",
                                    double alpha = 0.975) {
  int n = data.nrow();
  int p = data.ncol();

  // scale data (column-wise)
  NumericMatrix data_scaled(n, p);
  NumericVector col_means(p), col_sds(p);
  for (int j = 0; j < p; ++j) {
    double sum = 0.0, sq_sum = 0.0;
    for (int i = 0; i < n; ++i) {
      sum    += data(i, j);
      sq_sum += data(i, j) * data(i, j);
    }
    col_means[j] = sum / n;
    double var = std::max(0.0, sq_sum / n - col_means[j] * col_means[j]);
    col_sds[j]   = std::sqrt(var);

    for (int i = 0; i < n; ++i) {
      data_scaled(i, j) =
        (col_sds[j] > 0.0) ? ( (data(i, j) - col_means[j]) / col_sds[j] ) : 0.0;
    }
  }

  // chi-square cutoff
  double cutoff = R::qchisq(alpha, p, /*lower_tail*/1, /*log_p*/0);

  // center (mu) and covariance (S)
  NumericVector mu(p);
  NumericMatrix S(p, p);

  if (method == "mahalanobis") {
    // mean
    for (int j = 0; j < p; ++j) {
      double s = 0.0;
      for (int i = 0; i < n; ++i) s += data_scaled(i, j);
      mu[j] = s / n;
    }
    // covariance
    for (int j = 0; j < p; ++j) {
      for (int k = 0; k < p; ++k) {
        double s = 0.0;
        for (int i = 0; i < n; ++i) {
          s += (data_scaled(i, j) - mu[j]) * (data_scaled(i, k) - mu[k]);
        }
        S(j, k) = s / (n - 1);
      }
    }
  } else if (method == "mcd") {
    Environment MASS("package:MASS");
    Function cov_rob = MASS["cov.rob"];
    List rob = cov_rob(data_scaled, Named("method") = "mcd");
    mu = as<NumericVector>(rob["center"]);
    S  = as<NumericMatrix>(rob["cov"]);
  }

  // inverse of covariance
  Function solve = Environment::namespace_env("base")["solve"];
  NumericMatrix S_inv = as<NumericMatrix>(solve(S));

  // squared Mahalanobis distances
  NumericVector distances(n);
  for (int i = 0; i < n; ++i) {
    NumericVector row = data_scaled(i, _) - mu;
    NumericVector tmp(p);
    for (int j = 0; j < p; ++j) {
      double v = 0.0;
      for (int k = 0; k < p; ++k) v += S_inv(j, k) * row[k];
      tmp[j] = v;
    }
    double d = 0.0;
    for (int j = 0; j < p; ++j) d += row[j] * tmp[j];
    distances[i] = d;
  }

  // outlier flag
  LogicalVector outlier(n);
  for (int i = 0; i < n; ++i) outlier[i] = (distances[i] > cutoff);

  return DataFrame::create(data,Named("Distance")=distances,Named("Outlier")=outlier);

}
')

