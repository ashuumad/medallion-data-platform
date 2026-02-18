# dagster/__init__.py
# Makes dagster/ a Python package
# Export defs so `dagster job execute -m dagster_pipeline` can find it
from dagster_pipeline.definitions import defs

__all__ = ["defs"]
