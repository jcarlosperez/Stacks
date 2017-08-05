# [Stacks](http://getstacksapp.com/)
##### [View on the App Store](https://itunes.apple.com/us/app/stacks-send-stacks-of-images/id1163578161?mt=8)
Stacks is beautifully designed to provide a better and more concise way to share photos with a contact and receive their opinion on those images. Quickly and easily share a group of related photos with a friend, significant other or anybody really without flooding the conversation with individual images. With a clear and minimal interface, Stacks will present the images in a rotary slideshow where they can be rated to indicate which was liked more. After rating the images, Stacks can send a response message with the ratings back to the original sender to view. 

Enjoy!

## Getting Started

When a stack is sent, the images are stored online using AWS. In order to get this project working locally, you will need to create an AWS account and add your own keys to the project to store the images on your account. If you would like to do this, replace the following locations with your key.

> 1. Change region type: [Line 33 of MessagesExtension/STKSServerManager.m](https://github.com/jcarlosperez/Stacks/blob/master/MessagesExtension/STKSServerManager.m#L33). 
> 2. Change identity pool ID: [Line 33 of MessagesExtension/STKSServerManager.m](https://github.com/jcarlosperez/Stacks/blob/master/MessagesExtension/STKSServerManager.m#L33). 
> 3. Change unauth role ARN: [Line 33 of MessagesExtension/STKSServerManager.m](https://github.com/jcarlosperez/Stacks/blob/master/MessagesExtension/STKSServerManager.m#L33). 

You will additionally need to have [Cocoapods](https://cocoapods.org/) installed. Run `pod install` to install all required dependencies.
Once you have done this, you are ready to go. Build the project with Xcode and install it on your devices.

## Screenshots
| Send a stack of images | View it in the message thread | Rate the images | Reply back with your feedback | 
|-------------------------------------------------------------------------	|-------------------------------------------------------------------------	| -------------------------------------------------------------------------	| ---------------------------------------------------------------------------------------------	|
| ![](https://raw.githubusercontent.com/jcarlosperez/Stacks/master/Screenshots/send.png?token=AHpReOhIk1eYQlHHlFgNxBB1cm_vismHks5ZjyOGwA%3D%3D) | ![](https://raw.githubusercontent.com/jcarlosperez/Stacks/master/Screenshots/threads.png?token=AHpReDu4thIfoZyfjRIglauFVCalmblpks5ZjyO3wA%3D%3D) | ![](https://raw.githubusercontent.com/jcarlosperez/Stacks/master/Screenshots/rate.png?token=AHpReGAFbHeoRNEqGonPK94qGKwTxtPSks5ZjyMdwA%3D%3D) |![](https://raw.githubusercontent.com/jcarlosperez/Stacks/master/Screenshots/reply.png?token=AHpReOC-ty0cvHXnnxe1OdjS364gSf2dks5ZjyNqwA%3D%3D)|

## Built With

* [AWS](https://github.com/aws/aws-sdk-ios) - AWS Mobile SDK for iOS
* [CompactConstraint](https://github.com/marcoarment/CompactConstraint) - Simple NSLayoutConstraint expression parser for more readable autolayout code.
* [CTAssetsPickerController](https://github.com/chiunam/CTAssetsPickerController) - iOS control that allows picking multiple photos and videos from user's photo library.
* [KTCenterFlowLayout](https://github.com/keighl/KTCenterFlowLayout) - Aligns collection view cells to the center of the screen.
* [RXPromise](https://github.com/couchdeveloper/RXPromise) - An Objective-C Class which implements the Promises/A+ specification.

## Contribute
We'd love to recieve contributions from fellow developers. Feel free to send a pull request our way.

## Developers
* **Ben Rosen** -- [Twitter](https://twitter.com/benmrosen)
* **Juan Carlos Perez** -- [Twitter](https://twitter.com/J_Carlos_Perez)

## License
Open sourced under the [GNU General Public License v3.0](https://github.com/jcarlosperez/stacks/blob/master/LICENSE).

    This file is part of Stacks.

    Stacks is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Stacks is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Stacks.  If not, see <http://www.gnu.org/licenses/>.