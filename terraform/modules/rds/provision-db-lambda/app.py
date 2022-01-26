import sys
import pymysql
import boto3
import botocore
import json
import random
import time
import os
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# settings
rds_host          = os.environ['RDS_HOST']
vpc_cidr_block    = os.environ['VPC_CIDR_BLOCK']
db_name           = os.environ['RDS_DB_NAME']
helperFunctionARN = os.environ['HELPER_FUNCTION_ARN']
secret_name       = os.environ['SECRET_NAME']

my_session  = boto3.session.Session()
region_name = my_session.region_name
schema_file = 'schema.sql'
conn = None

# Get the service resource.
lambdaClient = boto3.client('lambda')

def invokeConnCountManager(incrementCounter):
    response = lambdaClient.invoke(
        FunctionName = helperFunctionARN,
        InvocationType = 'RequestResponse',
        Payload = '{"incrementCounter":' + str.lower(str(incrementCounter)) + ',"RDBMSName": "Prod_MySQL"}'
    )
    retVal = response['Payload']
    retVal1 = retVal.read()
    return retVal1

def get_sql_from_file(filename = schema_file):
    """
    Get the SQL instruction from a file

    :return: a list of each SQL query without the trailing ';'
    """
    from os import path

    # File did not exists
    if path.isfile(filename) is False:
        logger.error("ERROR: File load error : {}".format(filename))
        return False

    else:
        with open(filename, "r") as sql_file:
            # Split file in list
            ret = sql_file.read().split(';')
            # drop last empty entry
            ret.pop()
            return ret

def openConnection():
    logger.info("In Open connection")
    global conn
    secrets = None
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId = secret_name
        )
    except ClientError as e:
        logger.info(e)
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        if 'SecretString' in get_secret_value_response:
            secrets = json.loads(get_secret_value_response['SecretString'])
        else:
            secrets = base64.b64decode(get_secret_value_response['SecretBinary'])

    try:
        if(conn is None or not conn.open):
            conn = pymysql.connect(
                rds_host,
                user = secrets['root_username'],
                passwd = secrets['root_password'],
                db = db_name,
                connect_timeout = 5
            )

    except Exception as e:
        logger.error("ERROR: Unexpected error: Could not connect to MySQL instance.")
        logger.error(e)
        raise e


def lambda_handler(event, context):
    if invokeConnCountManager(True) == "false":
        print ("Not enough Connections available.")
        return False

    try:
        openConnection()
        with conn.cursor() as cur:
            request_list = self.get_sql_from_file()

            if request_list is not False:
                for idx, sql_request in enumerate(request_list):
                    self.message = self.MSG['request'].format(idx, sql_request)
                    cursor.execute(sql_request + ';')
                    cursor.execute('-- Microservice user')
                    cursor.execute(
                        "CREATE USER '%s'@'%s' IDENTIFIED BY '%s';"
                        % (secrets.user_username, vpc_cidr_block, secrets.user_password)
                    )
                    cursor.execute(
                        "GRANT SELECT, INSERT, UPDATE, DELETE ON utopia.* TO '%s'@'%s';"
                        % (secrets.user_username, vpc_cidr_block)
                    )
                    cursor.execute('FLUSH PRIVILEGES;')
    except Exception as e:
        logger.error("ERROR: Error while opening connection or processing" + e)
        logger.error("ERROR: " + e)
    finally:
        print("Closing Connection")
        if(conn is not None and conn.open):
            conn.close()
        invokeConnCountManager(False)

    return {
        "statusCode": 200,
        "body": "",
        "headers": {
            'Content-Type': 'application/json',
        }
    }
