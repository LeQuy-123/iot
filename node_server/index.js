// server.js
import http from 'http';
import linearRegressionModel from './linearRegression.js'; // Adjust the path based on your file structure
import { parse } from 'url';

const server = http.createServer((req, res) => {
    const parsedUrl = parse(req.url, true); // Parse the URL to extract query parameters

    if (req.method === 'GET' && parsedUrl.pathname === '/predict') {
        // Handle GET request for prediction
        const timestamp = parseFloat(parsedUrl.query.timestamp);
        if (!isNaN(timestamp)) {
            const prediction = linearRegressionModel.predict(timestamp);
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ timestamp, prediction }));
        } else {
            res.writeHead(400, { 'Content-Type': 'text/plain' });
            res.end('Invalid timestamp provided');
        }
    } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Not Found');
    }
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
