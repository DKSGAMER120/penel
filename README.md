
# DKS Pterodactyl Setup

Scripts for setting up Pterodactyl Panel and Wings
on a compatible Ubuntu server.

## Requirements

- Ubuntu 24.04 LTS
- Root or sudo access
- A supported server architecture
- Domain name recommended for HTTPS
- Sufficient RAM, CPU and disk space

## Panel Installation

1. Review `install-panel.sh` before running it.
2. Upload or clone this repository on your Ubuntu server.
3. Run:

```bash
chmod +x install-panel.sh
sudo ./install-panel.sh
```

4. Follow the installer prompts.
5. Install Wings separately after verifying the Panel.

## Security

- Never commit passwords, API keys or tokens.
- Use HTTPS for public access.
- Verify scripts before running them as root.
- Cloud providers may charge for resources outside
  their free-tier limits.

## Status

- [x] Panel installer launcher created
- [ ] Panel installation tested
- [ ] Wings setup
- [ ] Minecraft server configuration
