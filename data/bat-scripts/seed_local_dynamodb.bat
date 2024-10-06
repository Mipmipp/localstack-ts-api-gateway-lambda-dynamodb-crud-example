@echo off

REM Open Git Bash and run the script to seed the database, suppressing all output
"C:\Program Files\Git\bin\bash.exe" -c "bash data/bash-scripts/seed_local_dynamodb.sh >nul 2>&1"

REM Check the exit code of the last command
IF ERRORLEVEL 1 (
    echo Seeding data failed. Check the console for details.
    exit /b 1
) ELSE (
    echo Data seeded successfully.
)

exit /b 0
