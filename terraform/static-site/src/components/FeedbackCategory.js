import React from 'react';
import PropTypes from 'prop-types';

const FeedbackCategory = ({title, feedbackList}) => (
    <div className="feedback-category">
        <h3>{title}</h3>
        <ul>
            {Object.entries(feedbackList).map(([phrase, count]) => (
                <li key={phrase}>{`${phrase} (${count})`}</li>
            ))}
        </ul>
    </div>
);

FeedbackCategory.propTypes = {
    title: PropTypes.string.isRequired,
    feedbackList: PropTypes.object.isRequired
};

export default FeedbackCategory;
