# TestFlight builds

Lucky Logic uses GitHub's hosted Mac runners to build and upload to the existing
App Store Connect app, ID `6739385077`, bundle ID `com.foowibble.How-Lucky`.

## Upload a build

1. Push tested changes to `main`.
2. Open **Actions → Upload to TestFlight → Run workflow** on GitHub.
3. Enter the app version (currently `2.2`) and an unused build number for that
   version. Increase the build number for each upload.
4. The workflow runs the unit tests, archives a signed Release build, and uploads
   it for internal TestFlight testing. Apple must finish processing the build
   before it becomes installable.
5. In App Store Connect, assign the build to an internal testing group if it does
   not receive builds automatically. Install it through TestFlight on your phone.

This workflow does not submit an App Store release or change the live version.
Uploads run only from `main` and must be manually requested.

## Credentials

The repository's encrypted Actions secrets contain:

- `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY`: the dedicated Developer-role
  key named **Lucky Logic GitHub TestFlight**.
- `APPLE_DISTRIBUTION_P12_BASE64`, `APPLE_DISTRIBUTION_P12_PASSWORD`: the existing
  FooWibble LLC Apple Distribution certificate and its private key.
- `APPLE_PROVISIONING_PROFILE_BASE64`: the app-specific App Store profile named
  **Lucky Logic GitHub TestFlight 2026** (expires September 27, 2027).

Signing material is installed in a temporary runner keychain and cleaned up at
the end of the job. Never commit private keys, P12 files, or passwords. The local
`.local-signing` folder is ignored. Refresh the certificate/profile secrets before
their expiration; do not revoke a shared certificate while another app uses it.

The ordinary **iOS checks** workflow runs without signing secrets on pushes and
pull requests and retains test diagnostics for seven days.

References: [Apple upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/),
[GitHub signing setup](https://docs.github.com/en/actions/how-tos/deploy/deploy-to-third-party-platforms/sign-xcode-applications).
