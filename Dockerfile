FROM python:3.10-slim

RUN addgroup -g 65532 noroot && \
    adduser -u 65532 -G noroot -s /bin/sh -D noroot

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT=5000
EXPOSE 5000

# Change to the non-root user
USER noroot

CMD ["sh", "-c", "gunicorn app.app:app --bind 0.0.0.0:${PORT}"]
