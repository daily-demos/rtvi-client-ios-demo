# A voice to voice app for iOS

This demo is meant to showcase a basic voice to voice app that uses [Daily's bots](https://bots.daily.co).

## Prerequisites

- [Sign up for a Daily bots account](https://bots.daily.co/sign-up).
- Install [Xcode 15](https://developer.apple.com/xcode/), and set up your device [to run your own applications](https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices).

## Running locally

1. Clone this repository locally.
2. Open the DailyBotsDemo.xcodeproj in Xcode.
3. Tell Xcode to update its Package Dependencies by clicking File -> Packages -> Update to Latest Package Versions.
4. Build the project.
5. Run the project on your device.
6. Connect to the URL you are testing, and to see it work.

> **Note**: In a production environment, it is recommended to avoid calling Daily's API endpoint directly.  
> Instead, you should route requests through your own server to handle authentication, validation,  
> and any other necessary logic. Therefore, the `baseUrl` should be set to the URL of your own server,
> and you should not need to define DAILY_API_KEY environment variable.

## Contributing and feedback

We are welcoming contributions to this project in form of issues and pull request. For questions about RTVI head over to the [Pipecat discord server](https://discord.gg/pipecat) and check the [#rtvi](https://discord.com/channels/1239284677165056021/1265086477964935218) channel.
