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
flutter run --dart-define=API_BASE_URL=http://<backend-ip>:8000
```

The production default API is `https://fp-ai-production.up.railway.app`.
The API URL can also be changed in Settings. For local development, override
it with `--dart-define=API_BASE_URL=http://<backend-ip>:8000`.

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

Verify the container with `curl http://localhost:8000/health`. The image runs CPU inference and includes `best.pt`. The production backend is `https://fp-ai-production.up.railway.app`; verify `https://fp-ai-production.up.railway.app/health` before use. Railway output images are temporary; Flutter History stores a local copy. Local development can still use the `--dart-define` override or the Settings URL override.

## API

`GET /health` returns `{"status":"ok","service":"VastuAI"}`.

`POST /upload-rotated` accepts multipart fields:

- Required: `file`
- Rules: `rule_set_name`, `rules` (JSON object of direction arrays)
- Advanced: `confidence_threshold` (`0.10`–`0.90`), `show_bounding_boxes`

```json
{
  "image_url": "/outputs/...",
  "vastu_report": [{"label": "bed", "direction": "SE", "vastu_ok": false, "confidence": 0.87, "rule_applied": true}],
  "rule_set_name": "Vastu Presets"
}
```

Older responses may omit `confidence` or `rule_applied`; Flutter handles both for compatibility. When `rule_applied` is `false`, the label is not covered by the active rule map. `vastu_ok` remains present for API compatibility, while Flutter presents the item as neutral/not evaluated rather than as a failure.

## Custom Rule Behavior

`Vastu Presets` uses built-in backend rules. Every other rule set is a complete independent map; unspecified labels do not inherit preset rules. Flutter sends the active rules with each analysis.

## Advanced Settings

Confidence ranges from `0.10` to `0.90`, defaults to `0.25`, confidence display defaults off, and bounding boxes default on. Settings persist locally.

## Orientation

The top of the prepared image is treated as North. Rotate the floor plan until North faces up.

## Analysis History

History metadata and annotated images are stored locally by Flutter. The newest 25 analyses are retained. Saved results reopen without backend access.

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
