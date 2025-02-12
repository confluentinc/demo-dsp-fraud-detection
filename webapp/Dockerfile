FROM python:3.12-slim

ENV PYTHONBUFFERED=1
ENV PYTHOONDONTWRITEBYTECODE=1
ENV PORT=8000

RUN useradd -u 1001 -m appuser
USER root
WORKDIR /opt/fraud_detection
ADD fraud_detection /opt/fraud_detection
RUN pip install --no-cache-dir -r /opt/fraud_detection/requirements.txt
#RUN python /opt/fraud_detection/manage.py collectstatic --no-input
RUN mkdir -p /opt/fraud_detection/staticfiles && \
    chown -R appuser:appuser /opt/fraud_detection/staticfiles

EXPOSE 8000

USER appuser

# CMD ["python", "/opt/fraud_detection/manage.py", "runserver"]