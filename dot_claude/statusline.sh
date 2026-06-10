#!/bin/sh
input=$(cat)

BRANCH=$(git branch --show-current 2>/dev/null)
BRANCH=${BRANCH:--}
MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
EFFORT=$(echo "$input" | jq -r '.effort.level // ""')
CTX=$(echo "$input" | jq -r 'if (.context_window.used_percentage != null) then (.context_window.used_percentage | round | tostring) else "-" end')
FIVE_H=$(echo "$input" | jq -r 'if (.rate_limits.five_hour.used_percentage != null) then (.rate_limits.five_hour.used_percentage | round | tostring) else "-" end')
SEVEN_D=$(echo "$input" | jq -r 'if (.rate_limits.seven_day.used_percentage != null) then (.rate_limits.seven_day.used_percentage | round | tostring) else "-" end')

echo "${BRANCH} | [${MODEL}] ${EFFORT} | context:${CTX}% | 5h:${FIVE_H}% 7d:${SEVEN_D}%"
