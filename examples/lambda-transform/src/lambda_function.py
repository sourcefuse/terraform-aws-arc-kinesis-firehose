import base64
import json


def lambda_handler(event, context):
    """
    Firehose transformation handler.
    Receives a batch of records, decodes each, and returns them unchanged
    with status 'Ok'. Extend this function to enrich, filter, or transform
    records before they land in S3.
    """
    output = []

    for record in event.get("records", []):
        payload = base64.b64decode(record["data"])

        try:
            data = json.loads(payload)
        except (ValueError, TypeError):
            data = payload.decode("utf-8")

        # Re-encode (add a newline delimiter so S3 files are line-delimited JSON)
        transformed = json.dumps(data) + "\n"

        output.append({
            "recordId": record["recordId"],
            "result": "Ok",
            "data": base64.b64encode(transformed.encode("utf-8")).decode("utf-8"),
        })

    return {"records": output}
