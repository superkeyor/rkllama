# -h/--help
# Usage: docker build -t rkllama-nocache -f Dockerfile .
# Purpose: Rebuilds ghcr.io/notpunchnox/rkllama:main with prompt-cache
#          writing disabled at the source level. RKLLAMA has no config
#          flag to turn off cache writes (only a retention/cleanup
#          setting), so this patches the vendored rkllm.py directly:
#          save_prompt_cache is forced to 0 instead of 1, meaning the
#          NPU inference call is told never to persist a cache file.
#          Cache *loading* is left untouched - on a cache miss it will
#          still log the existing "Not found expected prompt cache
#          file" warning, which is expected and harmless.
# Example: docker build -t rkllama-nocache -f Dockerfile .
#          then reference "image: rkllama-nocache" in docker-compose.yml

# as of 9/6/2026, sha256:683e6a15263a167af380d5fdc5bdfa061755bcdacbff7be2cb7194f3d3bdcf70
FROM ghcr.io/notpunchnox/rkllama:main

# Disable prompt cache writing: force save_prompt_cache = 0 instead of 1.
# Matched by exact text so the build fails loudly (via the final grep
# check) if the upstream image changes this line, rather than silently
# doing nothing.
RUN set -eu; \
    FILE=/opt/venv/lib/python3.12/site-packages/rkllama/api/rkllm.py; \
    grep -q "self.prompt_cache_params.save_prompt_cache = 1" "$FILE"; \
    sed -i 's/self\.prompt_cache_params\.save_prompt_cache = 1/self.prompt_cache_params.save_prompt_cache = 0/' "$FILE"; \
    grep -q "self.prompt_cache_params.save_prompt_cache = 0" "$FILE"
