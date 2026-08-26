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

Install the tracked hosts as an included fragment so existing SSH hosts remain intact:

```sh
mkdir -p ~/.ssh
mkdir -p ~/.ssh/config.d
cp .config/ssh/config ~/.ssh/config.d/dotfiles.conf
grep -Fqx 'Include ~/.ssh/config.d/*.conf' ~/.ssh/config 2>/dev/null || \
  printf '\nInclude ~/.ssh/config.d/*.conf\n' >> ~/.ssh/config
chmod 700 ~/.ssh
chmod 700 ~/.ssh/config.d
chmod 600 ~/.ssh/config ~/.ssh/config.d/dotfiles.conf
```

Generate the referenced keys locally. Never commit private keys or machine-specific secrets to this repository.
