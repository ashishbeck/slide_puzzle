# 🧩 Slide Puzzle
A slide puzzle for the Flutter Puzzle Hack.
The live build is available to try [here](https://n-puzzle-solver-1.web.app/) ✨

## 🚀 Features 
- 【﻿ａｅｓｔｈｅｔｉｃ】🌆
- Responsive design that can fit any screen dynamically 📱💻
- Two different difficulties to test your skills- Easy (3x3) and Hard (4x4)
- Tiles can be moved with mouse click, mouse drag (flick or drag n drop) and keyboard arrow keys 🦾
- Can also click/drag multiple tiles at once if the space permits 👀
- Auto solves the puzzle for you in case you get tired 🤖

## 🛠️ Building and Compiling 
This project was created in Flutter 2.8.0 but the final build is produced with the latest version of 2.10.1. Please follow the official [documentations](https://docs.flutter.dev/get-started/install) to set up flutter in your system before proceeding. It also uses Firebase to create accounts and access the community scores. Please setup a firebase project for your app by following the [FlutterFire documentations](https://firebase.flutter.dev/docs/overview/#installation). Clone the repository and open it in terminal/cmd/powershell. Run the following commands to get the app running:

`flutter pub get`

`flutter run -d chrome`

### Firebase
This project uses firebase to anonymously sign in players and keep track of their scores in the firestore database. It also uses cloud functions to keep track of the community scores by pooling them in a single document for moves and times. Whenever a player creates a new score or breaks personal best, apart from update their own user document in users collections, the older stat is also removed and the newer one is added to the aformentioned pool. In order to achieve that, a very basic function is used here which fires on document updates of users collection. The function can be found in the [gist here](https://gist.github.com/ashishbeck/2f5f3d1ab376d09a5cb5445b751380e8). Remember to turn off eslint otherwise it won't deploy. It is not the cleanest piece of code I have ever written but it is what it is 🙄

### Important!
When building for release, please make sure to enable the canvaskit renderer otherwise the custom painter used in the project does not work as intended and produces artifacts in html mode (auto mode defaults to html renderer for mobile devices).

`flutter build web --web-renderer canvaskit`

## 📓 Developer notes
- The app accounts for two types of screen sizes which are enough for any device where the app can be run- tall screens such as phones/tablets and wide screens such as laptops/desktops/tablets.

- The images in individual tiles are not computed or split by copying and cropping because it is a resource intensive task and is not very user friendly. It is simply achieved by wrapping the image (or any other widget) with an `OverflowBox()` and `ClipRect()`. The tile is zoomed and centered in its place using the `Transform.scale()` widget with a scale value of the grid size and an offset based on its default position. Even for a 15-puzzle (4x4), this simple task is quite intensive in certain scenarios so I had to not include the 24-puzzle variant (5x5).

- Why not use popular plugins like `just_audio` for sound? Well, `soundpool` is amazing with loading assets into memory and executing them in a jiffy which makes for a great playing experience. It can also fire multiple instances of the same audio file at the same time which other packages fail to do.

- This game runs on Android, iOS and web. It is not really supposed to be multiplatform because not everything that is implemented here has support for all the platforms. `soundpool` for example has a very experimental support for windows and linux. Firebase has issues in the said platforms as well.

- The solving function used here incorporates IDA* algorithm (with pattern database heuristic) written in python (code modified from [Michael Schrandt](https://github.com/mschrandt/NPuzzle)) which is executed in Google Cloud Run and is accessed via http requests. After trying to implement the algorithm in dart and realising that it could result in potential UI freezes in web along with many other technical problems, I decided to outsource the computational task. For a puzzle of grid size 3, it is able to solve the puzzle within seconds. Grid size of 4 takes quite some time and 5 is beyond the scope of the algorithm which also contributed to not including the 24-puzzle in the final build. The solution is definitely not optimal (usually 50+ moves) and I am not even trying to go for it because it will take a lot more time (sometimes over 2 minutes to solve with manhattan distance heuristic). Moreover, the player wouldn't even understand the moves the AI makes so it is not ideal to go for the optimal solutions anyway. It is a pure aesthetic feature that just looks "cool" and is extremely satisfying to watch.
