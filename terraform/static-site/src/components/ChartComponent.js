import React from 'react';
import { Pie } from 'react-chartjs-2';

const ChartComponent = ({ title, data }) => {
    const options = {
        plugins: {
            tooltip: {
                callbacks: {
                    label: function(context) {
                        let label = context.label || '';
                        if (label) {
                            label += ': ';
                        }
                        if (context.parsed !== null) {
                            const total = context.dataset.data.reduce((acc, val) => acc + val, 0);
                            const percentage = ((context.parsed / total) * 100).toFixed(2) + '%';
                            label += percentage;
                        }
                        return label;
                    }
                }
            }
        }
    };

    return (
        <div className="pie-chart">
            <h2 className="chart-title">{title}</h2>
            {data.datasets.length > 0 ? (
                <Pie data={data} options={options} />
            ) : (
                <p>Loading data...</p>
            )}
        </div>
    );
}

export default ChartComponent;
