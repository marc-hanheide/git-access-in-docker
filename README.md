# An secure way to inject a github token into docker builds

## Approach
* use [Docker build secrets](https://docs.docker.com/build/building/secrets/) to make an access token available
* set `GIT_ASKPASS` so that the token is injected anytime a git command is used
* A few build steps that make this as easy as possible

## Usage

### In `Dockerfile`

1. add the generation of a `GIT_ASKPASS` helper to your `Dockerfile`:
    ```
    RUN cat <<EOF > /git-askpass.sh
    #!/bin/bash
    echo "\`cat /run/secrets/GIT_TOKEN\`"
    EOF
    RUN chmod +x /git-askpass.sh
    ```

1. whenever a `RUN` command needs git access, we add `--mount=type=secret,id=GIT_TOKEN GIT_ASKPASS=/git-askpass.sh`, e.g.:
    ```
    RUN --mount=type=secret,id=GIT_TOKEN GIT_ASKPASS=/git-askpass.sh \
        git clone https://github.com/LCAS/aoc_navigation.git
    ```

### At build step

At build time the secret needs to be injected into the container, e.g.

1. set the secret as an environment variable in your own environment, e.g. `export GH_TOKEN=ghp_SECRETTOKENLsdfgges786asdGfswe73aef3Fs` (not an actual token here, for illustration only)
1. inject it into your build command with the flag: `--secret id=GIT_TOKEN,env=GH_TOKEN` (replace `GH_TOKEN` with the name of the environment variable you used to store the access token), e.g.
    ```
    docker build --progress=plain  --secret id=GIT_TOKEN,env=GH_API_TOKEN .
    ```

# NOTES

* **NEVER** create a file in the build process that contains the token (don't let it leak into the image)
* Use tokens with minimal scopes (see https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
* The [`pomdtr.secrets`](https://marketplace.visualstudio.com/items?itemName=pomdtr.secrets) VSCode extension is useful to manage secrets in your VSCode
