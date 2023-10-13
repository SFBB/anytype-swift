# Anytype
Official Anytype client for iOS.

## Building the source
Use XCode to build the project.

[`anytype-heart`](https://github.com/anyproto/anytype-heart) is required for a successful build.

### Use pre-built `anytype-heart`

Create a personal access token [here](https://github.com/settings/tokens) with `read:packages` access.

More about [access to maven repo](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-apache-maven-registry).

`make setup-middle` — install the latest `anytype-heart` version.

Script will be ask you to input `MIDDLEWARE_TOKEN` - this is your personal github token.

`make change-github-token` - update `MIDDLEWARE_TOKEN`

### Build `anytype-heart` locally

Clone [`anytype-heart`](https://github.com/anyproto/anytype-heart) repo.
Check folder structure for use `make` in next steps:
```
- Parent Directory
  | - anytype-heart
  | - anytype-swift
```

Configure go environment by following instructions in [`anytype-heart`](https://github.com/anyproto/anytype-heart) repo.

`make setup-middle-local` — build and setup `anytype-heart` from the local repo.

## Contribution
Thank you for your desire to develop Anytype together!

❤️ This project and everyone involved in it is governed by the [Code of Conduct](docs/CODE_OF_CONDUCT.md).

🧑‍💻 Check out our [contributing guide](docs/CONTRIBUTING.md) to learn about asking questions, creating issues, or submitting pull requests.

🫢 For security findings, please email [security@anytype.io](mailto:security@anytype.io) and refer to our [security guide](docs/SECURITY.md) for more information.

🤝 Follow us on [Github](https://github.com/anyproto) and join the [Contributors Community](https://github.com/orgs/anyproto/discussions).

---
Made by Any — a Swiss association 🇨🇭

Licensed under [Any Source Available License 1.0](./LICENSE.md).