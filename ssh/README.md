# SSH

SSH client configuration.

## Local key layout

Keys are generated locally and are **not tracked by Git**.

```text
~/.ssh/
├── github/
│   ├── auth/
│   │   ├── key
│   │   └── key.pub
│   └── sign/
│       ├── key
│       └── key.pub
└── aur/
    ├── auth
    └── auth.pub
```

Copy the tracked client configuration manually:

```sh
mkdir -p ~/.ssh
cp ssh/config ~/.ssh/config
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
```

Generate the referenced keys locally. Never commit private keys or machine-specific secrets to this repository.
