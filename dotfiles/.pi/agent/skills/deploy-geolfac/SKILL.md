---
name: deploy-geolfac
description: Deploy the geolfac Django project (fac.moscow) to production. Use whenever the user mentions deploying, pushing to prod, releasing, or updating the live site.
---

## Environment

- **Server:** `ssh -p 2222 denis@95.165.87.62`
- **Project dir:** `/var/www/geolfac`
- **App user:** `geolfac` — all project commands must use `sudo -u geolfac`
- **Venv:** `/var/www/geolfac/.venv`
- **Service:** `geolfac.service` (gunicorn → unix socket → nginx)
- **Site:** `https://fac.moscow`
- **Git remote:** `git@github.com:DenisSud/geolfac.git`, branch `main`
- **Env file:** `/var/www/geolfac/.env` (not in git, already on server)

## Steps

1. **Pull latest code:**
   ```bash
   ssh -t -p 2222 denis@95.165.87.62 "cd /var/www/geolfac && sudo -u geolfac git pull"
   ```
   Use `-t` to allocate a terminal (needed for SSH key passphrase). All git writes require `sudo -u geolfac` because `.git/` is owned by `geolfac`.

2. **Install/upgrade dependencies:**
   ```bash
   ssh -p 2222 denis@95.165.87.62 "cd /var/www/geolfac && sudo -u geolfac /usr/local/bin/uv pip install -r requirements.txt --python .venv/bin/python"
   ```
   The project uses `requirements.txt` (no `pyproject.toml`), so `uv pip install` not `uv sync`.

3. **Run migrations** (if models changed — check with `showmigrations` first):
   ```bash
   ssh -p 2222 denis@95.165.87.62 "cd /var/www/geolfac && sudo -u geolfac .venv/bin/python manage.py showmigrations timetable"
   ssh -p 2222 denis@95.165.87.62 "cd /var/www/geolfac && sudo -u geolfac .venv/bin/python manage.py migrate"
   ```

4. **Collect static files** (if templates/CSS/JS/static changed):
   ```bash
   ssh -p 2222 denis@95.165.87.62 "cd /var/www/geolfac && sudo -u geolfac .venv/bin/python manage.py collectstatic --noinput"
   ```

5. **Restart the service:**
   ```bash
   ssh -p 2222 denis@95.165.87.62 "sudo systemctl restart geolfac"
   ```

## Validation

After deploying, confirm the site is up:
```bash
ssh -p 2222 denis@95.165.87.62 "curl -s -o /dev/null -w '%{http_code}' https://fac.moscow"
```
Expect `200`. Also check the service:
```bash
ssh -p 2222 denis@95.165.87.62 "systemctl status geolfac --no-pager"
```