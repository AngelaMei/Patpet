# Ur

This is the Auki Ur (Machine Learning) module.
It provides functionality based on machine learning such as hand tracking.

The native modules come from the `com.aukilabs.mediapipe` repository which is based on Mediapipe and is built using CI/CD pipelines in that repo. It is then downloaded to this repository via our NPM registry and included in the final Unity package built in this repository. Other repositories can be included by modifying the Makefile.

## Build locally

 - Clone this repo: `git clone git@github.com:aukilabs/com.aukilabs.unity.ur.git`
 - `make node_modules`
 - `make build-lib`

`native_hand_tracker_plugin.a` contains `ios_hand_tracker.o` which is the iOS hand tracker plugin. `native_hand_tracker.dylib` is the desktop version.

If you're adding this repository directly to a Unity project (not using the NPM package) you have to edit the project manifest.json and include the local version:

`"com.aukilabs.unity.ur": "file:../modules/com.aukilabs.unity.ur/Assets",`

Notice the "/Assets" at the end. This is necessary as this repo Unity package is assembled in that folder.

If you want to run on an iOS device, bitcode needs to be disabled in Xcode after the Unity project has been built and exported as an Xcode project. Click the Unity-iPhone project name on the left side of Xcode, then make sure the **PROJECT** Unity-iPhone is selected on the middle pane rather than any **TARGETS**. Then open the Build Settings tab, choose All instead of Basic and then input "bitcode" in the Filter text field. Select Enable Bitcode: No.

## Important files
* package.json - used by GitHub Actions CI/CD pipeline to build DLL and publish to NPM. When releasing, the dependencies need to be available in the external NPM registry or the build will fail.
* Packages/manifest.json - used when opening the project in Unity Editor to develop samples. Can use packages from the internal NPM registry as it's only used by Auki Labs during development.

## Git workflow
Please see the [workflow document](https://github.com/aukilabs/documentation/blob/main/GITHUB_WORKFLOW.md).

## Pipeline information
Pull requests trigger two build jobs, one for the native framework and one for the Unity package. The Unity package is compiled (using the `INTERNAL` build constant) and the job packages all resources but doesn't publish anywhere.

Every merge to the `develop` branch will first trigger a build job that bumps the version number and then triggers the same build job as for pull requests that compiles (using the `INTERNAL` build constant) and packages all resources, but this time it also publishes the package to the internal NPM registry. An internal [SDK demo app](https://github.com/aukilabs/AukiUnitySDKDemo) build is also triggered and pushed to TestFlight.

## How to release
1. Make sure your code has been tested and stable enough for a release. Please note that this will release to the external NPM registry for our SDK users to download.
2. Follow the [Git workflow](https://github.com/aukilabs/documentation/blob/main/GITHUB_WORKFLOW.md#branches-and-releases) to get your code on the `main` branch using pull requests.
3. Create a release on GitHub by clicking **Create a new release** under **Releases** in the right side of the repository overview.
4. Inside the release creation process, choose to create a new tag with a version starting with **v**, such as `v0.4.0`. It should match the version which is inside `package.json` of the `main` branch.

The tag creation will trigger build jobs that compile and package all resources and publish the Unity package to the external NPM registry. An automatically incremented tag is also pushed to the [SDK demo app](https://github.com/aukilabs/AukiUnitySDKDemo) repository which triggers an external SDK demo app build in that repository. The app will then be pushed to TestFlight.

## How to log in to NPM registry
If you need to download dependencies to be able to run `make init`, `make build`, `msbuild` or build the DLL file inside Rider, you need to authenticate to the NPM registry first.

```
npx verdaccio-github-oauth-ui --registry https://npm.dev.aukiverse.com
source .npmlogin
```
If your restart your terminal, you might need to run `source .npmlogin` again since the `NODE_AUTH_TOKEN` environment variable isn't set.
