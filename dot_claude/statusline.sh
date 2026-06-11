#!/bin/sh
input=$(cat)

BRANCH=$(git branch --show-current 2>/dev/null)
BRANCH=${BRANCH:--}
MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
EFFORT=$(echo "$input" | jq -r '.effort.level // ""')
CTX=$(echo "$input" | jq -r 'if (.context_window.used_percentage != null) then (.context_window.used_percentage | round | tostring) else "-" end')
FIVE_H=$(echo "$input" | jq -r 'if (.rate_limits.five_hour.used_percentage != null) then (.rate_limits.five_hour.used_percentage | round | tostring) else "-" end')
SEVEN_D=$(echo "$input" | jq -r 'if (.rate_limits.seven_day.used_percentage != null) then (.rate_limits.seven_day.used_percentage | round | tostring) else "-" end')
FIVE_H_RESET_AT=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
SEVEN_D_RESET_AT=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

if [ -n "$FIVE_H_RESET_AT" ]; then
  FIVE_H_RESET=" (~$(date -d "@${FIVE_H_RESET_AT}" +"%m/%d %H:%M"))"
else
  FIVE_H_RESET=""
fi
if [ -n "$SEVEN_D_RESET_AT" ]; then
  SEVEN_D_RESET=" (~$(date -d "@${SEVEN_D_RESET_AT}" +"%m/%d %H:%M"))"
else
  SEVEN_D_RESET=""
fi

echo "${BRANCH} | [${MODEL}] ${EFFORT} | context:${CTX}% | 5h:${FIVE_H}%${FIVE_H_RESET} 7d:${SEVEN_D}%${SEVEN_D_RESET}"
