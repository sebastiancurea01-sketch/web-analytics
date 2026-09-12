FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy just this one file in first, before anything else.
# Why: Docker caches each step. If only your dbt models change
# later (not your dependencies), Docker can skip reinstalling
# everything and reuse the cached install step. Faster rebuilds.
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["dbt", "--version"]