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

```bash
# let's sync from basecamp and push to our origin
git checkout main
git pull basecamp main
git push origin main

# let's create the integration branch
git checkout sdod
git pull origin sdod
git checkout -b main-sdod-<x>
git merge main
git push origin main-sdod-<x>

# let's update sdod branch
git checkout sdod
git merge main-sdod-<x>
git push origin sdod
```

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

### Bundler issues with ruby 4.0.9

`rvm install 4.0.9` fails with "Unknown ruby interpreter version"? rvm is outdated:

```bash
rvm get head && rvm reload
rvm install 4.0.9
```

`openssl` gem fails to build (`ASN1_BIT_STRING_set1` errors)? Homebrew's OpenSSL 4 is
picked up; build against OpenSSL 3 instead:

```bash
bundle config set --local build.openssl --with-openssl-dir=$(brew --prefix openssl@3)
bundle install
```

**Gemfile.lock conflicts: never regenerate from scratch.** Rails is tracked from
`github: "rails/rails", branch: "main"`, so re-resolving the lockfile floats Rails to the
branch tip. A newer Rails broke `config/initializers/uuid_primary_keys.rb`
(`SystemStackError: stack level too deep` during `db:prepare`), which made the new container
exit and Kamal report "target failed to become healthy". Instead, restore the lockfile
from `main` and let Bundler only add what's missing:

```bash
git show main:Gemfile.lock > Gemfile.lock
bundle install            # not `bundle update`
grep -A1 'rails/rails.git' Gemfile.lock   # revision should match main's
```

Run the tests before deploying.

**Debugging a failed deploy:** the old container keeps serving. Find the crashed one with
`bundle exec kamal app containers`, then read its log on the host:
`docker logs <container-id> 2>&1 | grep -n -A3 "aborted!"`.
