#!/bin/bash

if [ -f .env ]; then
    . .env
else
	echo 'Missing .env file. Copy .env.example to .env and fill in the values.'
	exit 1
fi
export notionVersion="2022-02-22"
export today=$(date +%Y-%m-%d)

output=$(curl --output - --fail --silent --show-error --location --globoff "https://api.notion.com/v1/databases/$databaseId/query" \
--header "Authorization: Bearer $token" \
--header 'Content-Type: application/json' \
--header "Notion-Version: $notionVersion" \
--data '{
    "filter": {
        "and": [
            {
                "property": "Status",
                "status": {
                    "equals": "Not started"
                }
            },
            {
                "property": "Due",
                "date": {
                    "on_or_before": "'${today}'"
                }
            }
        ]
    },
    "sorts": [
        {
            "property": "Due",
            "direction": "ascending"
        }
    ]
}')

#JSON output
#echo $output | jq '.results[] | {title: .properties.Task.title[].text.content, due: .properties.Due.date.start, status: .properties.Status.status.name, url: .url}' | jq -s

echo $output | jq '.results[] | {Title: .properties.Task.title[].text.content, Due: .properties.Due.date.start, Status: .properties.Status.status.name, Url: .url}'  | jq -s | jq -r '(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @tsv' | column -ts$'\t'