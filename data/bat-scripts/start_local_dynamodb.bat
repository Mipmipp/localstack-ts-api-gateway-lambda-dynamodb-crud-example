@echo off

REM Open Git Bash and run the script to create the DynamoDB table, suppressing all output
"C:\Program Files\Git\bin\bash.exe" -c "bash data/bash-scripts/start_local_dynamodb.sh >nul 2>&1"

REM Check the exit code of the last command
IF ERRORLEVEL 1 (
    echo Script to create table failed. Check the console for details.
    exit /b 1
) ELSE (
    echo Database created successfully.
)

exit /b 0
