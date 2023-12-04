import { NextResponse } from 'next/server';
import { SimpleLinearRegression } from 'ml-regression-simple-linear';

export async function POST(request) {
    try {

        const dataPoints = await request.json();
        const url = new URL(request.url);
        const searchParams = new URLSearchParams(url.search);
        const timestamp = searchParams.get('timestamp');
        const parsedTimestamp = parseFloat(timestamp);

        // Assuming dataPoints is an array of [x, y] pairs
        const xValues = dataPoints.map(point => point.x);
        const yValues = dataPoints.map(point => point.y);

        // Create a simple linear regression model
        const linearRegressionModel = new SimpleLinearRegression(xValues, yValues);
        const predictList = [];
        for(var i = 0; i< 12; i++) {
            const nextTimestamp = parsedTimestamp + i * 5 * 60 * 1000;
            predictList.push({
                timestamp: nextTimestamp,
                prediction: linearRegressionModel.predict(nextTimestamp)
            })
        }


        return NextResponse.json(
            {
                body: predictList,
                // path: request.nextUrl.pathname,
                // query: request.nextUrl.search,
                // cookies: request.cookies.getAll(),
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