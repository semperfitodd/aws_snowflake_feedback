// FeedbackCategory.js
import React from 'react';

const FeedbackCategory = ({ title, feedbackList }) => {
  return (
    <div className="feedback-category">
      <h3>{title}</h3>
      <ul>
        {feedbackList.map((phrase, index) => (
          <li key={index}>{phrase}</li>
        ))}
      </ul>
    </div>
  );
};

export default FeedbackCategory;
