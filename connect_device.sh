#!/bin/bash

ADB="/Users/macbook/Library/Android/sdk/platform-tools/adb"
DEVICE_IP="192.168.18.54"

echo "🔄 Resetting ADB Server..."
$ADB kill-server
$ADB start-server

echo "🔌 Setting TCP/IP Mode..."
# We try to set tcpip. If the device is not plugged in via USB, this might fail 
# if it's not already listening. But if it was just connected, it might work.
$ADB tcpip 5555 
sleep 2

echo "🔗 Connecting to $DEVICE_IP..."
$ADB connect $DEVICE_IP:5555

echo "📱 Connected Devices:"
$ADB devices
