const AWS = require('aws-sdk');
const s3 = new AWS.S3();
const comprehend = new AWS.Comprehend();
const sesBucketName = process.env.S3_BUCKET_NAME_SES;
const snowflakeBucketName = process.env.S3_BUCKET_NAME_SNOWFLAKE;
const emailsFolder = 'emails/';
const outputJsonFilePrefix = 'aggregated_emails_';

exports.handler = async (event) => {
    try {
        const response = await s3.listObjectsV2({ Bucket: sesBucketName, Prefix: emailsFolder }).promise();
        const allEmails = [];
        const filesToDelete = [];

        if (response.Contents) {
            for (const item of response.Contents) {
                const fileContent = await s3.getObject({ Bucket: sesBucketName, Key: item.Key }).promise();
                const emailData = JSON.parse(fileContent.Body.toString('utf-8'));
                const emailBody = emailData.body || '';
                const { sentiment, keyPhrases } = await getSentimentAndKeyPhrases(emailBody);
                emailData.sentiment = sentiment;
                emailData.keyPhrases = keyPhrases;
                allEmails.push(emailData);
                filesToDelete.push({ Key: item.Key });
            }
        }

        const currentDateTime = new Date().toISOString().replace(/:/g, '').split('.')[0];
        const outputJsonFile = outputJsonFilePrefix + currentDateTime + '.json';

        // Write aggregated JSON data to S3
        await s3.putObject({
            Bucket: snowflakeBucketName,
            Key: outputJsonFile,
            Body: JSON.stringify(allEmails, null, 2)  // Pretty print JSON
        }).promise();

        // Delete processed files only if the JSON file was successfully created
        for (const file of filesToDelete) {
            await s3.deleteObject({ Bucket: sesBucketName, Key: file.Key }).promise();
        }

        return {
            statusCode: 200,
            body: JSON.stringify('Email data aggregated into JSON and processed files deleted')
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify('Error in processing')
        };
    }
};

async function getSentimentAndKeyPhrases(text) {
    const sentimentResponse = await comprehend.detectSentiment({ Text: text, LanguageCode: 'en' }).promise();
    const sentiment = sentimentResponse.Sentiment;

    const keyPhrasesResponse = await comprehend.detectKeyPhrases({ Text: text, LanguageCode: 'en' }).promise();
    const keyPhrasesList = keyPhrasesResponse.KeyPhrases.map(phrase => phrase.Text);
    const keyPhrases = keyPhrasesList.join('. ');

    return { sentiment, keyPhrases };
}
