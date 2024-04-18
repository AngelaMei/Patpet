# Manna

This is the Auki Manna (Proof of Location & Calibration) module.

Manna is used for devices to find their position in a space through one or several of the different Proof of Location methods supported by Auki as described below:

* Instant Calibration - Calibrating off of a host device displaying a dynamic lighthouse while rapidly sending its pose updates over the network for the calibrating device to match with.
*  Domain Calibration / Static Lighthouse - Calibration of a static lighthouse tied to one or many domains. The static lighthouse has a known pose in the domain and the moment any device in a space calibrates off of a lighthouse in a domain, the space is linked to the domain and domain topography data can be downloaded to be used by all participants in the space.

## Setup Development Environment
1. `make modules`.
2. Open Project in Unity Editor.
3. Switch Platform to iOS.

*Desktop version requires OpenCV for Unity. https://assetstore.unity.com/packages/tools/integration/opencv-for-unity-21088*

## Important files
* package.json - used by GitHub Actions CI/CD pipeline to build DLL and publish to NPM. When releasing, the dependencies need to be available in the external NPM registry or the build will fail.
* Packages/manifest.json - used when opening the project in Unity Editor to develop samples. Can use packages from the internal NPM registry as it's only used by Auki Labs during development.

## Git workflow
Please see the [workflow document](https://github.com/aukilabs/documentation/blob/main/GITHUB_WORKFLOW.md).

## Pipeline information
Pull requests trigger a build job that compiles (using the `INTERNAL` build constant) and packages all resources but doesn't publish anywhere.

Every merge to the `develop` branch will trigger a build job that bumps the version number and then triggers another build job that compiles (using the `INTERNAL` build constant) and packages all resources and publishes the package to the internal NPM registry. An internal [SDK demo app](https://github.com/aukilabs/AukiUnitySDKDemo) build is also triggered and pushed to TestFlight.

## How to release
1. Make sure your code has been tested and stable enough for a release. Please note that this will release to the external NPM registry for our SDK users to download.
2. Follow the [Git workflow](https://github.com/aukilabs/documentation/blob/main/GITHUB_WORKFLOW.md#branches-and-releases) to get your code on the `main` branch using pull requests.
3. Create a release on GitHub by clicking **Create a new release** under **Releases** in the right side of the repository overview.
4. Inside the release creation process, choose to create a new tag with a version starting with **v**, such as `v0.4.0`. It should match the version which is inside `package.json` of the `main` branch.

The tag creation will trigger a build job that compiles and packages all resources and publishes the package to the external NPM registry. An automatically incremented tag is also pushed to the [SDK demo app](https://github.com/aukilabs/AukiUnitySDKDemo) repository which triggers an external SDK demo app build in that repository. The app will then be pushed to TestFlight.

## How to log in to NPM registry
If you need to download dependencies to be able to run `make init`, `make build`, `msbuild` or build the DLL file inside Rider, you need to authenticate to the NPM registry first.

```
npx verdaccio-github-oauth-ui --registry https://npm.dev.aukiverse.com
source .npmlogin
```
If your restart your terminal, you might need to run `source .npmlogin` again since the `NODE_AUTH_TOKEN` environment variable isn't set.
