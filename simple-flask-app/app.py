import os
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)

APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")


@app.route("/", methods=["GET"])
def index():
    return jsonify(
        {
            "message": "Hello from Cesar's Labs!",
            "hostname": socket.gethostname(),
            "version": APP_VERSION,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    )


@app.route("/healthz", methods=["GET"])
def healthz():
    # Used by Kubernetes liveness/readiness probes
    return jsonify({"status": "ok"}), 200


@app.route("/api/info", methods=["GET"])
def info():
    return jsonify(
        {
            "app": "simple-flask-app",
            "env": os.environ.get("APP_ENV", "development"),
            "pod": os.environ.get("POD_NAME", "n/a"),
        }
    )


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
