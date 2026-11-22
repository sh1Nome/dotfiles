import json
from pathlib import Path
from stat import S_IMODE
from tempfile import NamedTemporaryFile


def install_hooks(source, target):
    personal = json.loads(source.read_text(encoding="utf-8"))["hooks"]["SessionStart"][0]
    command = personal["hooks"][0]["command"]

    try:
        with target.open(encoding="utf-8") as existing:
            settings = json.load(existing)
            mode = S_IMODE(target.stat().st_mode)
    except FileNotFoundError:
        settings = {}
        mode = 0o644

    if not isinstance(settings, dict) or not isinstance(settings.setdefault("hooks", {}), dict):
        raise ValueError(f"{target}: expected a hooks object")
    groups = settings["hooks"].setdefault("SessionStart", [])
    if not isinstance(groups, list) or any(
        not isinstance(group, dict)
        or not isinstance(group.get("hooks"), list)
        or any(not isinstance(handler, dict) for handler in group["hooks"])
        for group in groups
    ):
        raise ValueError(f"{target}: expected SessionStart hook groups")

    for index, group in enumerate(groups):
        handlers = group["hooks"]
        if len(handlers) == 1 and handlers[0].get("command") == command:
            if group == personal:
                return
            groups[index] = personal
            break
    else:
        groups.append(personal)

    target.parent.mkdir(parents=True, exist_ok=True)
    with NamedTemporaryFile(
        mode="w", encoding="utf-8", dir=target.parent, delete=False
    ) as output:
        temporary = Path(output.name)
        try:
            json.dump(settings, output, ensure_ascii=False, indent=2)
            output.write("\n")
            output.close()
            temporary.chmod(mode)
            temporary.replace(target)
        finally:
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    install_hooks(Path(__file__).with_name("hooks.json"), Path("/etc/codex/hooks.json"))
