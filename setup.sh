#!/bin/zsh

rm -rf *.xcworkspace
find ./Projects/ -name "*.xcodeproj" | xargs rm -rf

tuist generate
cp Example/copy_file.sh Example/Package.swift Derived/.

