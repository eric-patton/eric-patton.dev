# Hosting: the Mac Mini and the Cloudflare Tunnel

The site runs on the same machine and the same tunnel as the RequestDesk demo. Nothing is
exposed to the internet by a port forward; the only route in is the tunnel, which dials out.

```
             Cloudflare edge
                    |
        eric-patton.dev  |  requestdesk.eric-patton.dev
                    |
            cloudflared (launch agent, tunnel "requestdesk")
                    |
   localhost:8086   |   localhost:8085
        |                       |
   eric-patton-dev        requestdesk-web
   (nginx, static)        (nginx -> api -> postgres)
```

Both stacks run under Colima's Docker on the Mac Mini, which is registered with
`brew services start colima` so it comes back after a reboot. The Mac auto-logs in, which is
what lets a *user* launch agent start `cloudflared` without anybody typing a password.

## Ports on that machine

| Port | What holds it |
|---|---|
| 8085 | RequestDesk front end |
| 8086 | This site |

Both bind to `127.0.0.1` only. The API and database ports are not published at all.

## First-time setup

```bash
ssh macmini
git clone https://github.com/eric-patton/eric-patton.dev.git ~/eric-patton.dev
cd ~/eric-patton.dev
docker compose up -d --build
curl -sI http://127.0.0.1:8086/health
```

Then add the hostname to the tunnel. The ingress list is order-sensitive and the catch-all
`http_status: 404` rule has to stay last:

```yaml
# ~/.cloudflared/config.yml
tunnel: 48b1f522-763d-46db-968b-c891bbcea401
credentials-file: /Users/eric/.cloudflared/48b1f522-763d-46db-968b-c891bbcea401.json

ingress:
  - hostname: requestdesk.eric-patton.dev
    service: http://localhost:8085
  - hostname: eric-patton.dev
    service: http://localhost:8086
  - hostname: www.eric-patton.dev
    service: http://localhost:8086
  - service: http_status:404
```

Point DNS at the tunnel once per hostname, then restart the agent:

```bash
cloudflared tunnel route dns requestdesk eric-patton.dev
cloudflared tunnel route dns requestdesk www.eric-patton.dev
launchctl kickstart -k gui/$(id -u)/com.cloudflare.cloudflared
```

## Updating the site

```bash
ssh macmini "cd ~/eric-patton.dev && git pull && docker compose up -d --build"
```

## When it is down

In order of likelihood:

1. **The Mac is asleep or off.** Everything else is downstream of this.
2. **Colima is not running.** `colima status`, then `brew services start colima`.
3. **The container is unhealthy.** `docker compose ps`, then `docker compose logs web`.
4. **The tunnel agent died.** `launchctl print gui/$(id -u)/com.cloudflare.cloudflared`, then
   `launchctl kickstart -k gui/$(id -u)/com.cloudflare.cloudflared`.

The agent's plist has to invoke `cloudflared tunnel --config <path> run`. Both
`brew services start cloudflared` and `cloudflared service install` produce an agent that runs
the binary without those arguments, which exits immediately and looks like a crash loop.

## Health check

Once a month, load <https://eric-patton.dev> and <https://requestdesk.eric-patton.dev>. That is
the whole monitoring story, and it is proportionate: this is a portfolio, not an SLA.
