# CS179K Senior Design Project - CookPad

CookPad is a social media app for recipes shared worldwide. Users are able to add recipes, save recipes, login via Facebook, comment on recipes, etc.

## Getting Started

Before compiling the app:
1. Install cocoapods by opening terminal and typing `sudo gem install cocoapods` to install the dependencies for Firebase
2. Next, type `pod setup` to download the master repo (may take a while)
3. After, cd into the CookPad directory pulled from GitHub. (Skip to step 4, if you pulled from the Github repo as the podfile is already setup). Type `pod init` to create a podfile. Open the podfile created by pod init (using vim or text editor) and add the following underneath '#Pods for CookPad'.
```
pod 'Firebase/Core' 
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
```
4. Finally, type `pod install` to install the necessary dependencies for the app.

CookPad is a social media app for recipes shared worldwide. Users are able to add recipes, save recipes, login via Facebook, comment on recipes, etc.

## Authors
Developed by: Justin Mac, Junhao Liang, Jamie Alaniz, Brent Badhwar, Satkaran Tamber
