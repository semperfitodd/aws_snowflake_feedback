export const processData = (data, period) => {
    const filteredData = data.filter(item => item.PERIOD === period);
    return {
        labels: filteredData.map(item => item.FEEDBACK || 'Unknown'),
        datasets: [{
            data: filteredData.map(item => item.RECCOUNT),
            backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0'],
            hoverBackgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0']
        }]
    };
};
