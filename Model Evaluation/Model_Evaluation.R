# Installing required packages
library(quantmod)
library(forecast)
library(tseries)
library(ggplot2)
library(tinytex)

# Iporting data
data <- readRDS("stock_data_clean.rds")

# Finding negative and nan values
sum(data <= 0)

# Shift the entire series to make all values positive
shift_value <- abs(min(data)) + 1
stock_shifted = data + shift_value

# Apply the log-plus-one transformation to the shifted data
stock_log = log1p(stock_shifted)

# Log transform to stabilize variance
stock_log_data <- log(stock_log)
stock_diff <- diff(stock_log_data)

# Fit the ARIMA model. Here, I am using auto.arima to select the best parameters.
fit <- auto.arima(stock_log, seasonal=FALSE)
summary(fit)

# Forecast next 30 days
forecasted_values <- forecast(fit, h=30)
plot(forecasted_values)

# Split data into training and test sets
train_end <- length(stock_log) - 30
train <- stock_log[1:train_end]
test <- stock_log[(train_end+1):length(stock_log)]

fit_train <- auto.arima(train, seasonal=FALSE)
forecasted_test <- forecast(fit_train, h=30)
forecasted_test

# Assuming train data is already loaded and the ARIMA model is already fit

fit_train <- auto.arima(train, seasonal=FALSE)
forecasted_test <- forecast(fit_train, h=30)

# Plot using ggplot2
autoplot(forecasted_test) +
  labs(title = "ARIMA Forecast", x = "Time", y = "Value") +
  theme_minimal()

# Convert both series to simple numeric vectors
forecast_values <- as.numeric(forecasted_test$mean)
test_values <- as.numeric(test)

# Calculate RMSE
rmse <- sqrt(mean((forecast_values - test_values)^2))
print(paste("RMSE:", rmse))

