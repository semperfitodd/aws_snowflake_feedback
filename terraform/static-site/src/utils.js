export const processData = (data, period) => {
    const filteredData = data.filter(item => item.PERIOD === period);
    const labels = filteredData.map(item => item.FEEDBACK || 'Unknown');
    const counts = filteredData.map(item => item.RECCOUNT);

    return {
        labels,
        datasets: [{
            data: counts,
            backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0'],
            hoverBackgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0'],
        }]
    };
};
