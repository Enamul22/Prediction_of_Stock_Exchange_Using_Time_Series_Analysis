# Installing required packages
library(quantmod)
library(forecast)
library(tseries)
library(tinytex)

# Importing APPLE stock data
getSymbols("AAPL")
stock_data <- Cl(AAPL) # Closing prices
stock_data

# Column Names
colnames(stock_data)

# length of the data
length(stock_data)

# Checking for missing values
missing_indices <- which(is.na(stock_data))
if(length(missing_indices) > 0) {
  print(paste("Number of missing values:", length(missing_indices)))
  # Here, we will use linear interpolation to fill in missing values
  stock_data <- na.approx(stock_data)
} else {
  print("No missing values detected.")
}

# Checking for NAs values
sum(is.na(diff(log(stock_data))))

# Removing NAs values
diff_log_data <- diff(log(stock_data))
stock_data_clean <- na.omit(diff_log_data)
stock_data_clean

# Coerce the time series data to a numeric vector
stock_data_vector <- coredata(stock_data_clean$AAPL.Close)

# Generate a boxplot and determine outliers
boxplot(stock_data_vector, main="Boxplot of Stock Prices")
outliers <- boxplot.stats(stock_data_vector)$out

if(length(outliers) > 0) {
  print(paste("Number of outliers detected:", length(outliers)))
  
  # Get the upper and lower bounds
  upper_bound <- boxplot.stats(stock_data_vector)$stats[5]
  lower_bound <- boxplot.stats(stock_data_vector)$stats[1]
  
  # Cap the outliers
  stock_data_vector[stock_data_vector > upper_bound] <- upper_bound
  stock_data_vector[stock_data_vector < lower_bound] <- lower_bound
  # Replace the original column with the capped data
  stock_data_clean$AAPL.Close <- stock_data_vector
  
} else {
  print("No outliers detected.")
}

# Checking for stationarity
adf.test(stock_data_clean, alternative="stationary", k=0)

# Saving the data
saveRDS(diff_log_data_clean, file = "stock_data_clean.rds")


install.packages("tinytex")
library(tinytex)
tinytex::install_tinytex()
tinytex:::is_tinytex()
