# SDOD Dev Notes

## Default Account

```text
- login as david@37signals.com
- see verification code in terminal
```

## Instance Setup

```bash
# Ubuntu
sudo apt-get update
sudo apt-get install -y docker.io git
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
# re-login for group to apply
```

## Deploy

`Kamal Commands`

```bash
# https://kamal-deploy.org/docs/commands/view-all-commands/
# https://kamal-deploy.org/docs/commands/build/

# Build Docker image from current codebase and push to registry (no deployment)
bundle exec kamal build push

# Full deployment: build + push + deploy (complete cycle for initial or major deployments)
bundle exec kamal deploy

# Fast redeployment: assumes image already exists, skips build/push (quick updates)
bundle exec kamal redeploy
```
