import json
import logging
import os
import socket
import time

import boto3
from botocore.config import Config

logger = logging.getLogger()
logger.setLevel(logging.INFO)

cloudwatch = boto3.client(
    "cloudwatch",
    config=Config(
        connect_timeout=3,
        read_timeout=3,
        retries={"total_max_attempts": 2},
    ),
)

HOST = os.environ["DB_HOST"]
PORT = int(os.environ.get("DB_PORT", "5432"))
CENTRAL_DEPLOYMENT = os.environ["CENTRAL_DEPLOYMENT"]
TARGET_REGION = os.environ["TARGET_REGION"]


def handler(event, context):
    start = time.monotonic()
    success = 0

    try:
        with socket.create_connection((HOST, PORT), timeout=5):
            success = 1
    except OSError as exc:
        # Log the error class without credentials or event content.
        logger.warning("Connection failed: %s", type(exc).__name__)

    elapsed_ms = (time.monotonic() - start) * 1000

    dimensions = [
        {"Name": "CentralDeployment", "Value": CENTRAL_DEPLOYMENT},
        {"Name": "TargetRegion", "Value": TARGET_REGION},
    ]

    metrics = [
        {
            "MetricName": "ConnectionSuccess",
            "Dimensions": dimensions,
            "Value": success,
            "Unit": "Count",
        }
    ]

    if success:
        metrics.append(
            {
                "MetricName": "ConnectionLatency",
                "Dimensions": dimensions,
                "Value": elapsed_ms,
                "Unit": "Milliseconds",
            }
        )

    # Let publishing errors fail the invocation. The alarm's missing-data
    # policy can then detect that the probe stopped reporting.
    cloudwatch.put_metric_data(
        Namespace="Protex/Connectivity",
        MetricData=metrics,
    )

    logger.info(
        json.dumps(
            {
                "target_region": TARGET_REGION,
                "success": success,
                "elapsed_ms": round(elapsed_ms, 2),
            }
        )
    )

    return {"success": bool(success)}
