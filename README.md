# 🧩 Slide Puzzle
A slide puzzle for the Flutter Puzzle Hack.
The live build is available to try [here](https://ashishbeck.github.io/slide_puzzle/) ✨

## 🚀 Features 
- 【﻿ａｅｓｔｈｅｔｉｃ】🌆
- Responsive design that can fit any screen dynamically 📱💻
- Tiles can be moved with mouse click, mouse drag and keyboard arrow keys 🦾
- Can also click/drag multiple tiles at once if the space permits 👀
- Auto solves the puzzle for you in case you get tired 🤖

## 📓 Developer notes
- The app accounts for two types of screen sizes which are enough for any device where the app can be run- tall screens such as phones/tablets and wide screens such as laptops/desktops/tablets.
- The solving function used here incorporates IDA* algorithm written in python which is executed in Google Cloud Run and is accessed via http requests. After trying to implement the algorithm in dart and realising that it could result in potential UI freezes in web along with many other techincal problems, I decided to outsource the computational task. For a puzzle of grid size 3, it is able to solve the puzzle within seconds. Grid size of 4 takes quite some time and 5 is beyond the scope of the algorithm which is why I had to disable the solve button for it. The solution is definitely not optimal and I am not even trying to go for it because it will take a lot more time and the player wouldn't even understand the moves the AI makes even for the non optimal solutions. It is a pure aesthetic feature that just looks "cool" and is extremely satisfying.
