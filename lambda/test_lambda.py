import json
import boto3
import os

def lambda_handler(event, context):
    print(f"Event: {json.dumps(event)}")
    print(f"Environment variables: {dict(os.environ)}")
    
    try:
        # Test basic functionality step by step
        print("Step 1: Parse body")
        if 'body' in event:
            body = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        else:
            body = event
        
        text = body.get('text', 'Hello world')
        voice_id = body.get('voiceId', 'Joanna')
        print(f"Text: {text}, Voice: {voice_id}")
        
        print("Step 2: Initialize Polly client")
        polly_client = boto3.client('polly')
        
        print("Step 3: Call Polly")
        response = polly_client.synthesize_speech(
            Text=text,
            OutputFormat='mp3',
            VoiceId=voice_id,
            Engine='standard'
        )
        print("Polly call successful")
        
        print("Step 4: Initialize S3 client")
        s3_client = boto3.client('s3')
        audio_bucket = os.environ.get('AUDIO_BUCKET')
        print(f"Audio bucket: {audio_bucket}")
        
        if not audio_bucket:
            raise Exception("AUDIO_BUCKET environment variable not set")
        
        print("Step 5: Upload to S3")
        s3_key = f"audio/test-{context.aws_request_id}.mp3"
        s3_client.put_object(
            Bucket=audio_bucket,
            Key=s3_key,
            Body=response['AudioStream'].read(),
            ContentType='audio/mpeg'
        )
        print("S3 upload successful")
        
        print("Step 6: Generate presigned URL")
        presigned_url = s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': audio_bucket, 'Key': s3_key},
            ExpiresIn=3600
        )
        print(f"Presigned URL generated: {presigned_url[:50]}...")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Methods': '*'
            },
            'body': json.dumps({
                'url': presigned_url,
                'message': 'Success'
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
                'error': error_msg,
                'step': 'See CloudWatch logs for details'
            })
        }