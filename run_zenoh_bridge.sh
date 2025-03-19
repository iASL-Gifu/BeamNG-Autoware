#!/bin/bash

# 実行するコマンドとオプションを定義
EXECUTABLE="./target/release/zenoh-bridge-ros2dds"
CONFIG_FILE="./config/config.json5"

# 実行
if [ -x "$EXECUTABLE" ]; then
    $EXECUTABLE --config $CONFIG_FILE
else
    echo "Error: $EXECUTABLE is not executable or not found."
    exit 1
fi
