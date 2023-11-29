// linearRegression.js
import { SimpleLinearRegression } from 'ml-regression-simple-linear';

// Sample data for timestamp and corresponding temperatures
const data = [
    [1638356400, 20],
    [1638357000, 25],
    [1638357600, 30],
    // Add more data points as needed
];

// Extract timestamps (X) and temperatures (Y)
const timestamps = data.map(point => point[0]);
const temperatures = data.map(point => point[1]);

// Create and train the linear regression model
const linearRegressionModel = new SimpleLinearRegression(timestamps, temperatures);

// Export the model
export default linearRegressionModel;
