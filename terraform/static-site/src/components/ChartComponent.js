import React from 'react';
import PropTypes from 'prop-types';
import {Pie} from 'react-chartjs-2';

const ChartComponent = ({title, data}) => (
    <div className="pie-chart">
        <h2 className="chart-title">{title}</h2>
        {data.datasets.length > 0 ? <Pie data={data}/> : <p>Loading data...</p>}
    </div>
);

ChartComponent.propTypes = {
    title: PropTypes.string.isRequired,
    data: PropTypes.object.isRequired
};

export default ChartComponent;
