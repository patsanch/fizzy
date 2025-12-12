# SDOD Dev Notes

## General

`User`

```text
- login as david@37signals.com
- see verification code in terminal
```

```text
- login as jason (owner)
- set to staff to access admin/jobs
```

```bash
bin/rails runner 'Identity.find_by(email_address: "jason@37signals.com").update!(staff: true); puts "Updated jason@37signals.com to staff"'
```

`Email`

```text
- we're using mailgun
```

## Deploy Preps

`IP`
10.111.129.16

`Artifactory`

sdod-fizzy-docker-prod-local.artifactory.sie.sony.com

`Instance`

```bash
# Ubuntu
sudo apt-get update
sudo apt-get install -y docker.io git
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
# re-login for group to apply
```

`AWS`

```text
- set up cert
- create security groups
- set up target group
- set up balancer
- update route53
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

`Kamal Debug`

```bash
bundle exec kamal proxy logs -f
bundle exec kamal app logs -f
```

## Syncing git@github.com:basecamp/fizzy.git

In https://github.com/patsanch/fizzy, click on `Sync fork`.

PR `main` to `sdod`. Fix conflicts and create an integration branch `main-sdod-<x>`.

Deploy.

## Troubleshooting

### Broadcast Jobs Failing / Pin Card 500 Errors

**Problem**: Turbo Stream broadcast jobs failing in Mission Control, 500 errors when pinning cards, real-time updates not working.

**Root Cause**: Solid Cable (database-backed Action Cable) requires a `solid_cable_messages` table in the cable database, but it wasn't created during initial setup.

**Symptoms**:

- Broadcast jobs (`Turbo::Streams::BroadcastJob`) failing in `/admin/jobs`
- 500 errors on turbo frame loads (e.g., pinning cards)
- Real-time updates not broadcasting to other users
- Browser console errors: `Uncaught (in promise) Ot: The response (500) did not contain the expected <turbo-frame>`

**Fix in Development**:

```bash
# Install Solid Cable schema
bin/rails solid_cable:install

# Load the schema to create the table
bin/rails db:schema:load:cable

# Verify
bin/rails runner 'puts "Cable table exists: #{SolidCable::Message.table_exists?}"'
```

**Fix in Production**:

```bash
# Load cable schema (bypasses production safety check)
bundle exec kamal app exec --reuse 'bin/rails db:schema:load:cable DISABLE_DATABASE_ENVIRONMENT_CHECK=1'

# Verify
bundle exec kamal app exec --reuse 'bin/rails runner "puts \"Cable table exists: #{SolidCable::Message.table_exists?}\""'
```

**Also needed in production** (config/environments/production.rb):

```ruby
config.action_cable.url = "wss://fizzy.sdod.io/cable"
config.action_cable.allowed_request_origins = [ "https://fizzy.sdod.io", /https:\/\/fizzy\.sdod\.io.*/ ]
```

### Broken Images

```ruby
config.action_controller.default_url_options = { host: "fizzy.sdod.io", protocol: "https" }
```
