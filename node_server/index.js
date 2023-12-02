import express from 'express';
import pkg from 'body-parser';
import { SimpleLinearRegression } from 'ml-regression-simple-linear';

const app = express();
const PORT = 3000;
const { json, urlencoded } = pkg;
app.use(json());
app.use(urlencoded({ extended: true }));

app.post('/predict', (req, res) => {
    const timestamp = parseFloat(req.query.timestamp);

    try {
        const requestData = req.body;

        if (!isNaN(timestamp)) {
            const timestamps = requestData.map(point => point.x);
            const temperatures = requestData.map(point => point.y);
            const linearRegressionModel = new SimpleLinearRegression(timestamps, temperatures);

            const prediction = linearRegressionModel.predict(timestamp);

            res.status(200).json({ timestamp, prediction });
        } else {
            res.status(400).send('Invalid timestamp provided');
        }
    } catch (error) {
        res.status(400).send('Invalid JSON payload');
    }
});

app.use((req, res) => {
    res.status(404).send('Not Found');
});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
