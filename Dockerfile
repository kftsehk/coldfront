FROM python:3.12

RUN apt-get update && apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip uv "setuptools<81"

WORKDIR /usr/src/app
COPY pyproject.toml uv.lock MANIFEST.in README.md manage.py .
COPY coldfront/ coldfront/
COPY theme/ theme/
RUN uv venv .venv \
    && uv pip install .

ENV VENV_PYTHON3=/usr/src/app/.venv/bin/python3
RUN ${VENV_PYTHON3} ./manage.py tailwind install \
    && ${VENV_PYTHON3} ./manage.py tailwind build \
    && ${VENV_PYTHON3} ./manage.py initial_setup -f \
    && ${VENV_PYTHON3} ./manage.py load_test_data

ENV DEBUG=True

EXPOSE 8000
CMD ["/usr/src/app/.venv/bin/python3", "./manage.py", "runserver", "0.0.0.0:8000"]
