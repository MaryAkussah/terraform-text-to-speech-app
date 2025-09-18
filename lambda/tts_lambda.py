import json
import boto3
import os
import uuid
import traceback

def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event)}")
    
    try:
        # Parse the request body
        if 'body' in event:
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        else:
            body = event
        
        print(f"Parsed body: {body}")
        
        text = body.get('text', '').strip()
        voice_id = body.get('voiceId', 'Joanna')
        
        print(f"Text: '{text}', Voice: {voice_id}")
        
        # Validate input
        if not text:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': '*',
                    'Access-Control-Allow-Methods': '*'
                },
                'body': json.dumps({'error': 'Text is required'})
            }
        
        if len(text) > 3000:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': '*',
                    'Access-Control-Allow-Methods': '*'
                },
                'body': json.dumps({'error': 'Text too long. Maximum 3000 characters allowed.'})
            }
        
        # Initialize AWS clients
        print("Initializing AWS clients...")
        polly_client = boto3.client('polly')
        s3_client = boto3.client('s3')
        
        # Generate unique filename
        audio_id = str(uuid.uuid4())
        s3_key = f"audio/{audio_id}.mp3"
        print(f"Generated audio_id: {audio_id}")
        
        # Convert text to speech using Polly
        print("Calling Polly...")
        response = polly_client.synthesize_speech(
            Text=text,
            OutputFormat='mp3',
            VoiceId=voice_id,
            Engine='standard'
        )
        print("Polly response received")
        
        # Upload audio to S3
        audio_bucket = os.environ.get('AUDIO_BUCKET')
        print(f"Uploading to S3 bucket: {audio_bucket}")
        
        if not audio_bucket:
            raise Exception("AUDIO_BUCKET environment variable not set")
        
        s3_client.put_object(
            Bucket=audio_bucket,
            Key=s3_key,
            Body=response['AudioStream'].read(),
            ContentType='audio/mpeg'
        )
        print("S3 upload completed")
        
        # Generate presigned URL for download
        presigned_url = s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': audio_bucket, 'Key': s3_key},
            ExpiresIn=3600
        )
        print(f"Generated presigned URL: {presigned_url[:50]}...")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Methods': '*'
            },
            'body': json.dumps({
                'url': presigned_url,
                'audioId': audio_id,
                'message': 'Speech generated successfully'
            })
        }
        
    except Exception as e:
        error_msg = str(e)
        print(f"ERROR: {error_msg}")
        import traceback
        print(f"TRACEBACK: {traceback.format_exc()}")
        
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Methods': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'details': error_msg
            })
        }