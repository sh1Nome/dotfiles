import json
from pathlib import Path

instructions = Path(__file__).with_name("AGENTS.md").read_text(encoding="utf-8")
print(
    json.dumps(
        {
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": instructions,
            }
        }
    )
)
