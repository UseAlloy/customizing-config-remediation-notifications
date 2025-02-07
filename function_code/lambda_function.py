import json
import boto3
from datetime import datetime, timedelta
import time
import os

def get_custom_query(ssm_client, event):
  document_name = event['detail']['requestParameters']['documentName']

  query_map_from_ps = ssm_client.get_parameter(Name=os.environ['SSM_MAPPING_PARAMETER_NAME'])
  query_map_from_ps_obj= json.loads(query_map_from_ps['Parameter']['Value'])

  custom_query_exists = document_name in list(query_map_from_ps_obj.keys())

  print("Document name", document_name, "in custom query map?:", custom_query_exists)

  return query_map_from_ps_obj[document_name] if custom_query_exists else None

def publish_to_sns(event, sns_client):
  topic_arn = os.environ["SNS_TOPIC_ARN"]

  print("Publishing event:", event, "to topic", topic_arn)
  response = sns_client.publish(
    TopicArn = topic_arn,
    Message = json.dumps(event)
  )
  return response

def create_cloudwatch_url(event):
  event_id = event['detail']['eventID']
  url = "https://"+event['region']+".console.aws.amazon.com/cloudtrailv2/home?region="+event['region']+"#/events/"+event_id

  return url

def execute_cloudwatch_query(event, ssm_client, logs_client, sns_client):
  query = get_custom_query(ssm_client, event)
  retries = 10
  num_results = 0
  log_group = os.environ["CLOUDTRAIL_LOG_GROUP_ARN"]

  print("The custom query is:", query)

  while retries > 0 and num_results == 0:
    print("Starting the retry #{} and num_results is {}".format(retries, num_results))
    response = None 

    start_query_response = logs_client.start_query(
      logGroupIdentifiers=[log_group],
      startTime=int((datetime.today() - timedelta(minutes=15)).timestamp()),
      endTime=int(datetime.now().timestamp()),
      queryString=query,  
    )

    query_id = start_query_response['queryId']
    time.sleep(10)

    while response == None or response['status'] == 'Running':
      print("Waiting for query to complete ...")
      time.sleep(20)
      response = logs_client.get_query_results(queryId=query_id)

    num_results = len(response['results'])
    retries -=1

  if num_results < 1:
    print("There are no results from Cloudwatch query after retries, not constructing an updated alert")

    return None

  else:
    print("There are", num_results, "results from Cloudwatch query")
    return response
    
def parse_cloudwatch_response_for_updated_resources(query_results):
  updated_resources = []
  result_items = query_results['results']

  for result in result_items:
    for field_item in result:
      if field_item['field'] == "resource":
        updated_resources.append(field_item['value'])
  return updated_resources 

def construct_original_notification(event):
    event_url = create_cloudwatch_url(event)
    new_event = {
      "version": "1.0",
      "source": "custom",
      "id": event["id"],
    }

    metadata = {
      "threadId" : event["id"]
    }

    new_event["metadata"] = metadata

    description_text= "<"+event_url+"|Original Cloudwatch Event>\n"

    content = {
      "title": "Config remediated a resource",
      "description": description_text,
    }

    new_event["content"] = content

    return new_event

def construct_custom_notification(resources_updated, event):
  events = []
  event_url = create_cloudwatch_url(event)

  for resource in resources_updated:

    new_event = {
      "version": "1.0",
      "source": "custom",
      "id": event["id"],
    }

    additional_context = {}

    for k, v in event["detail"].items():
      if isinstance(v ,str):
        additional_context[k] = v
      # docs here: https://docs.aws.amazon.com/chatbot/latest/adminguide/custom-notifs.html state this has to be a string for both keys and values  
      elif isinstance(v, bool): 
        additional_context[k] = str(v)  

    metadata = {
      "additionalContext" : additional_context,
      "threadId" : event["id"]
    }
    new_event["metadata"] = metadata

    description_text = '`'+resource+'`'+" updated by Config Remediation document `"+event['detail']['requestParameters']['documentName']+"` in region `"+event['region']+"`\n"
    description_text+= "<"+event_url+"|Original Cloudwatch Event>\n"
    description_text+="```"+str(additional_context)+"```"

    content = {
      "title": ":blob-sweat: Config remediated a resource",
      "description": description_text,
    }

    new_event["content"] = content

    events.append(new_event)

  return events

def lambda_handler(event, context):

  logs_client = boto3.client('logs', region_name='us-east-1') # we query the cloudTril log group, which only is in us-east-1
  sns_client = boto3.client('sns')
  ssm_client = boto3.client('ssm')

  print("Event:", event)
  print("Context:", context)

  document_that_has_custom_notifcation = get_custom_query(ssm_client, event)

  if not document_that_has_custom_notifcation:
    print("There is not a custom notification for the document", event['detail']['requestParameters']['documentName'])
    response = publish_to_sns(event, sns_client)
    print(response)

  else:  
    print("There is a custom notification for the document", event['detail']['requestParameters']['documentName'])

    original_message = construct_original_notification(event)
    print("Publishing original event to SNS")
    publish_to_sns(original_message, sns_client)

    query_results = execute_cloudwatch_query(event, ssm_client, logs_client, sns_client)

    if query_results:

      resources_updated = parse_cloudwatch_response_for_updated_resources(query_results)
      print("The following resources were updated:", resources_updated)

      custom_messages_to_send = construct_custom_notification(resources_updated, event)

      for custom_message in custom_messages_to_send:
        print("Publishing the custom message:", custom_message)
        response = publish_to_sns(custom_message, sns_client)
        print("The response from publishing custom event to SNS is:", response)

  return True