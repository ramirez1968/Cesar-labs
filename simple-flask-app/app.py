import os
import requests
from flask import Flask, render_template, jsonify

app = Flask(__name__)

APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")
MEME_API_URL = "https://meme-api.com/gimme"


def get_meme(subreddit=None):
    """Fetch a random meme from the meme-api (pulls from Reddit)."""
    url = f"{MEME_API_URL}/{subreddit}" if subreddit else MEME_API_URL
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        data = response.json()
        return {
            "title": data.get("title", "Untitled"),
            "image_url": data.get("url"),
            "subreddit": data.get("subreddit", "unknown"),
            "post_link": data.get("postLink", "#"),
        }
    except requests.RequestException:
        return {
            "title": "Couldn't fetch a meme right now",
            "image_url": None,
            "subreddit": "n/a",
            "post_link": "#",
        }


@app.route("/", methods=["GET"])
def index():
    meme = get_meme()
    return render_template("index.html", meme=meme, version=APP_VERSION)


@app.route("/healthz", methods=["GET"])
def healthz():
    # Used by Kubernetes liveness/readiness probes
    return jsonify({"status": "ok"}), 200


@app.route("/api/meme", methods=["GET"])
def api_meme():
    # JSON version, handy for testing without loading the HTML page
    return jsonify(get_meme())


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)