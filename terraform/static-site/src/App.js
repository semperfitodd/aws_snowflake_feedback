import React, {useEffect, useState} from 'react';
import axios from 'axios';
import './App.css';
import {processData} from './utils';
import ChartComponent from './components/ChartComponent';
import FeedbackCategory from './components/FeedbackCategory';
import {ArcElement, Chart as ChartJS, Legend, Tooltip} from 'chart.js';

ChartJS.register(ArcElement, Tooltip, Legend);

const API_ENDPOINT = '/snowflake';

function App() {
    const [data, setData] = useState({
        currentPeriodData: {datasets: []},
        previousPeriodData: {datasets: []},
        positiveFeedback: [],
        negativeFeedback: [],
        mixedFeedback: [],
        neutralFeedback: [],
        totalEmails: 0,
        positiveFeedbackCount: 0,
        negativeFeedbackCount: 0,
    });
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchData = async () => {
            try {
                const overviewResponse = await axios.get(API_ENDPOINT, {params: {view: 'v_feedback_overview_by_period'}});
                const feedbackResponse = await axios.get(API_ENDPOINT, {params: {view: 'v_feedback_with_keyword_by_period'}});
                const overallAttributesResponse = await axios.get(API_ENDPOINT, {params: {view: 'v_overall_attributes'}});
                const feedbackOverviewResponse = await axios.get(API_ENDPOINT, {params: {view: 'v_feedback_overview'}});

                const positiveCount = feedbackOverviewResponse.data.find(item => item.FEEDBACK === 'POSITIVE')?.RECCOUNT || 0;
                const negativeCount = feedbackOverviewResponse.data.find(item => item.FEEDBACK === 'NEGATIVE')?.RECCOUNT || 0;
                const totalEmails = overallAttributesResponse.data.find(attr => attr.ATTRIBUTE === 'Total responses')?.VALUE || 0;

                setData({
                    ...processFeedback(feedbackResponse.data),
                    currentPeriodData: processData(overviewResponse.data, 'Current period'),
                    negativeFeedbackCount: negativeCount,
                    positiveFeedbackCount: positiveCount,
                    previousPeriodData: processData(overviewResponse.data, 'Previous period'),
                    totalEmails,
                });
            } catch (err) {
                setError('Failed to fetch data. Please try again later.');
                console.error('Error fetching data:', err);
            }
        };

        fetchData();
    }, []);

    const processFeedback = (feedbackData) => {
        const feedbackTypes = ['POSITIVE', 'NEGATIVE', 'MIXED', 'NEUTRAL'];
        const feedbackResult = {};

        feedbackTypes.forEach(type => {
            feedbackResult[type.toLowerCase() + 'Feedback'] = feedbackData
                .filter(item => item.FEEDBACK === type)
                .map(item => item.KEYWORD_LIST.toLowerCase().split(',').map(phrase => phrase.trim()))
                .flat()
                .reduce((acc, phrase) => {
                    acc[phrase] = (acc[phrase] || 0) + 1;
                    return acc;
                }, {});
        });

        return feedbackResult;
    };

    const getCurrentDateTime = () => new Intl.DateTimeFormat('en-US', {
        year: 'numeric', month: 'long', day: '2-digit',
        hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true
    }).format(new Date());

    return (
        <div className="App">
            <header className="App-header">
                <h1>Email Feedback Metrics</h1>
                <p className="data-time">Data as of {getCurrentDateTime()}</p>
            </header>
            <main>
                <section className="email-count-banner">
                    <div>
                        <span className="email-text">Total Emails Received:</span>
                        <span className="email-count">{data.totalEmails}</span>
                    </div>
                    <div>
                      <span className="email-sentiment-positive">
                        <img src={require('./images/smiley.png')} alt="Positive Feedback" className="emoji-image"/> {data.positiveFeedbackCount} positive
                      </span>
                    </div>
                    <div>
                      <span className="email-sentiment-negative">
                        <img src={require('./images/frowny.png')} alt="Negative Feedback" className="emoji-image"/> {data.negativeFeedbackCount} negative
                      </span>
                    </div>

                </section>
                <h2>Email Sentiment Breakdown</h2>
                <section className="chart-section">
                    <div className="chart-container">
                        <ChartComponent title="Current Period" data={data.currentPeriodData}/>
                        <ChartComponent title="Previous Period" data={data.previousPeriodData}/>
                    </div>
                </section>
                {error && <p className="error">{error}</p>}
                <section className="phrases-section">
                    <h2>Key Phrases from Emails</h2>
                    <div className="feedback-row">
                        <FeedbackCategory title="Positive Feedback" feedbackList={data.positiveFeedback}/>
                        <FeedbackCategory title="Negative Feedback" feedbackList={data.negativeFeedback}/>
                    </div>
                    <div className="feedback-row">
                        <FeedbackCategory title="Mixed Feedback" feedbackList={data.mixedFeedback}/>
                        <FeedbackCategory title="Neutral Feedback" feedbackList={data.neutralFeedback}/>
                    </div>
                </section>
            </main>
        </div>
    );
}

export default App;
