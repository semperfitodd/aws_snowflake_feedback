const AWS = require('aws-sdk');
const { simpleParser } = require('mailparser');
const s3 = new AWS.S3();
const bucketName = process.env.S3_BUCKET_NAME;

exports.handler = async (event) => {
    console.log("Received event:", JSON.stringify(event));

    const snsMessage = JSON.parse(event.Records[0].Sns.Message);
    const mail = snsMessage.mail;
    const source = mail.source;
    const subject = mail.commonHeaders.subject;

    const emailDate = new Date(mail.commonHeaders.date);

    const receivedDateTimeUTC = emailDate.toISOString();

    const rawContent = snsMessage.content;
    const emailData = await parseEmail(rawContent);

    const emailInfo = {
        sender: source,
        subject: subject,
        body: emailData.text,
        received_datetime: receivedDateTimeUTC
    };

    const s3Key = 'emails/' + mail.messageId;
    await s3.putObject({
        Bucket: bucketName,
        Key: s3Key,
        Body: JSON.stringify(emailInfo)
    }).promise();

    return {
        statusCode: 200,
        body: JSON.stringify('Email data saved to S3')
    };
};

async function parseEmail(rawContent) {
    try {
        return simpleParser(rawContent);
    } catch (error) {
        console.error("Error parsing email:", error);
        throw error;
    }
}
