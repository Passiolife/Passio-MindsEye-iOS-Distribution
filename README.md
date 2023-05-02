# Passio-MindsEye-iOS-Distribution

## Getting Started

1. In order to use Passio's MindsEye app first go to [MindsEye](https://labs.passiolife.com/mindseye), type in what you want to recognize, and click "Download Model".
![download_model](img/download_model.png)

2. Clone this repo. In a terminal run `git clone https://github.com/Passiolife/Passio-MindsEye-iOS-Distribution.git` then `cd Passio-MindsEye-iOS-Distribution/`

3. Run `open MindsEye.xcodeproj/`

4. The project will open in Xcode. First of all navigate to the "Signing & Capabilities" page and verify that your provisioning profile is setup correctly. Sometimes you might have to log in. You should see something like this:
![xcode_signing](img/xcode_signing.png)

5. Drag the `MLModel` file into the project and add it. The dialog should like the one below. Click "Finish".
![add_model](img/add_model.png)

6. Now edit the model name in `ViewController.swift`. By default the model name is `My-Passio-MindsEye-Model`
![rename_model](img/rename_model.png)

7. Attach your iPhone and select is as the build target

8. Run the app on your phone and recognize the items you listed in MindsEye
![tada](img/tada.jpg)


