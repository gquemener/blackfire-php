#!/bin/sh

blackfire-agent --server-id="${BLACKFIRE_AGENT_SERVER_ID}" --server-token="${BLACKFIRE_AGENT_SERVER_TOKEN}" --log-level=4 --log-file="stderr"

/etc/init.d/blackfire-agent restart

exec "$@"
