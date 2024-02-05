# Email Feedback Metrics Dashboard

## Overview

This project is designed to collect and analyze feedback from emails automatically. It uses a serverless architecture on
AWS to process emails sent to a specific address, store them in an S3 bucket, and then periodically analyze the contents
using AWS Lambda and Amazon Comprehend for sentiment analysis. The analyzed data is then made available on a dashboard
that presents the sentiment breakdown, key phrases from the emails, and other relevant metrics.

## Features and Benefits

- **Automated Email Analysis**: Our system simplifies the feedback process by automatically collecting, processing, and
  analyzing emails. It eliminates the need for manual sorting and analysis, allowing you to focus on actionable
  insights.
- **Real-Time Sentiment Analysis**: Utilize Amazon Comprehend's natural language processing (NLP) to analyze email
  sentiment in real-time. This powerful tool gives you immediate understanding of customer emotions, helping to gauge
  satisfaction and respond to trends promptly.
- **Interactive Dashboard**: The React frontend provides a dynamic and interactive experience. It features customizable
  charts and graphs for a clear visual representation of data, with real-time updates that reflect the most current
  feedback metrics.

    ![dashboard.png](images%2Fdashboard.png)
- **Serverless Architecture**: By leveraging AWS's serverless components, our architecture offers a cost-effective
  solution that scales automatically with usage. This means you pay only for what you use, without the need to manage
  servers, resulting in lower operational costs and simplified scalability.

## Use Cases

- **Customer Feedback Monitoring**: Ideal for businesses of any size looking to automate the tracking of customer
  feedback. Our dashboard makes it easier to understand customer sentiment, which can inform business strategies and
  improve customer relationships.
- **Product Review Insights**: E-commerce sites and retailers can use the dashboard to aggregate and visualize customer
  sentiment from product reviews. This insight can drive product improvements, targeted marketing campaigns, and better
  inventory decisions.
- **Service Improvement**: Support and customer service teams can leverage the dashboard to identify common concerns and
  sentiment trends. This enables them to proactively address areas for service enhancement and improve overall customer
  satisfaction.

## Architecture

![architecture.png](images%2Farchitecture.png)

## Components

* **Amazon SES:** Receives emails and triggers a Lambda function.
* **Amazon SNS:** Notifies services of new messages.
* **S3 Buckets:** Store emails and static website files.
* **AWS Lambda:** Processes emails, runs on a schedule to analyze data.
* **Amazon Comprehend:** Provides sentiment analysis of email contents.
* **Snowflake Pipes:** Handles the aggregation and storage of processed data.
* **Amazon CloudFront:** Delivers the static website content.
* **Amazon API Gateway:** Interfaces the frontend with backend AWS services.
* **React Frontend:** Displays the dashboard with metrics and analytics.

## Prerequisites

Before deploying this project, ensure you meet the following prerequisites:

- **AWS Account**: You need an active AWS account. Create one at [AWS](https://aws.amazon.com/) if you don't already
  have an account.
- **AWS CLI**: Install and configure the AWS CLI with credentials that have administrative
  access. [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- **Terraform**: Install Terraform for managing infrastructure as
  code. [Terraform Download](https://www.terraform.io/downloads.html)
- **Node.js and npm**: Ensure you have Node.js and npm installed to build the frontend
  application. [Node.js Installation Guide](https://nodejs.org/en/download/)
- **Email Domain**: Verify a domain with Amazon SES to send and receive
  emails. [Amazon SES Domain Verification](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-domains.html)
- **IAM Permissions**: Set up an IAM user with permissions to manage SES, SNS, Lambda, S3, CloudFront, API Gateway, and
  Comprehend.
- **Snowflake Account**: A Snowflake account is required for data
  warehousing. [Snowflake Account Setup](https://signup.snowflake.com/)

## Installation & Deployment

### Frontend Setup and Deployment

1. Navigate to the static-site directory:
    ```bash
    cd static-site
    ```
2. Install the required Node.js packages:
    ```bash
    npm install
    ```
3. Build the frontend application:
    ```bash
    npm run build
    ```

### Backend Deployment with Terraform

1. Clone the repository to your local machine:
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```
2. Navigate to the terraform directory:
    ```bash
    cd terraform
    ```
3. Complete `terraform.tfvars` file with necessary variables such as AWS region, resource names, etc..
4. Initialize the Terraform environment to download necessary providers:
    ```bash
    terraform init
    ```
5. Plan the Terraform deployment to review the changes that will be applied:
    ```bash
    terraform plan -out plan.out
    ```
6. Apply the Terraform plan to deploy the infrastructure:
    ```bash
    terraform apply plan.out
    ```
   **Note:** This step will create resources in your AWS account which will incur costs.

### Post-Deployment

- Set up Snowflake pipes to process and store the data.
- Adjust tfvars file with needed Snowflake variables.
- Run Terraform again.
