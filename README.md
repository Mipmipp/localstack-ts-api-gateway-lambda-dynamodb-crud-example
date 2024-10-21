[![LocalStack Pods Launchpad](https://localstack.cloud/gh/launch-pod-badge.svg)](https://app.localstack.cloud/launchpad?url=https://raw.githubusercontent.com/localstack/cloud-pod-badge/main/MyOwnPod) ![ts](https://badgen.net/badge/Built%20With/TypeScript/blue) ![Coverage](https://img.shields.io/badge/coverage-84.25%25-brightgreen)

# Introduction
This repository is an example of a basic CRUD application, designed to test and work locally with [API Gateway](https://aws.amazon.com/api-gateway/) and [Lambda](https://aws.amazon.com/lambda/). It utilizes [TypeScript](https://www.typescriptlang.org/) and [DynamoDB](https://aws.amazon.com/dynamodb/) as the database ([Dynamoose](https://dynamoosejs.com/getting_started/Introduction) as an optional ORM library).

All AWS services are run locally using [LocalStack](https://www.localstack.cloud/) within [Docker](https://www.docker.com/), allowing for a seamless development experience. Everything is containerized, enabling end-to-end local testing using [Jest](https://jestjs.io/) and [Supertest](https://www.npmjs.com/package/supertest) while seeding the database. All operations are run via scripts to simplify the process of packaging code for Lambda, along with its [dependencies as a layer](https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html).

## LocalStack Services

This project utilizes the following LocalStack services:

- **API Gateway**: [LocalStack API Gateway Documentation](https://docs.localstack.cloud/user-guide/aws/apigateway/)
- **Lambda**: [LocalStack Lambda Documentation](https://docs.localstack.cloud/user-guide/aws/lambda/)
- **DynamoDB**: [LocalStack DynamoDB Documentation](https://docs.localstack.cloud/user-guide/aws/dynamodb/)

## Clarification

Everything has been tested on Windows; it has not been tested on Ubuntu or other operating systems. However, the libraries are cross-platform, so it shouldn't be too difficult to set everything up.

## Dependencies

- [**Docker**](https://www.docker.com/): To run the localstack Docker image.
- [**7zip**](https://www.7-zip.org/): Installed and added to the PATH in environment variables to zip the code.
- [**AWS CLI**](https://docs.aws.amazon.com/streams/latest/dev/setup-awscli.html): To run various localstack commands.
- Ensure that the scripts run in the Windows console, as they may not execute properly in environments like VSCode.

## Run Locally

### Clone the project

```bash
git clone https://github.com/Mipmipp/localstack-ts-api-gateway-lambda-dynamodb-crud-example.git
```

### Go to the project directory

```bash
cd localstack-ts-api-gateway-lambda-dynamodb-crud-example
```

### Install dependencies

```bash
npm ci
```

### Start the server

```bash
npm run start:dev
```

## Environment Variables

To run this project, rename the `.env.dist` file to `.env` and populate it with the necessary environment variables.

## Running Tests

To run tests in the console:

```bash
npm run test:dev
```

## Package Scripts

| Command                                      | Description                                                                                              |
|----------------------------------------------|----------------------------------------------------------------------------------------------------------|
| `test:e2e`                                   | Runs end-to-end tests.                                                                                  |
| `test:handler`                               | Runs unit tests against the handler index.                                                              |
| `prebuild`                                   | Deletes the `dist` folder.                                                                               |
| `create-package`                             | Creates an empty `package.json` in `temp-dependencies-layer`.                                          |
| `build:index`                                | Transpiles the `index.ts` code to JavaScript with a global handler banner in the output directory.       |
| `build:src`                                  | Transpiles all TypeScript files excluding `index.ts`.                                                  |
| `build:dependencies`                         | Edits a temp folder for non-development dependencies.                                                   |
| `build`                                      | Runs the commands to build the project.                                                                  |
| `postbuild`                                  | Zips the contents of the temp folders to `dist` and deletes the temp folders.                           |
| `start:local-db`                             | Runs scripts to start the local DynamoDB instance.                                                      |
| `seed:local-db`                              | Runs scripts to seed the local database.                                                                 |
| `start:local-api`                            | Runs scripts to start the local API Gateway and Lambda.                                                |
| `wait-for-docker`                            | Runs scripts to wait for Docker to be ready.                                                            |
| `start:dev`                                  | Runs the complete setup for local development, including Docker and local database initialization.        |
| `test:dev`                                   | Runs the complete setup for local testing, including Docker and end-to-end tests.                       |

## Bash Scripts

| Script Name                                   | Description                                                                                              |
|-----------------------------------------------|----------------------------------------------------------------------------------------------------------|
| **`seed_local_dynamodb.sh`**                  | Seeds the local database with various items (can be omitted or edited).                                 |
| **`start_local_api_gateway_and_lambda.sh`**  | Configures everything, deploying functions with the zipped handler code, creating Lambda functions, API Gateway, connecting endpoints, and generating a `.local.env` file with the endpoint and local API ID. This can be edited for various CRUD resources. |
| **`start_local_dynamodb.sh`**                 | Creates an empty local database (can be updated to include tables and more).                            |
| **`wait-for-docker.sh`**                      | Pings the Docker container endpoint to check if everything is up and running.                           |

## Local Endpoint

Once the scripts are executed, the `.local.env` file will contain the `LOCAL_API_ENDPOINT` variable, created by LocalStack. This changes with the `LOCAL_API_ID`, which is also stored for potential use in tests.

## Files for Lambda Deployment

In the `dist` directory, you will find:
- **`index.zip`**: Minified JavaScript code from `src` ready for AWS Lambda deployment.
- **`dependencies-layer.zip`**: Non-development dependencies packaged for Lambda as a layer.

## Database Suggestions

To manage and view your local DynamoDB database, we recommend using [**AWS NoSQL Workbench**](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.html). This tool provides a user-friendly interface for querying and visualizing data.

### Quick Setup Guide

1. **Install AWS NoSQL Workbench**: Download from the [AWS NoSQL Workbench website](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.settingup.html).

2. **Open the Application**: Launch NoSQL Workbench after installation.

3. **Add a Connection**:
   - Navigate to the **"Operation Builder"** tab.
   - Click **"Add connection"** and select **"DynamoDB Local"**.

4. **Configure Connection**:
   - Set the host to `localhost` and the port to `4566` (or your configured port).
   - Test the connection to ensure it's working.

5. **Start Managing Your Data**: Use the Operation Builder to run queries, insert items, and visualize your database.
 
