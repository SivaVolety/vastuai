# VastuAI

VastuAI is an AI-assisted Flutter app for analyzing floor-plan images with configurable Vastu rules.

## Features

- Camera/gallery input, pan, zoom, 30° rotation, alignment cross, and 640×640 preprocessing
- North-up guidance and YOLO object detection
- Direction-based Vastu evaluation with built-in or independent custom rule sets
- Configurable FastAPI URL, health check, confidence threshold, confidence display, and bounding-box display
- Local History with offline reopening, deletion, clear-all, and newest-25 retention

## Architecture

```text
Flutter Client → FastAPI Backend → Ultralytics YOLO → Direction Calculation
             → Selected Vastu Rule Evaluation → Annotated Image + Report
```

Flutter stores History metadata and annotated images locally. The backend is a separate project at `/Users/sivavolety/projects/fp-ai`.

## Repository Structure

Flutter: `lib/pages/` (screens), `lib/services/` (API and History), `lib/providers/` (state), `lib/models/` (data models), `lib/widgets/` (shared UI), and `test/` (unit tests).

Backend:

- `/Users/sivavolety/projects/fp-ai/main.py`: FastAPI routes and YOLO loading
- `/Users/sivavolety/projects/fp-ai/business.py`: annotation, direction calculation, and Vastu evaluation
- `/Users/sivavolety/projects/fp-ai/best.pt`: YOLO weights

## Requirements

The verified backend `.penv` uses Python 3.9.12, FastAPI 0.115.14, Ultralytics 8.3.162, PyTorch 2.2.2, torchvision 0.17.2, NumPy 1.26.4, Pillow/OpenCV, and python-multipart 0.0.20. See `fp-ai/requirements.txt` for pins.

Flutter dependencies are in `pubspec.yaml` and target Dart `^3.2.3`.

## Flutter Setup

```bash
flutter pub get
flutter run --dart-define=VASTUAI_API_BASE_URL=http://<backend-ip>:8000
```

The production build selects its API with `VASTUAI_API_BASE_URL`. Without a define,
the local fallback is `http://localhost:8000`. For Android emulators use
`http://10.0.2.2:8000`; for physical phones use your development server's LAN IP.
The older `API_BASE_URL` define remains a fallback for existing mobile scripts.
A saved Settings URL overrides the build default; use **Reset to Default** to
clear it. This also clears any previously saved Railway URL.

## Backend Setup

Current checkout:

```bash
cd /Users/sivavolety/projects/fp-ai
./.penv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
```

Generic equivalent:

```bash
cd /path/to/fp-ai
python -m venv .penv
./.penv/bin/pip install -r requirements.txt
./.penv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
```

Use `.penv`; the older `venv/` is incompatible. Do not commit virtual environments.

### Container deployment

From the backend project directory:

```bash
docker build -t vastuai-backend .
docker run --rm -p 8000:8000 -e PORT=8000 vastuai-backend
```

Verify the container with `curl http://localhost:8000/health`. The image runs CPU inference and includes stable `best.pt` and experimental `best_v2.pt`. The intended production backend is `https://api.vastuai.com`; configure its hosting and HTTPS separately. Backend output images are temporary; mobile Flutter History stores a local copy. Local development can still use the `--dart-define` override or the Settings URL override.

## API

`GET /health` returns `{"status":"ok","service":"VastuAI","models":["v1","v2"]}`.

`POST /upload-rotated` accepts multipart fields:

- Required: `file`
- Detector: `model_version` (`v1` by default, or experimental `v2`)
- Rules: `rule_set_name`, `rules` (JSON object of direction arrays)
- Advanced: `confidence_threshold` (`0.10`–`0.90`), `show_bounding_boxes`

```json
{
  "image_url": "/outputs/...",
  "vastu_report": [{"label": "bed", "direction": "SE", "vastu_ok": false, "confidence": 0.87, "rule_applied": true}],
  "rule_set_name": "Vastu Presets",
  "model_version": "v1"
}
```

Older responses may omit `model_version` (displayed as model not reported), `confidence`, or `rule_applied`; Flutter handles both for compatibility. When `rule_applied` is `false`, the label is not covered by the active rule map. `vastu_ok` remains present for API compatibility, while Flutter presents the item as neutral/not evaluated rather than as a failure.

## Custom Rule Behavior

`Vastu Presets` uses built-in backend rules. Every other rule set is a complete independent map; unspecified labels do not inherit preset rules. Flutter sends the active rules with each analysis.

## Advanced Settings

Confidence ranges from `0.10` to `0.90`, defaults to `0.25`, confidence display defaults off, and bounding boxes default on. Settings persist locally.

## Orientation

The top of the prepared image is treated as North. Rotate the floor plan until North faces up.

## Analysis History

On mobile, History metadata, model version when reported, and annotated images are stored locally by Flutter. The newest 25 analyses are retained. Saved results reopen without backend access. Legacy records without model metadata still open. Web analyses are not saved; the History page explains this limitation and never accesses mobile filesystem APIs.

## Testing

```bash
flutter analyze
flutter test
cd /Users/sivavolety/projects/fp-ai
PYTHONPATH=. ./.penv/bin/python -m pytest
```

The verified backend suite contains six focused tests; the Flutter suite contains four unit tests.

## Known Limitations

- YOLO detects only classes represented in its training data.
- Orientation must currently be set manually to North-up.
- Backend deployment is developer-managed; History is device-local.
- There is no authentication, cloud sync, export, or sharing.
- AI detections and Vastu evaluations can be incorrect.

## Disclaimer

VastuAI provides AI-assisted analysis and is not guaranteed architectural, engineering, or professional Vastu advice. Verify important decisions independently.

## Detector Models

The Home screen shows a compact **Detection model** selector next to the rule
selection controls. **Stable V1 — Recommended** is selected on each app start.
**Experimental V2 — Research Beta** is optional, with a warning that rare classes
may be less accurate. Selection survives navigation within the app session but
is not saved across a restart or browser refresh. Each upload sends
`model_version=v1` or `model_version=v2` alongside all existing fields. Results
and new mobile History records use the backend's reported model version; an
older backend that omits it is shown as **Not reported by backend**.

V2 is an experimental 9-class research model for `bed`, `dining_table`,
`main_entrance`, `stairs`, `stove`, `sink`, `toilet`, `tub`, and `kitchen_bar`.
It is still being evaluated and is not known to be more accurate overall.
Uncovered labels remain not evaluated by the selected rules.

## Flutter Web Production Deployment

Frontend: **https://vastuai.com** (optionally **https://www.vastuai.com**).
Backend: **https://api.vastuai.com**, hosted independently from this app.
No Railway service is required.

From a checkout of this branch, using Flutter stable (validated with Flutter 3.44.2 / Dart 3.12.2):

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --dart-define=VASTUAI_API_BASE_URL=https://api.vastuai.com
```

Upload **only `build/web/`** to an HTTPS static host. Do not publish this repository's
root, local datasets, notebooks, model weights, or user files. Configure a GitHub
build on the intended branch with the command above and publish directory
`build/web`. The Dart define is compiled into the bundle; changing a host's runtime
environment does not change the API URL. Rebuild to change it. This public URL
is configuration, not a secret.

The app uses Flutter's default hash routing (`/#/help`, `/#/history`), so route
fragments do not need server rewrites. Serve `/` as `index.html`. If path-based
routing is introduced later, add a SPA fallback for navigation URLs to
`index.html`, while serving real assets normally. Keep `index.html` and bootstrap
files revalidated across releases so clients receive new configuration. Serve
all generated JavaScript, fonts, assets, and CanvasKit files with correct MIME
types. Deploy at the domain root (default base href `/`).

Configure backend CORS to allow exactly `https://vastuai.com` and
`https://www.vastuai.com`; allow multipart POST/OPTIONS and image GET requests.
Route `/upload-rotated`, `/health`, and `/outputs/` to the backend. HTTPS frontend
pages must use an HTTPS API to avoid mixed-content blocking. Results resolve
relative `image_url` values against the configured backend URL. Existing Settings
overrides persist per browser/device: reset them when verifying a new build.

For local browser development:

```bash
flutter run -d chrome --web-port 7357 \
  --dart-define=VASTUAI_API_BASE_URL=http://localhost:8000
```

Allow `http://localhost:7357` in local backend CORS. Web uploads use the browser's
file chooser, `XFile.readAsBytes`, and an in-memory multipart upload. Mobile keeps
Camera/Gallery options and filesystem-backed History; browser History is not
persisted. Review web results before navigating away or refreshing.

After deploying, use Settings → Test Connection and analyze a sample plan with
both models. This preparation does not deploy the frontend/backend or configure DNS.
