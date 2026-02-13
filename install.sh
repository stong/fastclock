#!/bin/bash

# Build the app first
make package

# Copy to Applications
echo "Installing FastClock.app to /Applications..."
rm -rf /Applications/FastClock.app
cp -R FastClock.app /Applications/

echo ""
echo "FastClock.app installed to /Applications!"
echo ""
echo "To make it start at login:"
echo "1. Open System Settings → General → Login Items"
echo "2. Click + under 'Open at Login'"
echo "3. Select FastClock.app from Applications"
