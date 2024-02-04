import React from 'react';
import {Pie} from 'react-chartjs-2';

const ChartComponent = ({title, data}) => {
    return (
        <div className="pie-chart">
            <h2 className="chart-title">{title}</h2>
            {data.datasets.length > 0 ? (
                <Pie data={data}/>
            ) : (
                <p>Loading data...</p>
            )}
        </div>
    );
}

export default ChartComponent;
