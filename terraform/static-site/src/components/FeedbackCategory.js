// FeedbackCategory.js
import React from 'react';

const FeedbackCategory = ({ title, feedbackList }) => {
  return (
    <div className="feedback-category">
      <h3>{title}</h3>
      <ul>
        {feedbackList.map((feedback, index) => (
          <li key={index}>{feedback.KEYWORD_LIST}</li>
        ))}
      </ul>
    </div>
  );
};

export default FeedbackCategory;
