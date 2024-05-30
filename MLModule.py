import firebase_admin
from firebase_admin import credentials, firestore
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LinearRegression
import nltk
import time

nltk.download('stopwords')
nltk.download('punkt')

try:
    cred = credentials.Certificate("D:\Sale's_ai\Firebase\MLModule\login-21cc2-firebase-adminsdk-4vpxv-121d760acb.json")
    firebase_admin.initialize_app(cred)

    db = firestore.client()
    feedback_collection = db.collection("feedback")
    feedback_documents = feedback_collection.get()
    feedback_data = [(doc.id, doc.get("companyName"), doc.reference.collection("records").get()) for doc in feedback_documents]

    print("Feedback data:")
    print(feedback_data)

    if feedback_data:
        print("Available Companies:")
        for idx, (document_id, company_name, _) in enumerate(feedback_data, start=1):
            print(f"{idx}. {company_name}")
    else:
        print("No feedback data available. Please try again later or contact support.")

    while True:
        start_time = time.time()  

        for idx, (document_id, selected_company_name, records_collection) in enumerate(feedback_data, start=1):
            print(f"\nUpdating suggestions for {selected_company_name}...")

            try:
                def preprocess_data(records):
                    processed_data = []

                    for record in records:
                        user_input = record.get("feedback", "")

                        tokens = word_tokenize(user_input.lower())

                        filtered_tokens = [token for token in tokens if token not in stopwords.words("english")]

                        processed_data.append((" ".join(filtered_tokens)))

                    return processed_data

                records = []

                for doc in records_collection:
                    record_data = doc.to_dict()
                    feedback_data = record_data.get("feedback", "")
                    records.append({"feedback": feedback_data})

                processed_feedback_data = preprocess_data(records)

                if not processed_feedback_data:
                    print("No feedback data available for this company. Skipping...")
                    continue

                y_train_numeric = [record.get("ratings", {}).get("Recommendation", 0) for record in records]

                X_train = processed_feedback_data
                vectorizer = TfidfVectorizer()
                X_train_vectorized = vectorizer.fit_transform(X_train)

                regressor = LinearRegression()
                regressor.fit(X_train_vectorized, y_train_numeric)

                def generate_suggestions(user_input):

                    tokens = word_tokenize(user_input.lower())
                    filtered_tokens = [token for token in tokens if token not in stopwords.words("english")]
                    processed_input = " ".join(filtered_tokens)

                    input_vectorized = vectorizer.transform([processed_input])

                    suggestion_numeric = regressor.predict(input_vectorized)

                    product_suggestion = "Improve the quality and features of your products."
                    service_suggestion = "Great job! Users appreciate your excellent service."
                    support_suggestion = "Consider enhancing your support services for better user satisfaction."
                    delivery_suggestion = "Ensure timely and reliable delivery to enhance user experience."
                    experience_suggestion = "Focus on improving the overall user experience of your products and services."

                    return {
                        "product": product_suggestion,
                        "service": service_suggestion,
                        "support": support_suggestion,
                        "delivery": delivery_suggestion,
                        "experience": experience_suggestion
                    }

                suggestion_data = generate_suggestions(selected_company_name)
                print(f"Suggestions for {selected_company_name} users:")
                for key, value in suggestion_data.items():
                    print(f"{key.capitalize()}: {value}")

                suggestion_collection = db.collection("Suggestion_record")
                company_document_ref = suggestion_collection.document(selected_company_name)
                company_document_ref.set(suggestion_data)
                print("Suggestion added successfully.")

            except Exception as e:
                print(f"An error occurred while processing {selected_company_name}: {e}")

        # Check for new companies and add their suggestions
        new_feedback_documents = feedback_collection.get()
        new_feedback_data = [(doc.id, doc.get("companyName")) for doc in new_feedback_documents]
        new_companies = set(new_feedback_data) - set(feedback_data)
        print("New companies found:", new_companies)
        for document_id, company_name in new_companies:
            print(f"\nAdding suggestions for new company: {company_name}")
            # Add your logic to generate suggestions and store them for the new company
            
        end_time = time.time()  
        elapsed_time = end_time - start_time  

        if elapsed_time < 100:
            time.sleep(100 - elapsed_time)

except Exception as e:
    print(f"An error occurred: {e}")
