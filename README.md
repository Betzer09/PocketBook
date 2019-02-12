# PocketBook
PocketBook Budgeting is a creative and simple way to manage all of your bank accounts and 
transactions without the hassle of giving out your personal information. 

## Description Behind Development
Many of you will probably see this and ask yourself why in the world would you need another budgeting app. PocketBook Budgeting does not
JUST have a clean design but has a specific task to ensure you hit your goals. Many budgeting apps have long and complex onboarding flows
and often ask for your personal information. We don't believe in just being an app that stores and displays your information, but instead
we want to be the place where you regularly interact and see the progress your making. By having to input every single transaction you input
in a day, you will notice how much your spending and definitely start spending less.

## Coming in version 1.2
Version 1.2 is currently underway (Tentative Release date Feb. 28, 2019)
- Implementing Silent Notifications to ensure everything is consistent across devices. 
- Fixing issues with transactions charging an account twice. 
- Adding the option to update a budget category in case you think it is wrong.
- Fixing the layout across all device sizes. 
- If you're using the app across multiple devices you won't be asked 100 times to reset you monthly budget because you already did it!!! 
- Daily notifications to remind you to add your transactions for the day, and you get to pick the time!

## Privacy Policy
Your information is yours alone and is stored safely under your iCloud account. No one has access to your information except you, so 
be sure to keep everything up to date.

## Available on the AppStore
https://itunes.apple.com/us/app/pocketbook-budgeting/id1313590748?mt=8

## Screen Shots
![img_1077 2x](https://user-images.githubusercontent.com/31580350/51434997-ad1bdf80-1c2a-11e9-9988-7b0f782bf790.png)
![img_1076 2x](https://user-images.githubusercontent.com/31580350/51434998-ad1bdf80-1c2a-11e9-8bb2-ac46d87b3775.png)
![img_1075 2x](https://user-images.githubusercontent.com/31580350/51434999-ad1bdf80-1c2a-11e9-9271-ac86fcf424ec.png)
![img_1078 2x](https://user-images.githubusercontent.com/31580350/51435000-adb47600-1c2a-11e9-934f-fae0e74aafd8.png)

## Frameworks Used
- CloudKit 
- Silent PushNotifications
- CoreGraphics
- Programmatic Constraints 

## CloudKit 
CloudKit was used in order to gain experience and leverage Apple's Free Cloud Services. We decided to use CloudKit over CoreData
because we thought it would be important to allow our users to be able to use the app on multiple devices instead of just one device. 
All the information used in the app is saved to the user's private database. 

## Silent Notifications 
Seeing how people have multiple devices we thought it would only be fair to have everything looks the same across everyone's devices. 
No one likes being lied to about how much money they have!

## CoreGraphics
Cocopods are loved and hated by many developers so instead of using a third-party framework made by someone else we thought it would be
important to learn Apple's documentation and utilize their CoreGraphics framework to draw graphs on the screen. 

# Programmatic Constraints
Not everything in life is perfect spaced out and it is hard to guess how much room something should take up when there is an unlimited 
amount of information that could be shown. In the case of our Monthly Budget tab some users could have up to 16 budget categories.
So, instead of guessing or forcing constraints for our labels and graphs we used programmatic constraints
to ensure we always had a clean look. 

