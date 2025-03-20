#!/bin/bash

# Initial version

# Function to clear Safari history and cache
clear_safari() {
    echo "Clearing Safari history and cache..."
    osascript -e 'tell application "Safari" to quit'
    osascript <<EOF
    tell application "Safari"
        activate
        delay 1
        tell application "System Events"
            keystroke "y" using {shift down, command down}
        end tell
        delay 1
        quit
    end tell
EOF
    rm -rf ~/Library/Caches/com.apple.Safari
    rm -rf ~/Library/Safari
    rm -rf ~/Library/Preferences/com.apple.Safari*
    echo "Safari history and cache cleared."
}

# Function to clear Chrome history and cache
clear_chrome() {
    echo "Clearing Chrome history and cache..."
    osascript -e 'tell application "Google Chrome" to quit'
    rm -rf ~/Library/Caches/Google/Chrome
    rm -rf ~/Library/Application\ Support/Google/Chrome
    rm -rf ~/Library/Preferences/com.google.Chrome*
    echo "Chrome history and cache cleared."
}

# Function to clear Firefox history and cache
clear_firefox() {
    echo "Clearing Firefox history and cache..."
    osascript -e 'tell application "Firefox" to quit'
    rm -rf ~/Library/Caches/Mozilla/Firefox
    rm -rf ~/Library/Application\ Support/Firefox
    rm -rf ~/Library/Preferences/org.mozilla.firefox*
    echo "Firefox history and cache cleared."
}

# Main script
echo "Starting browser history and cache cleanup..."

# Clear Safari
clear_safari

# Clear Chrome
clear_chrome

# Clear Firefox
clear_firefox

echo "All browser history and cache cleared successfully."

