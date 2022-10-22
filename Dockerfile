FROM python:3.10-slim-bullseye as base

ENV \
    PYTHONFAULTHANDLER=1 \
	PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
	POETRY_VIRTUALENVS_CREATE=false \
    POETRY_HOME=/opt/poetry \
    POETRY_VERSION=1.2.2 \
    MATPLOTLIBRC=/app/styles/matplotlibrc

RUN apt-get update && apt-get -y upgrade \
	&& rm -rf /var/lib/apt/lists/*

FROM base as poetry

ENV PATH="$POETRY_HOME/bin:$PATH"
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		curl \
	&& rm -rf /var/lib/apt/lists/* \
	&& curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/install-poetry.py | python

WORKDIR /app

FROM poetry as dev

WORKDIR /app
COPY poetry.lock pyproject.toml ./

RUN echo "user:x:1000:1000:nobody:/app:/bin/bash" >> /etc/passwd

RUN --mount=type=cache,target=/root/.cache \
	poetry install