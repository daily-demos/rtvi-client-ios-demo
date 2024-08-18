# A voice to voice app for iOS

This demo is meant to showcase a basic voice to voice app that uses [Daily's bots](https://bots.daily.co).

## Prerequisites

- [Sign up for a Daily bots account](https://bots.daily.co/sign-up).
- Install [Xcode 15](https://developer.apple.com/xcode/), and set up your device [to run your own applications](https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices).

## Running locally

1. Clone this repository locally, i.e.: `git clone git@github.com:rtvi-ai/rtvi-client-ios-demo.git`
2. Open the RTVIDemo.xcodeproj in Xcode.
3. Tell Xcode to update its Package Dependencies by clicking File -> Packages -> Update to Latest Package Versions.
4. Set DAILY_API_KEY Environment Variables in Xcode Scheme:
   - Select the project from the Project Navigator.
   - Click on the RTVIDemo target.
   - Go to the "Product" menu, then select "Scheme", and choose "Edit Scheme...".
   - In the Scheme editor, select the "Run" tab from the left sidebar.
   - In the "Run" tab, open the "Arguments" section.
   - Under the "Environment Variables" section, click the + button to add a new environment variable.
   - Set the Name to DAILY_API_KEY and the Value to your actual API key.
   - Click "Close" to save the changes.
5. Build the project.
6. Run the project on your device.
7. Connect to the URL you are testing, and to see it work.

> **Note**: In a production environment, it is recommended to avoid calling Daily's API endpoint directly.  
> Instead, you should route requests through your own server to handle authentication, validation,  
> and any other necessary logic. Therefore, the `baseUrl` should be set to the URL of your own server,
> and you should not need to define DAILY_API_KEY environment variable.

## Contributing and feedback

We are welcoming contributions to this project in form of issues and pull request. For questions about RTVI head over to the [Pipecat discord server](https://discord.gg/pipecat) and check the [#rtvi](https://discord.com/channels/1239284677165056021/1265086477964935218) channel.
