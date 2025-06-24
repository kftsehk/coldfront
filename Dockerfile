FROM python:3.12

RUN pip3 install --upgrade pip uv "setuptools<81"

WORKDIR /usr/src/app
COPY pyproject.toml uv.lock MANIFEST.in README.md manage.py .
COPY coldfront/ coldfront/
RUN uv venv .venv \
    && uv pip install .

ENV VENV_PYTHON3=/usr/src/app/.venv/bin/python3
RUN ${VENV_PYTHON3} ./manage.py initial_setup -f \
    && ${VENV_PYTHON3} ./manage.py load_test_data

ENV DEBUG=True

EXPOSE 8000
CMD ["/usr/src/app/.venv/bin/python3", "./manage.py", "runserver", "0.0.0.0:8000"]
