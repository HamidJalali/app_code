FROM python:3.12-slim

ARG APP_USER=appuser
ARG APP_HOME=/home/appuser

ENV HOME="${APP_HOME}" \
    PATH="${APP_HOME}/.local/bin:${PATH}"

RUN useradd \
    --create-home \
    --home-dir "${APP_HOME}" \
    --shell /usr/sbin/nologin \
    "${APP_USER}"

WORKDIR /app

USER ${APP_USER}

COPY requirements.txt .

RUN python -m pip install --no-cache-dir --user -r requirements.txt

COPY app.py .

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
