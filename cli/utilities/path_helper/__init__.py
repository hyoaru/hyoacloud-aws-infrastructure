from pathlib import Path


class PathHelper:
    @staticmethod
    def get_project_root() -> Path:
        current = Path(__file__).resolve()
        for parent in current.parents:
            if (parent / "pyproject.toml").exists():
                return parent
        return Path.cwd()
