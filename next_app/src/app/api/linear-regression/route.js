import { NextResponse } from 'next/server';
import { SimpleLinearRegression } from 'ml-regression-simple-linear';

export async function  POST(request) {
    try {
        const { dataPoints } = await request.json();
        const { timestamp } = request.query;
        const parsedTimestamp = parseFloat(timestamp);
        console.log(dataPoints)

        // Assuming dataPoints is an array of [x, y] pairs
        const xValues = dataPoints.map(point => point.x);
        const yValues = dataPoints.map(point => point.y);

        // Create a simple linear regression model
        const linearRegressionModel = new SimpleLinearRegression(xValues, yValues);
        
        const prediction = linearRegressionModel.predict(parsedTimestamp);


        return NextResponse.json(
            {
                body: {
                    timestamp, prediction 
                },
                path: request.nextUrl.pathname,
                query: request.nextUrl.search,
                cookies: request.cookies.getAll(),
            },
            {
                status: 200,
            },
        );
    } catch (error) {
        console.error('Error processing request:', error);
        return NextResponse.json(
            { error: 'Internal Server Error' },
            {
                status: 500,
            }
        );
    }
   
}