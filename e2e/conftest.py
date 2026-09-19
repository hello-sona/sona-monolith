import os
import socket
import subprocess
import time
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
FRONTEND_URL = os.environ.get("E2E_FRONTEND_URL") or "http://127.0.0.1:5173"
BACKEND_URL = os.environ.get("E2E_BACKEND_URL") or "http://127.0.0.1:8000"


def _port_open(host: str, port: int) -> bool:
    with socket.socket() as sock:
        sock.settimeout(0.25)
        return sock.connect_ex((host, port)) == 0


def _wait_for_port(host: str, port: int, timeout: float = 60) -> None:
    deadline = time.time() + timeout
    while time.time() < deadline:
        if _port_open(host, port):
            return
        time.sleep(0.2)
    raise RuntimeError(f"Timed out waiting for {host}:{port}")


@pytest.fixture(scope="session")
def frontend_url():
    return FRONTEND_URL


@pytest.fixture(scope="session")
def backend_url():
    return BACKEND_URL


@pytest.fixture(scope="session", autouse=True)
def stack():
    procs = []
    backend_env = os.environ.copy()
    backend_env.setdefault("DB_ENGINE", "sqlite")
    backend_env.setdefault("DJANGO_SECRET_KEY", "insecure-e2e-secret-key")

    if not _port_open("127.0.0.1", 8000):
        subprocess.check_call(
            ["uv", "run", "python", "manage.py", "migrate", "--noinput"],
            cwd=ROOT / "backend",
            env=backend_env,
        )
        procs.append(
            subprocess.Popen(
                ["uv", "run", "python", "manage.py", "runserver", "8000", "--noreload"],
                cwd=ROOT / "backend",
                env=backend_env,
            )
        )
    if not _port_open("127.0.0.1", 5173):
        procs.append(
            subprocess.Popen(
                ["npm", "run", "dev", "--", "--host", "127.0.0.1", "--port", "5173"],
                cwd=ROOT / "frontend",
            )
        )

    try:
        _wait_for_port("127.0.0.1", 8000)
        _wait_for_port("127.0.0.1", 5173)
        yield
    finally:
        for proc in procs:
            proc.terminate()
            proc.wait(timeout=5)
