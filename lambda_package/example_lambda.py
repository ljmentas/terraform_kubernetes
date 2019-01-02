#!python
import boto3
import botocore
from botocore.vendored import requests
import redis
import json


redis_client = redis.Redis(host='cluster-demo.gthbrr.0001.use1.cache.amazonaws.com', port=6379, db=0)
sqs = boto3.client('sqs',"us-east-1")
queue = sqs.get_queue_url(QueueName='terraform-example-queue')


def process_webpage(url, words):

    response =requests.get(url)
    #r = requests.get(url, allow_redirects=False)
    #soup = BeautifulSoup(r.content, 'lxml')
    response_body = []
    for word in words:
        word_count = response.text.count(word)
        response_body.append({'word': word, 'count': word_count})
    return response_body

# Main function. Entrypoint for Lambda
def handler(event, context):

    for message in event.Records:
        message_dict = json.loads(message["body"])
        result = process_webpage(message_dict['url'], message_dict['words'])
        saved = redis_client.set(message["messageId"], json.dumps(result))
    return true


# Manual invocation of the script (only used for testing)
if __name__ == "__main__":
    # Test data
    test = {}
    # Test function
    handler(test, None)
