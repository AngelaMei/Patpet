# ConjureKit

This is the ConjureKit module. It only provides basic networking functionality. It can be used in combination with other modules to provide more functionality.

## Important files

* package.json - used by GitHub Actions CI/CD pipeline to build DLL and publish to NPM. When releasing, the dependencies need to be available in the external NPM registry or the build will fail.
* Packages/manifest.json - used when opening the project in Unity Editor to develop samples. Can use packages from the internal NPM registry as it's only used by Auki Labs during development.

## Dependencies
The CI/CD pipeline runs `make init` which pulls in the other source code repositories and puts them in the `modules` folder. The `com.aukilabs.unity.util.json` module needs C# 9.0 in order to compile, so currently we use Microsoft's .NET SDK to compile because stable versions of Mono 6.12 do not yet support C# 9.0. When a more recent version of Mono (6.12.0.174+) is available for use on GitHub or Docker Hub, we can switch back to Mono.

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
