#!/bin/bash

# the x and - here are not ASCII characters
THE_FORMULA="0.123 × 1045−8140 to 112.36 × 123.4"

function emoji(){
  emojis=(🐶 🐺 🐱 🐭 🐹 🐰 🐸 🐯 🐨 🐻 🐷 🐮 🐵 🐼 🐧 🐍 🐢 🐙 🐠 🐳 🐬 🐥)
  echo ${emojis[$RANDOM % 22]}
}

emoji
