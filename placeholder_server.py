from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend testing

# Mock Data
planned_plates = [
    {"id": 1, "name": "Pâtes Carbonara", "date": "2026-03-14", "image": "🍝"},
    {"id": 2, "name": "Salade César", "date": "2026-03-15", "image": "🥗"}
]

@app.route('/auth/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    if not email:
        return jsonify({"success": False, "message": "Email is required"}), 400

    print(f"Login requested for: {email}")
    return jsonify({"success": True, "message": "Code sent successfully"})

@app.route('/auth/verify', methods=['POST'])
def verify():
    data = request.json
    email = data.get('email')
    code = data.get('code')

    if not email or not code:
        return jsonify({"success": False, "message": "Email and code are required"}), 400

    # Logic: If code is 123456, it's a new user. Otherwise, existing user.
    is_new_user = (code == "123456")

    return jsonify({
        "success": True,
        "key": "mock_api_token_12345",
        "newuser": is_new_user
    })

@app.route('/auth/verify-group', methods=['POST'])
def verify_group():
    data = request.json
    group_code = data.get('group_code')

    # Simple check: valid if code is not empty
    is_valid = bool(group_code and len(group_code) > 3)

    return jsonify({
        "success": True,
        "valid": is_valid
    })

@app.route('/auth/onboard', methods=['POST'])
def onboard():
    # In a real app, we'd check the Authorization header
    auth_header = request.headers.get('Authorization')
    if not auth_header:
         return jsonify({"success": False, "message": "Unauthorized"}), 401

    data = request.json
    print(f"Onboarding data received: {data}")
    return jsonify({"success": True, "message": "Onboarding completed."})

@app.route('/plates/planned', methods=['GET'])
def get_planned_plates():
    auth_header = request.headers.get('Authorization')
    if not auth_header:
         return jsonify({"success": False, "message": "Unauthorized"}), 401

    return jsonify({
        "success": True,
        "plates": planned_plates
    })

@app.route('/plates', methods=['POST'])
def add_plate():
    auth_header = request.headers.get('Authorization')
    if not auth_header:
         return jsonify({"success": False, "message": "Unauthorized"}), 401

    data = request.json
    name = data.get('name')

    if not name:
        return jsonify({"success": False, "message": "Name is required"}), 400

    new_plate = {
        "id": len(planned_plates) + 1,
        "name": name,
        "date": "2026-03-16",
        "image": "🍽️"
    }
    planned_plates.append(new_plate)

    return jsonify({"success": True, "message": "Plate added."})

if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True, port=5000)
