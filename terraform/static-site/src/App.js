import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js';
import './App.css';
import { processData } from './utils';
import ChartComponent from './components/ChartComponent';
import FeedbackCategory from "./components/FeedbackCategory";

ChartJS.register(ArcElement, Tooltip, Legend);

const API_ENDPOINT = '/snowflake';
const FEEDBACK_OVERVIEW = 'v_feedback_overview_by_period';

const App = () => {
  const [currentPeriodData, setCurrentPeriodData] = useState({ datasets: [] });
  const [previousPeriodData, setPreviousPeriodData] = useState({ datasets: [] });
  const [positiveFeedback, setPositiveFeedback] = useState([]);
  const [negativeFeedback, setNegativeFeedback] = useState([]);
  const [mixedFeedback, setMixedFeedback] = useState([]);
  const [neutralFeedback, setNeutralFeedback] = useState([]);
  const [error, setError] = useState("");

  const fetchData = async () => {
  try {
    // Fetching existing overview data
    let response = await axios.get(API_ENDPOINT, {
      params: { view: FEEDBACK_OVERVIEW }
    });
    let data = response.data;
    setCurrentPeriodData(processData(data, 'Current period'));
    setPreviousPeriodData(processData(data, 'Previous period'));

    // Fetching keyword data
    response = await axios.get(API_ENDPOINT, {
      params: { view: 'v_feedback_with_keyword_by_period' }
    });
    data = response.data;

    // Filtering and setting feedback categories
    setPositiveFeedback(data.filter(item => item.FEEDBACK === 'POSITIVE'));
    setNegativeFeedback(data.filter(item => item.FEEDBACK === 'NEGATIVE'));
    setMixedFeedback(data.filter(item => item.FEEDBACK === 'MIXED'));
    setNeutralFeedback(data.filter(item => item.FEEDBACK === 'NEUTRAL'));
  } catch (err) {
    setError("Failed to fetch data. Please try again later.");
    console.error("Error fetching data:", err);
  }
};

  useEffect(() => {
    fetchData();
  }, []);

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
        <section>
          <div className="chart-container">
            <ChartComponent
                title="Current Period"
                data={currentPeriodData}
            />
            <ChartComponent
                title="Previous Period"
                data={previousPeriodData}
            />
          </div>
        </section>
        {error && <p className="error">{error}</p>}
        <div className="phrases-section">
          <FeedbackCategory title="Positive Feedback" feedbackList={positiveFeedback} />
          <FeedbackCategory title="Negative Feedback" feedbackList={negativeFeedback} />
          <FeedbackCategory title="Mixed Feedback" feedbackList={mixedFeedback} />
          <FeedbackCategory title="Neutral Feedback" feedbackList={neutralFeedback} />
        </div>
  {error && <p className="error">{error}</p>}
      </main>
    </div>
  );
}

export default App;
