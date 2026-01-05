from pathlib import Path

from pydantic_settings import BaseSettings

from cli.utilities.path_helper import PathHelper


class Settings(BaseSettings):
    PROJECT_ROOT: Path = PathHelper.get_project_root()
    AWS_REGION: str = "ap-southeast-1"
