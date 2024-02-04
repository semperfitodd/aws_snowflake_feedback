const snowflake = require('snowflake-sdk');
const AWS = require('aws-sdk');

exports.handler = async (event) => {
    const secretsManager = new AWS.SecretsManager();
    const secretName = process.env.SECRET_NAME;
    let connection;
    const viewName = event.queryStringParameters && event.queryStringParameters.view;

    if (!viewName) {
        return {
            statusCode: 400,
            body: JSON.stringify('No view specified')
        };
    }

    try {
        const secretValue = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
        const credentials = JSON.parse(secretValue.SecretString);

        connection = snowflake.createConnection({
            account: credentials.account,
            username: credentials.username,
            password: credentials.password,
            database: 'POC_01',
            schema: 'PUBLIC'
        });

        await new Promise((resolve, reject) => {
            connection.connect((err, conn) => {
                if (err) {
                    console.error('Unable to connect: ' + err.message);
                    reject(err);
                } else {
                    console.log('Successfully connected as id: ' + conn.getId());
                    resolve();
                }
            });
        });

        const sqlText = `SELECT * FROM ${viewName}`;
        const rows = await executeSql(connection, sqlText);

        return {
            statusCode: 200,
            body: JSON.stringify(rows)
        };
    } catch (err) {
        console.error('Error:', err);
        return {
            statusCode: 500,
            body: JSON.stringify('Error executing query')
        };
    } finally {
        if (connection) {
            connection.destroy();
        }
    }
};

function executeSql(connection, sqlText) {
    return new Promise((resolve, reject) => {
        connection.execute({
            sqlText,
            complete: (err, stmt, rows) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(rows);
                }
            }
        });
    });
}
