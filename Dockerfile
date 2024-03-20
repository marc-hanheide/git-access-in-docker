FROM ubuntu:22.04 as base

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

######################
# Configure GIT access in docker

RUN cat <<EOF > /git-askpass.sh
#!/bin/bash
echo "\`cat /run/secrets/GIT_TOKEN\`"
EOF
RUN chmod +x /git-askpass.sh

######################

# whenever we need the secret in a run command, we can use --mount=type=secret,id=GIT_TOKEN
RUN --mount=type=secret,id=GIT_TOKEN GIT_ASKPASS=/git-askpass.sh \
    git clone https://github.com/LCAS/aoc_navigation.git

