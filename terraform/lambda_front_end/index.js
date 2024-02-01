const snowflake = require('snowflake-sdk');
const AWS = require('aws-sdk');

exports.handler = async (event) => {
    const secretsManager = new AWS.SecretsManager();
    const secretName = process.env.SECRET_NAME;
    let connection;

    try {
        const secretValue = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
        const credentials = JSON.parse(secretValue.SecretString);

        connection = snowflake.createConnection({
            account: credentials.account,
            username: credentials.username,
            password: credentials.password,
            view: credentials.view
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

        const viewName = credentials.view;
        const sqlText = `SELECT * FROM ${viewName} LIMIT 10`;
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
