# 403bypass.sh

A bash script to test HTTP 403 Forbidden bypass techniques.

## Features
- Header bypass (X-Forwarded-For, X-Original-URL, etc.)
- Path bypass (/%2f, /./, /..;/, etc.)
- HTTP method bypass (POST, PUT, OPTIONS, etc.)
- Protocol bypass (HTTP vs HTTPS)

## Usage

```bash
chmod +x 403bypass.sh
./403bypass.sh https://target.com/path
```

## Output
- [HIT] = bypass worked (200, 201, 204, 401)
- [MISS] = still blocked

## Disclaimer
For authorized security testing only.
