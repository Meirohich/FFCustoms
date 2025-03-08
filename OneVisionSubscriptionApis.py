# A very simple Flask Hello World app for you to get started with...

from flask import Flask, request, jsonify
import json
import base64
import hmac
import requests
from datetime import datetime, timedelta
import firebase_admin
from firebase_admin import credentials, firestore, auth
# from dotenv import load_dotenv
import os
import pandas as pd

# FireBase credentials
cred_path = os.path.abspath(os.path.dirname(__file__)) + "/credentials.json"
cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)
fs_db = firestore.client()



app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello from Flask!'

### OneVision start

# load_dotenv()

# API_KEY = os.getenv('API_KEY')
# SECRET_KEY = os.getenv('SECRET_KEY')
# SERVICE_ID = os.getenv('SERVICE_ID')
# MERCHANT_ID = os.getenv('MERCHANT_ID')

def update_records(order_id, user_token, payment_id, payment_date):
    try:
        # Search for the payment document by orderId field
        payment_ref = fs_db.collection('payments').document(order_id)
        payment_doc = payment_ref.get()

        if not payment_doc.exists:
            return f"No payment with document ID {order_id} found."

        # Reference to the payment document
        payment_data = payment_doc.to_dict()
        amount = payment_data.get('amount')

        if amount is None:
            return "Payment amount is missing."

        # Query subscriptions collection to find a matching reg_price
        subscriptions_query = fs_db.collection('subscriptions').where('reg_price', '==', amount).limit(1)
        subscription_docs = subscriptions_query.stream()
        subscription_doc = next(subscription_docs, None)

        if not subscription_doc:
            return "No matching subscription found for this amount."

        subscription_data = subscription_doc.to_dict()
        subscription_ref = subscription_doc.reference

        # Update user's user_token if user_token is provided
        if user_token and user_token != 'none':
            user_ref = payment_data.get('userRef')
            if user_ref:
                user_doc = user_ref.get()
                if user_doc.exists:
                    user_doc_ref = fs_db.document(user_ref.path)
                    user_doc_ref.update({'user_token': user_token, 'subscriptionRef': subscription_ref})

                    # Determine subscription expiration date
                    sub_type = subscription_data.get('subscription', '').lower()
                    if sub_type == 'annual':
                        next_expiry = datetime.utcnow() + timedelta(days=365)
                    elif sub_type == 'monthly':
                        next_expiry = datetime.utcnow() + timedelta(days=30)
                    else:
                        return "Invalid subscription type."

                    subscription_exp_date = next_expiry.replace(hour=3, minute=0, second=0, microsecond=0)
                    user_doc_ref.update({
                        'subscriptionExpDate': subscription_exp_date,
                        'isPremium': True
                    })

        # Parse and update payment_date
        dt = payment_date
        if isinstance(payment_date, dict) and 'seconds' in payment_date:
            seconds = payment_date['seconds']
            dt = datetime.utcfromtimestamp(seconds)
        elif '+' in payment_date:
            try:
                dt = datetime.strptime(payment_date.replace(' UTC', ''), '%Y-%m-%d %H:%M:%S.%f +0000')
            except ValueError:
                dt = datetime.strptime(payment_date.replace(' UTC', ''), '%Y-%m-%d %H:%M:%S +0000')

        # Update payment document
        payment_ref.update({
            'status': 'paid',
            'paymentId': str(payment_id),
            'payment_date': dt,
            'orderId': order_id
        })

        return "success"
    except Exception as e:
        # Log error in the payment document
        if 'payment_ref' in locals():
            payment_ref.update({'status': 'error', 'error': str(e)})
        return f"An error occurred: {str(e)}"


@app.route('/payment_callback', methods=['POST'])
def payment_callback():
    # Extract and decode the 'data' field
    request_data = request.json
    encoded_data = request_data.get('data')
    if encoded_data:
        # Decode and parse the data
        decoded_data = base64.b64decode(encoded_data).decode()
        parsed_data = json.loads(decoded_data)

        # Check the operation status
        operation_status = parsed_data.get('operation_status')
        if operation_status == 'error':
            return jsonify({'error': 'Operation resulted in an error'}), 404

        order_id = parsed_data.get('order_id')
        user_token = parsed_data.get('recurrent_token')
        payment_id = parsed_data.get('payment_id')
        payment_date = parsed_data.get('payment_date')
        if order_id and user_token and payment_date:

            res = update_records(order_id, user_token, payment_id, payment_date)
            if res == 'success':
                return jsonify({'message': 'Record updated successfully'}), 200
            else:
                return jsonify({'message': res}), 500
        else:
            return jsonify({'error': "Missing 'order_id' or 'user_token' or 'payment_date' in the data"}), 400
    else:
        return jsonify({'error': "Missing 'data' field in request"}), 400


def make_onevision_request(payload, endpoint, is_status = False):
    try:

        API_KEY = Api_key
        SECRET_KEY = Secret_key
        ENDPOINT = endpoint

        data_json = json.dumps(payload)
        data_encoded = base64.b64encode(data_json.encode()).decode()

        sign = hmac.new(SECRET_KEY.encode(), data_encoded.encode(), digestmod="sha512").hexdigest()

        headers = {
            "Authorization": f"Bearer {base64.b64encode(API_KEY.encode()).decode()}",
            "Content-Type": "application/json"
        }

        request_data = {
            "data": data_encoded,
            "sign": sign
        }

        response = requests.post(ENDPOINT, json=request_data, headers=headers)
        # print("Response Status Code:", response.status_code)

        response_data = response.json()
        # print("Response Text:", response_data.get('data'))

        if is_status == False:
            # Check the 'success' value
            if not response_data.get('success'):
                return jsonify(response_data), 400

        # Decode the 'data' field from the API response
        encoded_data = response_data.get('data')
        if encoded_data:
            decoded_data = base64.b64decode(encoded_data).decode()
            parsed_data = json.loads(decoded_data)
            # You can now use parsed_data to return the unhashed data
            return jsonify(parsed_data), response.status_code
        else:
            # If 'data' field is missing, return the original response
            return jsonify(response_data), response.status_code

    except Exception as e:
        app.logger.error(f"An error occurred: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/make_binding_payment', methods=['POST'])
def make_binding_payment():

    endpoint = "https://api.paysage.kz/payment/create"

    data = request.json

    amount = round(float(data['amount']), 2)
    order_id = (data['order_id'])
    description = str(data['description'])
    phone = str(data['phone'])
    user_id = str(data['user_id'])
    email = str(data['email'])

    success_url = str(data.get('success_url', 'https://webhook.site/1e24940c-d8ce-48c9-a074-c17f060f5670'))

    # need to change callback and other urls
    payload = {
        "amount": amount,
        "currency": "KZT",
        "order_id": order_id,
        "description": description,
        "payment_type": "pay",
        "payment_method": "ecom",
        "user_id": user_id,
        "email": email,
        "phone": phone,
        "success_url": success_url,
        "failure_url": "https://webhook.site/1e24940c-d8ce-48c9-a074-c17f060f5670",
        "callback_url": "https://mihrapp-adenbekov.pythonanywhere.com/payment_callback",
        # "merchant_term_rl": "https://webhook.site/1e24940c-d8ce-48c9-a074-c17f060f5670",
        "payment_lifetime": 3600,
        "lang": "ru",
        "items": [
            {
                "merchant_id": merchant_id,
                "service_id": service_id,
                "merchant_name": "mihrApp",
                "name": "Курсы",
                "quantity": 1,
                "amount_one_pcs": amount,
                "amount_sum": amount
            }
        ],
        "create_recurrent_profile": True,
        "recurrent_profile_lifetime": 365
    }

    return make_onevision_request(payload, endpoint)


@app.route('/make_recurrent_payment', methods=['POST'])
def make_recurrent_payment():

    endpoint = "https://api.paysage.kz/payment/recurrent"

    data = request.json

    amount = float(data['amount'])
    order_id = (data['order_id'])
    description = str(data['description'])
    token = str(data['token'])

    payload = {
        "test_mode": 1,
        "amount": amount,
        "order_id": order_id,
        "description": description,
        "token": token,
    }

    return make_onevision_request(payload, endpoint)


@app.route('/recurrent_payment_status', methods=['POST'])
def recurrent_payment_status():

    endpoint = "https://arm.paysage.kz/payment/status"

    data = request.json

    payment_id = data.get('payment_id')
    order_id = data.get('order_id')

    payload = {
        "order_id": order_id
    }

    return make_onevision_request(payload, endpoint, True)


@app.route('/status_callback', methods=['POST'])
def status_callback():

    data = request.json

    order_id = data.get('order_id')
    payment_id = str(data.get('payment_id'))
    payment_date = str(data.get('payment_date'))
    recurrent_token = str(data.get('recurrent_token'))
    # order_id = (request.args.get('order_id'))
    # payment_id = str(request.args.get('payment_id'))
    # payment_date = str(request.args.get('payment_date'))

    res = update_records(order_id, recurrent_token, payment_id, payment_date)
    if res == 'success':
        return jsonify({'message': 'Record updated successfully'}), 200
    else:
        return jsonify({'message': res}), 500


# @app.route('/retrieve/<order_id>', methods=['GET'])
# def retrieve_data(order_id):
#     # Retrieve data by 'order_id'
#     data = data_store.pop(order_id, None)

#     if data:
#         return jsonify(data)
#     else:
#         return "Data not found for the provided order_id", 404


### OneVision end

