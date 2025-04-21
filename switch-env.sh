#!/bin/bash

# Function to stop all related processes
stop_processes() {
    echo "🛑 Stopping any running processes..."
    pkill -f 'vite' 2>/dev/null
    supabase stop 2>/dev/null
}

# Function to clean cache and rebuild
clean_and_rebuild() {
    echo "🧹 Cleaning cache and rebuilding..."
    rm -rf node_modules/.vite dist
    npm install
}

# Function to start the development server with the correct environment
start_dev_server() {
    echo "🚀 Starting development server with $1 environment..."
    if [ "$1" == "prod" ]; then
        VITE_SUPABASE_URL=https://pukoguerqijfsfqrypev.supabase.co \
        VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1a29ndWVycWlqZnNmcXJ5cGV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3MjM0MzcsImV4cCI6MjA2MDI5OTQzN30.tSJ1gl3ooeIvTbqY_iClPTgTtYnHrmkYs9ZESDM-o2Q \
        npm run dev
    else
        npm run dev
    fi
}

# Main script
echo "🎯 Environment Switcher"
echo "======================"

# Select environment
select env in "local" "prod"; do
    case $env in
        local )
            stop_processes
            cp .env.local .env
            echo "✅ Switched to LOCAL environment"
            clean_and_rebuild
            start_dev_server "local"
            break;;
        prod )
            stop_processes
            cp .env.prod .env
            echo "✅ Switched to PRODUCTION environment"
            clean_and_rebuild
            start_dev_server "prod"
            break;;
    esac
done 