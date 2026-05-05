FROM runpod/worker-comfyui:5.8.5-base

COPY custom-nodes.txt /opt/runpod/custom-nodes.txt
COPY install-custom-nodes.sh /opt/runpod/install-custom-nodes.sh
COPY start-with-volume-models.sh /opt/runpod/start-with-volume-models.sh

RUN chmod +x /opt/runpod/install-custom-nodes.sh /opt/runpod/start-with-volume-models.sh \
    && /opt/runpod/install-custom-nodes.sh

RUN python3 - <<'PY'
import pathlib
import runpod.serverless.utils.rp_upload as rp_upload

path = pathlib.Path(rp_upload.__file__)
text = path.read_text()
text = text.replace(
    'bucket = bucket_name if bucket_name else time.strftime("%m-%y")',
    'bucket = bucket_name or os.environ.get("BUCKET_NAME") or time.strftime("%m-%y")'
)
text = text.replace(
    'if not bucket_name:\n        bucket_name = time.strftime("%m-%y")',
    'if not bucket_name:\n        bucket_name = os.environ.get("BUCKET_NAME") or time.strftime("%m-%y")'
)
path.write_text(text)
print(f"Patched RunPod S3 bucket handling in {path}")
PY

CMD ["/opt/runpod/start-with-volume-models.sh"]
