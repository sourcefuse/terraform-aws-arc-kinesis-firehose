import base64
import json


def lambda_handler(event, context):
    """
    Firehose transformation handler.
    Decodes each record, adds a newline delimiter, and returns it unchanged.
    Extend this to enrich or filter records before they reach OpenSearch.
    """
    output = []

    for record in event.get("records", []):
        payload = base64.b64decode(record["data"])

        try:
            data = json.loads(payload)
        except (ValueError, TypeError):
            data = payload.decode("utf-8")

        transformed = json.dumps(data) + "\n"

        output.append({
            "recordId": record["recordId"],
            "result": "Ok",
            "data": base64.b64encode(transformed.encode("utf-8")).decode("utf-8"),
        })

    return {"records": output}
