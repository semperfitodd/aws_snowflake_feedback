import React, {useCallback, useEffect, useState} from 'react';
import axios from 'axios';
import {ArcElement, Chart as ChartJS, Legend, Tooltip} from 'chart.js';
import './App.css';
import {processData} from './utils';
import ChartComponent from './components/ChartComponent';
import FeedbackCategory from "./components/FeedbackCategory";

ChartJS.register(ArcElement, Tooltip, Legend);

const API_ENDPOINT = '/snowflake';
const FEEDBACK_OVERVIEW = 'v_feedback_overview_by_period';

const App = () => {
    const [currentPeriodData, setCurrentPeriodData] = useState({datasets: []});
    const [previousPeriodData, setPreviousPeriodData] = useState({datasets: []});
    const [positiveFeedback, setPositiveFeedback] = useState([]);
    const [negativeFeedback, setNegativeFeedback] = useState([]);
    const [mixedFeedback, setMixedFeedback] = useState([]);
    const [neutralFeedback, setNeutralFeedback] = useState([]);
    const [error, setError] = useState("");

    const combinePhrases = (feedbackList) => {
        const phraseCounts = {};

        feedbackList.forEach(item => {
            item.KEYWORD_LIST.toLowerCase().split(',').forEach(phrase => {
                const trimmedPhrase = phrase.trim();
                phraseCounts[trimmedPhrase] = (phraseCounts[trimmedPhrase] || 0) + 1;
            });
        });

        return Object.keys(phraseCounts).map(phrase => `${phrase} (${phraseCounts[phrase]})`);
    };

    const fetchData = useCallback(async () => {
        try {
            let response = await axios.get(API_ENDPOINT, {
                params: {view: FEEDBACK_OVERVIEW}
            });
            let data = response.data;
            setCurrentPeriodData(processData(data, 'Current period'));
            setPreviousPeriodData(processData(data, 'Previous period'));

            response = await axios.get(API_ENDPOINT, {
                params: {view: 'v_feedback_with_keyword_by_period'}
            });
            data = response.data;

            setPositiveFeedback(combinePhrases(data.filter(item => item.FEEDBACK === 'POSITIVE')));
            setNegativeFeedback(combinePhrases(data.filter(item => item.FEEDBACK === 'NEGATIVE')));
            setMixedFeedback(combinePhrases(data.filter(item => item.FEEDBACK === 'MIXED')));
            setNeutralFeedback(combinePhrases(data.filter(item => item.FEEDBACK === 'NEUTRAL')));
        } catch (err) {
            setError("Failed to fetch data. Please try again later.");
            console.error("Error fetching data:", err);
        }
    }, []);

    useEffect(() => {
        fetchData();
    }, [fetchData]);

    const getCurrentDateTime = () => {
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric', month: 'long', day: '2-digit',
            hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true
        }).format(new Date());
    };

    return (
        <div className="App">
            <header className="App-header">
                <h1>Email Feedback Metrics</h1>
                <p className="data-time">Data as of {getCurrentDateTime()}</p>
            </header>
            <main>
                <h2>Email Sentiment Breakdown</h2>
                <section className="chart-section">
                    <div className="chart-container">
                        <ChartComponent title="Current Period" data={currentPeriodData}/>
                        <ChartComponent title="Previous Period" data={previousPeriodData}/>
                    </div>
                </section>
                {error && <p className="error">{error}</p>}
                <section className="phrases-section">
                    <h2>Key Phrases from Emails</h2>
                    <div className="feedback-row">
                        <FeedbackCategory title="Positive Feedback" feedbackList={positiveFeedback}/>
                        <FeedbackCategory title="Negative Feedback" feedbackList={negativeFeedback}/>
                    </div>
                    <div className="feedback-row">
                        <FeedbackCategory title="Mixed Feedback" feedbackList={mixedFeedback}/>
                        <FeedbackCategory title="Neutral Feedback" feedbackList={neutralFeedback}/>
                    </div>
                </section>
            </main>
        </div>
    );

}

export default App;
