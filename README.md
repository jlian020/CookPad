# CS179K Senior Design Project - CookPad
Developed by: Justin Mac, Junhao Liang, Jamie Alaniz, Brent Badhwar, Satkaran Tamber
Team Name: Mac and Cheese Its

Before compiling the app:
1. Install cocoapods by opening terminal and typing 'sudo gem install cocoapods' to install the dependencies for Firebase
2. Next, type `pod setup` to download the master repo (may take a while)
3. After, cd into the CookPad directory pulled from GitHub and type `pod init` to create a podfile. Open the podfile created by pod init (using vim or text editor) and add `pod 'Firebase/Core'`, `pod 'Firebase/Auth'`, `pod 'Firebase/Database'`, `pod 'Firebase/Storage'`, `pod 'Firebase/Messaging'` underneath '#Pods for CookPad'.
4. Finally, type `pod install` to install the necessary dependencies for the app.

CookPad is a social media app for recipes shared worldwide. Users are able to add recipes, save recipes, login via Facebook, comment on recipes, etc.


