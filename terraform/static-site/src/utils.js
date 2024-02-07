const feedbackColors = {
    MIXED: '#FFCE56',
    NEGATIVE: '#FF6384',
    NEUTRAL: '#36A2EB',
    POSITIVE: '#4BC0C0',
    UNKNOWN: '#C9CBCF'
};

export const processData = (data, period) => {
    const filteredData = data.filter(item => item.PERIOD === period);

    const backgroundColors = filteredData.map(item => feedbackColors[item.FEEDBACK || 'UNKNOWN']);

    return {
        labels: filteredData.map(item => item.FEEDBACK || 'Unknown'),
        datasets: [{
            data: filteredData.map(item => item.RECCOUNT),
            backgroundColor: backgroundColors,
            hoverBackgroundColor: backgroundColors
        }]
    };
};
