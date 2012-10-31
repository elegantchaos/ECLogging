Both the Mac and iOS versions of ECLogging come with some support classes that you can use to provide in-app debugging support for configuring your log channels.

Mac
---

The main ui support class on the Mac is ECLoggingMenu. If you place one of these in your menu in MainMenu.xib, it will automatically populate a Debug menu with lots of options that let you control your channels.

![Mac debug ui](https://github.com/elegantchaos/ECLogging/raw/master/Extras/Documentation/Screenshots/mac%20debug%20menu.png)

You will find a sample application in [[Extras/Examples/Mac|https://github.com/elegantchaos/ECLogging/tree/master/Extras/Examples/Mac]] which illustrates how to do this.

---

The main ui support class on iOS is ECDebugViewController. If you push one of these onto a navigation controller, or show one modally, it will show an interface that lets you control your channels.

![iOS debug view](https://github.com/elegantchaos/ECLogging/raw/master/Extras/Documentation/Screenshots/ios%20debug%20view.png) - ![iOS channels list view](https://github.com/elegantchaos/ECLogging/raw/master/Extras/Documentation/Screenshots/ios%20channels%20view.png) - ![iOS channel configuration view](https://github.com/elegantchaos/ECLogging/raw/master/Extras/Documentation/Screenshots/ios%20channel%20view.png)

You will find a sample application in [[Extras/Examples/iOS|https://github.com/elegantchaos/ECLogging/tree/master/Extras/Examples/iOS]] which illustrates how to do this.